import csv
import importlib.util
import os
from pathlib import Path
import shutil
import subprocess
import sys
SCRIPTS = Path(__file__).resolve().parent
ROOT = SCRIPTS / '.work'
ROOT.mkdir(exist_ok=True)
spec = importlib.util.spec_from_file_location('bench_scene', SCRIPTS / 'bench_scene.py')
engine = importlib.util.module_from_spec(spec)
spec.loader.exec_module(engine)
install = Path((SCRIPTS.parent / 'software/current-install.txt').read_text().strip())
ffmpeg = install / 'bin/ffmpeg'
VIDEOS = [{'name': 'BQTerrace', 'filename': 'BQTerrace_1920x1080_60-dianbo.yuv', 'fps': 60}]

def prepare(item):
    source = Path(os.environ.get('X265_VIDEO_DIR', '/home/test/Test/video')) / item['filename']
    if source.stat().st_size < 1920 * 1080 * 3 // 2 * 600:
        raise ValueError('Input video needs at least 600 frames: ' + str(source))
    return source

def main():
    manifest = engine.read_json(install / 'build-manifest.json')
    if manifest['config']['libnuma'] or manifest['config']['x265'] != '4.2':
        raise ValueError('A stock 8-bit x265 4.2 build with libnuma disabled is required.')
    clips = [(item, prepare(item)) for item in VIDEOS]
    destination = SCRIPTS / 'result_bench-x265.csv'
    destination.write_text('scenario,frames,fps,status\n')
    runs = []
    cases = ROOT / 'cases'
    cases.mkdir(exist_ok=True)
    print('Single route; CPU/NUMA affinity: unbound; pools=16; frame-threads=15')
    print('{:<38} {:>8} {:>12} {:>6}'.format('scenario', 'frames', 'fps', 'status'))
    for item, clip in clips:
        for crf in (24, 28):
            name = '{}_medium_crf{}_offline'.format(item['name'], crf)
            video = dict(id=item['name'], path=str(clip), width=1920, height=1080, fps=str(item['fps']), pix_fmt='yuv420p', start_frame=0, screen_frames=600)
            case = dict(id=item['name'] + '-medium-l16-ft15-ctu16-bf7-pool16-aq4',
                        video=video, cores=16, preset='medium', frame_threads=15,
                        pool_threads=16, ctu_size=16, bframes=7, aq_mode=4,
                        crf=crf, maxrate_kbps=6000, bufsize_kbits=12000)
            plan = dict(phase='confirm', unbound=True, warm_input=True, cases=[case])
            folder = cases / name
            if folder.is_symlink() or folder.resolve().parent != cases.resolve():
                raise ValueError('Unsafe work directory.')
            if folder.exists():
                shutil.rmtree(folder)
            folder.mkdir()
            engine.save_json(folder / 'plan.json', plan)
            info = dict(sha256=None, total_frames=600)
            row = engine.encode_one(ffmpeg, plan['cases'][0], [0], {0: []}, 1, plan, info, folder, 1800, False)
            data = dict(rows=[row], affinity='unbound', plan=plan)
            engine.save_json(folder / 'results.json', data)
            if row['status'] != 'OK' or row['frames'] != 600:
                raise ValueError('Encoding validation failed: ' + str(row))
            record = dict(scenario=name, item=item, data=data, output=str(folder / row['folder'] / 'output.mp4'), command_file=str(folder / row['folder'] / 'command.json'))
            runs.append(record)
            engine.save_json(ROOT / 'evidence.json', dict(runs=runs))
            print('{:<38} {:>8} {:>12.3f} {:>6}'.format(name, 600, row['fps'], 'OK'), flush=True)
    engine.save_json(ROOT / 'evidence.json', dict(runs=runs, affinity='unbound'))
    with destination.open('w', newline='') as stream:
        writer = csv.writer(stream)
        writer.writerow(['scenario', 'frames', 'fps', 'status'])
        for record in runs:
            writer.writerow([record['scenario'], 600, '{:.3f}'.format(record['data']['rows'][0]['fps']), 'OK'])
    print('Result: ' + str(destination))
    print('Read fps (frames per second); higher is better.')
if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        sys.exit('ERROR: ' + str(error))
