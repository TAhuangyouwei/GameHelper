"""Exercise the actual background converter; never opens a user scene."""
from pathlib import Path
import hashlib
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
FFMPEG = ROOT / '.local/refplayer/ffmpeg.exe'
WORKER = ROOT / 'scripts/实用工具/动画/RenderToMP4.ps1'


def run(*args, check=True):
    return subprocess.run([str(arg) for arg in args], check=check, capture_output=True, timeout=60)


def convert(source, check=True, previous=None, encoded=False):
    extra = ['-PreviousWriteTime', previous[0], '-PreviousLength', previous[1]] if previous else []
    if encoded:
        import base64
        def quote(value):
            return "'" + str(value).replace("'", "''") + "'"
        command = '& ' + quote(WORKER) + ' -InputPath ' + quote(source) + ' -FFmpegPath ' + quote(FFMPEG)
        if previous:
            command += ' -PreviousWriteTime ' + quote(previous[0]) + ' -PreviousLength ' + previous[1]
        return run('powershell.exe', '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass',
                   '-EncodedCommand', base64.b64encode(command.encode('utf-16-le')).decode(), check=check)
    return run('powershell.exe', '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass',
               '-File', WORKER, '-InputPath', source, '-FFmpegPath', FFMPEG, *extra, check=check)


def stamp(source):
    script = "$f=Get-Item -LiteralPath '" + str(source).replace("'", "''") + "'; $f.LastWriteTimeUtc.ToString('o'); $f.Length"
    return run('powershell.exe', '-NoProfile', '-Command', script).stdout.decode().splitlines()


def digest(path):
    return hashlib.sha256(path.read_bytes()).digest()


def main():
    with tempfile.TemporaryDirectory(prefix='gamehelper-mp4-') as folder:
        folder = Path(folder)
        source = folder / "中文 & 空格 % ' [test].avi"
        run(FFMPEG, '-v', 'error', '-f', 'lavfi', '-i', 'testsrc=size=65x49:rate=24',
            '-f', 'lavfi', '-i', 'sine=frequency=440:sample_rate=48000',
            '-t', '1', '-c:v', 'ffv1', '-pix_fmt', 'bgr0', '-c:a', 'pcm_s16le', source)
        original = digest(source)
        output = source.with_suffix('.mp4')
        before = stamp(source)
        convert(source, previous=before)
        assert not output.exists(), 'Skip an old AVI when rendering wrote no new output'
        # Simulate an AVI writer updating the file, without any per-frame callback.
        import os
        os.utime(source, (source.stat().st_atime, source.stat().st_mtime + 2))
        convert(source, previous=before, encoded=True)
        assert output.is_file() and digest(source) == original, 'Keep the original AVI'
        # Decode the real MP4: all frames, frame rate, padded dimensions and audio.
        decoded = run(FFMPEG, '-v', 'error', '-i', output, '-map', '0:v:0', '-f', 'framemd5', '-')
        lines = decoded.stdout.decode().splitlines()
        assert '#dimensions 0: 66x50' in lines and '#tb 0: 1/24' in lines
        assert len([line for line in lines if not line.startswith('#')]) == 24
        audio = run(FFMPEG, '-v', 'error', '-i', output, '-map', '0:a:0', '-f', 's16le', '-')
        assert len(audio.stdout) > 90000, 'Preserve audio'
        first_mp4 = digest(output)
        convert(source)
        assert output.with_stem(output.stem + '_001').is_file()
        assert digest(output) == first_mp4, 'Never overwrite an existing MP4'
        silent = folder / 'silent.avi'
        run(FFMPEG, '-v', 'error', '-f', 'lavfi', '-i', 'color=size=64x48:rate=30',
            '-t', '0.2', '-c:v', 'ffv1', silent)
        convert(silent)
        assert silent.with_suffix('.mp4').is_file(), 'Support AVI without audio'
        broken = folder / 'broken.avi'
        broken.write_bytes(b'not an AVI')
        assert convert(broken, check=False).returncode != 0
        assert broken.read_bytes() == b'not an AVI' and not broken.with_suffix('.mp4').exists()
        assert Path(str(broken) + '.mp4.log').is_file(), 'Keep failure details'
        assert not list(folder.glob('*.partial.mp4')), 'Remove failed intermediate files'
    print('PASS: unchanged AVI skipped, changed AVI encoded without frame events, encoded-command launch, '
          'real AVI conversion, Unicode/special paths, 24 frames, FPS, odd dimensions, '
          'audio/silent AVI, original retention, MP4 conflicts, corrupt input and cleanup')


if __name__ == '__main__':
    main()
