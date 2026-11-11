"""原版 x265 场景测试；仅使用 Python 标准库，产物写入指定工作目录。"""


import argparse


import hashlib


import json


import os


from pathlib import Path


import platform


import re


import shlex


import signal


import subprocess


import sys


import time


import threading


from datetime import datetime


from fractions import Fraction


ROOT = Path(__file__).resolve().parent.parent


PRESETS = ("ultrafast", "superfast", "veryfast", "faster", "fast", "medium", "slow", "slower", "veryslow", "placebo")


TUNES = ("none", "zerolatency", "fastdecode", "grain", "psnr", "ssim", "animation")


ME_METHODS = ("dia", "hex", "umh", "star", "sea", "full")


CTU_SIZES = (16, 32, 64)


STOP = threading.Event()


def execute(command, timeout, stdout, stderr):
    """超时或停止时回收整组子进程，避免后台残留编码任务。"""
    if STOP.is_set():
        raise ValueError("测试已停止")
    process = subprocess.Popen(command, stdout=stdout, stderr=stderr, start_new_session=True)
    started = time.monotonic()
    try:
        while process.poll() is None:
            if STOP.wait(0.1):
                raise ValueError("测试已停止")
            if time.monotonic() - started > timeout:
                raise ValueError(f"任务超过{timeout}秒")
        if process.returncode:
            raise ValueError(f"进程退出码{process.returncode}")
    except BaseException:
        if process.poll() is None:
            os.killpg(process.pid, signal.SIGTERM)
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
        raise


def save_json(path, data):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def read_json(path):
    return json.loads(Path(path).read_text(encoding="utf-8-sig"))


def digest(path):
    checksum = hashlib.sha256()
    with open(path, "rb") as stream:
        for chunk in iter(lambda: stream.read(8 * 1024 * 1024), b""):
            checksum.update(chunk)
    return checksum.hexdigest()


def capture(command):
    result = subprocess.run(command, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, check=True)
    return result.stdout


def make_pool_list(nodes, cpus_by_node, pool_threads=None):
    pools = [0] * (max(nodes) + 1)
    if pool_threads is None:
        for node, cpus in cpus_by_node.items():
            pools[int(node)] = len(cpus)
    else:
        per_node, remainder = divmod(pool_threads, len(nodes))
        if remainder:
            raise ValueError("pool_threads不能平均分到NUMA节点")
        for node in nodes:
            pools[int(node)] = per_node
    return ",".join(map(str, pools))


def binding_args(nodes, cpus_by_node):
    return []


def command_for(ffmpeg, case, nodes, cpus_by_node, input_path, start, frames, output,
                use_libnuma=False):
    video = case["video"]
    offset = start * video["width"] * video["height"] * 3 // 2
    requested_pool_threads = case.get("pool_threads")
    if use_libnuma:
        pool_layout = make_pool_list(nodes, cpus_by_node, requested_pool_threads)
    elif len(nodes) == 1:
        pool_layout = str(requested_pool_threads or case["cores"])
    else:
        raise ValueError("跨NUMA线程池需要ENABLE_LIBNUMA构建")
    command = binding_args(nodes, cpus_by_node) + [str(ffmpeg), "-hide_banner", "-nostdin", "-loglevel", "info", "-n",
            "-f", "rawvideo", "-pixel_format", "yuv420p", "-video_size",
            f"{video['width']}x{video['height']}", "-framerate", str(video["fps"]),
            "-skip_initial_bytes", str(offset), "-i", str(input_path),
            "-map", "0:v:0", "-an", "-frames:v", str(frames), "-c:v", "libx265",
            "-preset", case["preset"], "-crf", str(case["crf"]),
            "-maxrate", f"{case['maxrate_kbps']}k", "-bufsize", f"{case['bufsize_kbits']}k"]
    if case.get("tune", "none") != "none":
        command.extend(["-tune", case["tune"]])
    x265_params = [f"pools={pool_layout}", f"frame-threads={case['frame_threads']}"]
    if case.get("ctu_size") is not None:
        x265_params.append(f"ctu={case['ctu_size']}")
    if case.get("me") is not None:
        x265_params.append(f"me={case['me']}")
    if case.get("aq_mode") is not None:
        x265_params.append(f"aq-mode={case['aq_mode']}")
    if case.get("bframes") is not None:
        x265_params.append(f"bframes={case['bframes']}")
    if case.get("keyint") is not None:
        x265_params.append(f"keyint={case['keyint']}")
    if case.get("b_adapt") is not None:
        x265_params.append(f"b-adapt={case['b_adapt']}")
    if case.get("pmode", False):
        x265_params.append("pmode=1")
    if case.get("pme", False):
        x265_params.append("pme=1")
    if case.get("sao") is not None:
        x265_params.append(f"sao={int(case['sao'])}")
    if case.get("rd") is not None:
        x265_params.append(f"rd={case['rd']}")
    if case.get("subme") is not None:
        x265_params.append(f"subme={case['subme']}")
    command.extend(["-threads:v", "0", "-x265-params",
            ":".join(x265_params),
            "-progress", "pipe:1", "-nostats", "-f", "mp4", "-movflags", "+faststart", str(output)])
    return command


def warm_input(ffmpeg, case, nodes, cpus_by_node, start, frames, folder, timeout):
    video = case["video"]
    command = binding_args(nodes, cpus_by_node) + [
               str(ffmpeg), "-v", "error", "-nostdin", "-f", "rawvideo", "-pixel_format", "yuv420p",
               "-video_size", f"{video['width']}x{video['height']}", "-framerate", str(video["fps"]),
               "-skip_initial_bytes", str(start * video["width"] * video["height"] * 3 // 2),
               "-i", video["path"], "-frames:v", str(frames), "-c:v", "copy", "-f", "null", "-"]
    save_json(folder / "warmup-command.json", command)
    with open(folder / "warmup.log", "w", encoding="utf-8") as log:
        execute(command, timeout, log, log)


def encode_one(ffmpeg, case, nodes, cpus_by_node, repeat, plan, info, root, timeout, use_libnuma):
    flat_cpus = sorted(cpu for group in cpus_by_node.values() for cpu in group)
    node_tag = "-".join(map(str, nodes))
    folder = root / f"{case['id']}-r{repeat}-n{node_tag}"
    folder.mkdir()
    video = case["video"]
    start = video["start_frame"] if plan["phase"] == "screen" else 0
    frames = video["screen_frames"] if plan["phase"] == "screen" else info["total_frames"]
    output = folder / "output.mp4"
    command = command_for(ffmpeg, case, nodes, cpus_by_node, video["path"], start, frames, output,
                          use_libnuma)
    save_json(folder / "command.json", command)
    (folder / "command.txt").write_text(shlex.join(command) + "\n", encoding="utf-8")
    row = {"case": case["id"], "repeat": repeat, "node": nodes[0], "nodes": nodes,
           "node_cpus": cpus_by_node, "cpus": flat_cpus,
           "status": "FAIL", "frames": frames, "start_frame": start,
           "input_sha256": info["sha256"], "settings": case,
           "phase": plan["phase"], "folder": folder.name}
    if plan.get("unbound"):
        row.update(node=None, nodes=[], node_cpus={}, cpus=[], affinity="unbound")
    try:
        # 统一预读策略；不计入编码时间，不宣称整个大文件一定驻留内存。
        if plan.get("warm_input", True):
            warm_input(ffmpeg, case, nodes, cpus_by_node, start, frames, folder, timeout)
        with open(folder / "progress.txt", "w", encoding="utf-8") as progress, \
                open(folder / "encode.log", "w", encoding="utf-8") as log:
            started = time.monotonic()
            row["started_unix"] = time.time()
            execute(command, timeout, progress, log)
            elapsed = time.monotonic() - started
            row["finished_unix"] = time.time()
        row["seconds"] = elapsed
        progress_text = (folder / "progress.txt").read_text()
        counts = re.findall(r"^frame=\s*(\d+)\s*$", progress_text, re.M)
        if "progress=end" not in progress_text or not counts or int(counts[-1]) != frames:
            raise ValueError("进度未完整结束或实际编码帧数不匹配")
        if not output.is_file() or output.stat().st_size == 0:
            raise ValueError("编码输出为空")
        probe = read_probe(ffmpeg.parent / "ffprobe", output, nodes, cpus_by_node)
        save_json(folder / "probe.json", probe)
        stream = probe["streams"][0]
        if (int(stream["nb_read_frames"]) != frames or stream["codec_name"] != "hevc"
                or int(stream["width"]) != video["width"] or int(stream["height"]) != video["height"]):
            raise ValueError("输出探测的帧数、编码或分辨率不匹配")
        size = output.stat().st_size
        log_text = (folder / "encode.log").read_text(errors="replace")
        x265_log = [line for line in log_text.splitlines() if "x265 [" in line]
        pool_thread_counts = pool_counts(x265_log)
        row.update(status="OK", fps=frames / elapsed, realtime=frames / float(Fraction(str(video["fps"]))) / elapsed,
                   output_bytes=size, output_sha256=digest(output),
                   container_kbps=size * 8 / 1000 / (frames / float(Fraction(str(video["fps"])))),
                   pool_thread_counts=pool_thread_counts, x265_log=x265_log)
    except Exception as error:
        row["error"] = str(error)
    save_json(folder / "result.json", row)
    label = "unbound" if plan.get("unbound") else f"NUMA{nodes} CPUs={flat_cpus}"
    print(f"{row['case']} r{repeat} {label}: {row['status']} "
          f"{row.get('fps', 0):.3f} fps {row.get('error', '')}", flush=True)
    return row


def read_probe(ffprobe, output, nodes=None, cpus_by_node=None):
    binding = binding_args(nodes, cpus_by_node) if cpus_by_node else []
    return json.loads(capture(binding + [str(ffprobe), "-v", "error", "-select_streams", "v:0", "-count_frames",
                               "-show_entries", "stream=codec_name,width,height,nb_read_frames,avg_frame_rate",
                               "-of", "json", str(output)]))


def pool_counts(log_lines):
    result = []
    for line in log_lines:
        match = re.search(r"Thread pool(?: created|\s+\d+)? using (\d+) threads", line)
        if match:
            result.append(int(match.group(1)))
    return result


def tree_digest(root):
    checksum = hashlib.sha256()
    for path in sorted(root.rglob("*")):
        if ".git" in path.relative_to(root).parts:
            continue
        if path.is_symlink():
            raise ValueError(f"源码目录不支持符号链接：{path}")
        if path.is_file():
            checksum.update(path.relative_to(root).as_posix().encode() + b"\0")
            checksum.update(digest(path).encode() + b"\0")
    return checksum.hexdigest()


def build(args):
    if sys.platform != "linux":
        raise ValueError("构建需要目标Linux服务器")
    xsrc, fsrc = Path(args.x265_source).resolve(), Path(args.ffmpeg_source).resolve()
    if not (xsrc / "source/CMakeLists.txt").is_file() or not (fsrc / "configure").is_file():
        raise ValueError("请提供已解压的原版x265 4.2与FFmpeg 7.0.1源码目录")
    if not (fsrc / "RELEASE").is_file() or (fsrc / "RELEASE").read_text().strip() != "7.0.1":
        raise ValueError("FFmpeg源码必须为7.0.1发布包")
    if platform.machine().lower() in ("x86_64", "amd64"):
        nasm = capture(["nasm", "-v"])
        match = re.search(r"version (\d+)\.(\d+)", nasm)
        if not match or tuple(map(int, match.groups())) < (2, 13):
            raise ValueError("x86需要nasm>=2.13")
    elif platform.machine().lower() not in ("aarch64", "arm64"):
        raise ValueError("仅支持AArch64或x86_64")
    if args.jobs < 1:
        raise ValueError("jobs必须大于0")
    prefix = ROOT / "software" / datetime.now().strftime("build-%Y%m%d-%H%M%S-%f")
    if any(prefix.is_relative_to(src) for src in (xsrc, fsrc)):
        raise ValueError("源码目录不能包含构建输出目录")
    prefix.mkdir(parents=True)
    config = {"x265": "4.2", "ffmpeg": "7.0.1", "bit_depth": 8,
              "shared_x265": False, "libnuma": args.enable_numa, "assembly": True,
              "build_type": "Release", "ffmpeg_autodetect": False,
              "extra_cflags": args.extra_cflags, "extra_cxxflags": args.extra_cxxflags}
    manifest = {"sources": {"x265_tree_sha256": tree_digest(xsrc), "ffmpeg_tree_sha256": tree_digest(fsrc)},
                "config": config, "cc": capture(["cc", "--version"]), "cxx": capture(["c++", "--version"]),
                "cmake": capture(["cmake", "--version"]), "commands": []}
    install = prefix / "install"
    xbuild, fbuild = prefix / "x265-build", prefix / "ffmpeg-build"
    fbuild.mkdir()
    env = dict(os.environ)
    env["LC_ALL"] = "C"
    for key, extra in (("CFLAGS", args.extra_cflags), ("CXXFLAGS", args.extra_cxxflags)):
        tokens = shlex.split(extra)
        if tokens:
            env[key] = shlex.join(shlex.split(env.get(key, "")) + tokens)
    manifest["build_environment"] = {key: env.get(key, "") for key in ("CFLAGS", "CXXFLAGS")}
    # 只从本次安装读取pkg-config，防止误链接系统的另一份x265。
    env["PKG_CONFIG_LIBDIR"] = f"{install}/lib/pkgconfig:{install}/lib64/pkgconfig"
    env["PKG_CONFIG_PATH"] = env["PKG_CONFIG_LIBDIR"]
    x265_configure = ["cmake", "-S", str(xsrc / "source"), "-B", str(xbuild),
                      "-DCMAKE_BUILD_TYPE=Release", f"-DCMAKE_INSTALL_PREFIX={install}", "-DENABLE_SHARED=OFF",
                      "-DENABLE_CLI=ON", "-DENABLE_PIC=ON", "-DENABLE_ASSEMBLY=ON",
                      f"-DENABLE_LIBNUMA={'ON' if args.enable_numa else 'OFF'}",
                      "-DHIGH_BIT_DEPTH=OFF"]
    numa_library = os.environ.get("X265_NUMA_LIBRARY")
    if args.enable_numa and numa_library:
        x265_configure.append(f"-DNUMA_LIBRARY={Path(numa_library).resolve()}")
    commands = [(x265_configure, prefix),
                (["cmake", "--build", str(xbuild), "--parallel", str(args.jobs)], prefix),
                (["cmake", "--install", str(xbuild)], prefix),
                ([str(fsrc / "configure"), f"--prefix={install}", "--enable-gpl", "--enable-libx265",
                  "--disable-autodetect", "--disable-doc", "--disable-ffplay", "--pkg-config-flags=--static",
                  "--extra-libs=-lstdc++ -lm -lpthread -ldl"], fbuild),
                (["make", "-j", str(args.jobs)], fbuild), (["make", "install"], fbuild)]
    for index, (command, cwd) in enumerate(commands):
        manifest["commands"].append({"argv": command, "cwd": str(cwd)})
        save_json(prefix / "build-pending.json", manifest)
        print(shlex.join(command), flush=True)
        with open(prefix / f"step-{index}.log", "w", encoding="utf-8") as log:
            subprocess.run(command, cwd=cwd, env=env, stdout=log, stderr=log, check=True)
    cache = (xbuild / "CMakeCache.txt").read_text()
    numa_value = "ON" if args.enable_numa else "OFF"
    if f"ENABLE_LIBNUMA:BOOL={numa_value}" not in cache or "ENABLE_ASSEMBLY:BOOL=ON" not in cache:
        raise ValueError("构建开关未生效，请检查CMakeCache")
    if args.enable_numa:
        configure_log = (prefix / "step-0.log").read_text(errors="replace")
        if "libnuma found, building with support for NUMA nodes" not in configure_log:
            raise ValueError("已请求libnuma，但x265配置日志未确认找到NUMA支持")
    xv = capture([str(install / "bin/x265"), "--version"])
    fv = capture([str(install / "bin/ffmpeg"), "-version"])
    if not re.search(r"version 4\.2(?:\D|$)", xv) or "ffmpeg version 7.0.1" not in fv:
        raise ValueError("安装产物版本不符合要求")
    manifest["versions"] = {"x265": xv, "ffmpeg": fv}
    manifest["binaries"] = {name: digest(install / "bin" / name) for name in ("ffmpeg", "ffprobe", "x265")}
    save_json(install / "build-manifest.json", manifest)
    print(f"构建完成：{install / 'bin/ffmpeg'}。")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['build'])
    parser.add_argument('--x265-source', required=True)
    parser.add_argument('--ffmpeg-source', required=True)
    parser.add_argument('--jobs', type=int, default=16)
    parser.add_argument('--extra-cflags', default='')
    parser.add_argument('--extra-cxxflags', default='')
    args = parser.parse_args()
    args.enable_numa = False
    build(args)


if __name__ == '__main__':
    main()
