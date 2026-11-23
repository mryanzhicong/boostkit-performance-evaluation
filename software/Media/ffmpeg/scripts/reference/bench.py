import csv
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time
ROOT = Path(__file__).resolve().parent
NODE = None
WORK = ROOT / '.work'
PREFIX = ROOT.parent / 'software/ffmpeg-7.1.1/ffmpeg_install'
ITERATIONS = 20
VIDEOS = [{'name': 'BQTerrace', 'filename': 'BQTerrace_1920x1080_60-dianbo.yuv', 'fps': 60}, {'name': 'Film2012', 'filename': 'Film2012_1920x1080_25_8bit_8Mbps.yuv', 'fps': 25}, {'name': 'messi', 'filename': 'messi_1920x1080_25_1000.yuv', 'fps': 25}]

def digest(path):
    result = hashlib.sha256()
    with path.open('rb') as stream:
        for data in iter(lambda: stream.read(1024 * 1024), b''):
            result.update(data)
    return result.hexdigest()

def prepare(item):
    source = Path('/home/test/Test/video') / item['filename']
    required = 1920 * 1080 * 3 // 2 * 30
    if source.stat().st_size < required:
        raise ValueError('Input video needs at least 30 frames: ' + str(source))
    clip = WORK / (item['name'] + '-30.yuv')
    with source.open('rb') as stream:
        clip.write_bytes(stream.read(required))
    return clip

def run(command, env):
    start = time.perf_counter_ns()
    result = subprocess.run(command, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=300)
    if result.returncode:
        raise ValueError(result.stderr.decode(errors='replace')[-2000:])
    return (time.perf_counter_ns() - start) / 1000000.0 / 30

def warm(command, env):
    subprocess.run(command, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True, timeout=300)

def main():
    WORK.mkdir(exist_ok=True)
    inputs = [(item, prepare(item)) for item in VIDEOS]
    env = os.environ.copy()
    env.update(LD_LIBRARY_PATH=str(PREFIX / 'lib'), LC_ALL='C', OMP_NUM_THREADS='1', OMP_THREAD_LIMIT='1')
    encoder = PREFIX / 'bin/ffmpeg'
    evidence = dict(cpu=None, node=NODE, source_mode='unpatched', cases={})
    failed = False
    destination = ROOT / 'result_bench-ffmpeg.csv'
    print('CPU affinity: unbound; codec/filter threads: 1; repetitions: 20; frames per command: 30')
    print('{:<34} {:>10} {:>14} {:>6}'.format('scenario', 'frames', 'ms/frame', 'status'))
    with destination.open('w', newline='') as stream:
        writer = csv.writer(stream)
        writer.writerow(['scenario', 'frames', 'ms_per_frame', 'status'])
        for item, source in inputs:
            for width, height, pixel in ((640, 360, 'rgb24'),):
                name = '{}_{}x{}_{}'.format(item['name'], width, height, pixel)
                output = WORK / 'output.raw'
                command = [str(encoder), '-v', 'error', '-nostdin', '-y', '-threads', '1', '-filter_threads', '1', '-f', 'rawvideo', '-pixel_format', 'yuv420p', '-video_size', '1920x1080', '-framerate', str(item['fps']), '-i', str(source), '-vf', 'scale={}:{}:flags=bilinear+accurate_rnd+bitexact'.format(width, height), '-frames:v', '30', '-threads', '1', '-c:v', 'rawvideo', '-pix_fmt', pixel, '-f', 'rawvideo', str(output)]
                try:
                    warm(command, env)
                    expected_size = width * height * 30 * 3 // (1 if pixel == 'rgb24' else 2)
                    if output.stat().st_size != expected_size:
                        raise ValueError('Output frame data is incomplete.')
                    timed = command[:-1] + ['/dev/null']
                    samples = [run(timed, env) for _ in range(ITERATIONS)]
                    evidence['cases'][name] = dict(samples_ms_per_frame=samples, output_sha256=digest(output))
                    value, status = ('{:.6f}'.format(statistics.median(samples)), 'OK')
                except (OSError, ValueError, subprocess.SubprocessError) as error:
                    print('ERROR: {}: {}'.format(name, error), file=sys.stderr)
                    value, status, failed = ('', 'FAIL', True)
                (WORK / 'evidence.json').write_text(json.dumps(evidence, indent=2))
                writer.writerow([name, 30, value, status])
                stream.flush()
                print('{:<34} {:>10} {:>14} {:>6}'.format(name, 30, value or '-', status), flush=True)
                output.unlink(missing_ok=True)
    print('Result: ' + str(destination))
    print('Read ms_per_frame (milliseconds per frame); lower is better.')
    return int(failed)
if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        sys.exit('ERROR: ' + str(error))
