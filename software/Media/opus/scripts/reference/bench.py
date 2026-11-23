import csv
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import time
NODE = None
RUNNER = Path(__file__).resolve().parent
ROOT = RUNNER / '.work'
ROOT.mkdir(exist_ok=True)
INPUT = ROOT / 'audio'
INPUT.mkdir(exist_ok=True)
BUILD = RUNNER.parent / 'opus-1.6.1/build-fixed-auto/.libs'
DEMO = BUILD / 'opus_demo'
import urllib.request
import shutil
import wave
AUDIO = [{'name': 'speech_orig', 'url': 'https://media.xiph.org/opus/samples/examples/speech_orig.wav', 'attribution_page': 'https://opus-codec.org/examples/', 'channels': 1, 'sample_rate': 48000, 'sample_width': 2, 'frames': 518400, 'selected_frames': 518400, 'selected_seconds': 10.8}]
for info in AUDIO:
    path = INPUT / (info['name'] + '.wav')
    if not path.exists():
        temporary = path.with_suffix('.part')
        with urllib.request.urlopen(info['url'], timeout=60) as response, temporary.open('wb') as output:
            shutil.copyfileobj(response, output)
        temporary.replace(path)
    with wave.open(str(path), 'rb') as wav:
        assert wav.getframerate() == 48000 and wav.getnchannels() == info['channels'] and (wav.getsampwidth() == 2)
        pcm = wav.readframes(info['selected_frames'])
    if len(pcm) < info['selected_frames'] * info['channels'] * 2:
        raise ValueError('Audio needs at least 10.8 seconds.')
    (INPUT / (info['name'] + '.pcm')).write_bytes(pcm)
env = os.environ.copy()
env['LD_LIBRARY_PATH'] = str(BUILD)
env['OMP_NUM_THREADS'] = '1'
linkage = str(BUILD)
metadata = AUDIO
inputs = {r['name']: r for r in metadata}
cases = [('speech_orig', 'voip', 16000, 5), ('speech_orig', 'voip', 16000, 10), ('speech_orig', 'voip', 24000, 10)]
evidence = dict(version='1.6.1', source_mode='unpatched', build_system='autotools', fixed_point=True, cpu=None, node=NODE, threads=1, linkage=linkage, cases={})
print('CPU/NUMA affinity: unbound; stock fixed-point; 3 cases; 20 iterations', flush=True)
with (RUNNER / 'result_bench-opus.csv').open('w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['scenario', 'iterations', 'ms_per_audio_second', 'status'])
    for source, application, bitrate, complexity in cases:
        info = inputs[source]
        raw = ROOT / (source + '.input.pcm')
        raw.write_bytes((INPUT / (source + '.pcm')).read_bytes())
        name = source + '_' + str(bitrate) + '_complexity' + str(complexity)
        encoded = ROOT / (name + '.packets')
        decoded = ROOT / (name + '.pcm')
        cmd = [str(DEMO), '-e', application, '48000', str(info['channels']), str(bitrate), '-complexity', str(complexity), '-framesize', '20', str(raw), str(encoded)]
        subprocess.run(cmd, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True, timeout=300)
        expected = hashlib.sha256(encoded.read_bytes()).hexdigest()
        samples = []
        for _ in range(20):
            started = time.perf_counter_ns()
            subprocess.run(cmd, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True, timeout=300)
            samples.append((time.perf_counter_ns() - started) / 1000000.0 / info['selected_seconds'])
        dec = [str(DEMO), '-d', '48000', str(info['channels']), str(encoded), str(decoded)]
        subprocess.run(dec, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True, timeout=300)
        samples_out = decoded.stat().st_size // (info['channels'] * 2)
        assert abs(samples_out - info['selected_frames']) <= 1920
        row = dict(input_sha256=hashlib.sha256(raw.read_bytes()).hexdigest(), encoded_sha256=expected, decoded_sha256=hashlib.sha256(decoded.read_bytes()).hexdigest(), output_bytes=encoded.stat().st_size, decoded_frames=samples_out, input_frames=info['selected_frames'], samples_ms_per_audio_second=samples, command=cmd)
        evidence['cases'][name] = row
        writer.writerow([name, 20, f'{statistics.mean(samples):.6f}', 'OK'])
        f.flush()
        (ROOT / 'evidence.json').write_text(json.dumps(evidence, indent=2))
        print(f'{name:40s} 20 {statistics.mean(samples):12.6f} OK', flush=True)
print('Result:', RUNNER / 'result_bench-opus.csv')
print('查看 ms_per_audio_second 列，单位毫秒/音频秒，越小越好。')
