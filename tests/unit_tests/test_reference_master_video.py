"""Decode real short videos without opening Max or changing the system clipboard."""
from pathlib import Path
import subprocess
import tempfile

from test_reference_master_multiview import CORE, CSC, ROOT, STUB, extract, run_exe

FFMPEG = ROOT / '.local/refplayer/ffmpeg.exe'
HARNESS = r'''
class VideoTest
{
    [System.Runtime.InteropServices.DllImport("kernel32.dll")]
    static extern uint SetErrorMode(uint mode);
    static void Check(bool ok, string message) { if (!ok) throw new System.Exception(message); }
    [System.STAThread]
    static int Main(string[] args)
    {
        SetErrorMode(2);
        try { Run(args); return 0; }
        catch (System.Exception error) { System.Console.Error.WriteLine(error); return 1; }
    }
    static void Run(string[] args)
    {
        string exe = args[0], input = args[1], root = args[2];
        Check(RefPlayer.VideoImportJob.IsVideoFile(input) && RefPlayer.VideoImportJob.IsVideoFile("a.MOV") && !RefPlayer.VideoImportJob.IsVideoFile("a.png"), "Video type detection");
        string a, b;
        using (var job = new RefPlayer.VideoImportJob(exe, input, root, 24)) a = job.Finish();
        using (var job = new RefPlayer.VideoImportJob(exe, input, root, 30)) b = job.Finish();
        Check(System.IO.Directory.GetFiles(a, "*.jpg").Length == 24 && System.IO.Directory.GetFiles(b, "*.jpg").Length == 30, "Preserve a one-second duration at different scene frame rates");
        Check(RefPlayer.VideoImportJob.CachedFps(a) == 24 && RefPlayer.VideoImportJob.CachedFps(b) == 30, "Remember cache frame rate when reopening from history");
        using (var first = new System.Drawing.Bitmap(System.IO.Path.Combine(b, "video_00000000.jpg")))
        using (var last = new System.Drawing.Bitmap(System.IO.Path.Combine(b, "video_00000029.jpg")))
            Check(first.Width == 64 && last.Height == 48, "Extract first and last video frames at original dimensions");
        string cancelled;
        using (var job = new RefPlayer.VideoImportJob(exe, input, root, 30))
        { cancelled = job.Folder; job.Cancel(); }
        Check(!System.IO.Directory.Exists(cancelled), "Cancellation removes incomplete frame cache");
        int before = System.IO.Directory.GetDirectories(root).Length;
        string broken = System.IO.Path.Combine(root, "broken.mp4");
        System.IO.File.WriteAllText(broken, "not a movie");
        bool failed = false;
        try { using (var job = new RefPlayer.VideoImportJob(exe, broken, root, 30)) job.Finish(); }
        catch (System.InvalidOperationException) { failed = true; }
        Check(failed && System.IO.Directory.GetDirectories(root).Length == before, "Bad videos report failure and leave no partial cache");
        using (var view = new RefPlayer.PlayerForm())
        {
            view.JoinGroup(); view.ReferenceFolder = b;
            var cleaned = view.ClearClipboardCache(root);
            Check(cleaned.Deleted == 1 && cleaned.InUse == 1 && !System.IO.Directory.Exists(a) && System.IO.Directory.Exists(b), "Remove unused video cache while keeping an active reference");
            System.IO.File.WriteAllText(System.IO.Path.Combine(b, "personal.txt"), "keep");
            view.ReferenceFolder = null;
            Check(view.ClearClipboardCache(root).Deleted == 0 && System.IO.Directory.Exists(b), "Skip cache folders containing unrelated files");
        }
        Check(System.IO.File.Exists(input), "Keep the original video");
        System.Console.WriteLine("PASS: actual MP4 decoding, 24/30fps duration, Unicode/space/percent paths, history metadata, cancellation, invalid videos, cache cleanup");
    }
}
'''


def main():
    assert FFMPEG.is_file(), 'Install the local FFmpeg executable described in docs/REFERENCE_VIDEO.md'
    script = CORE.read_text(encoding='utf-8-sig')
    assert 'VideoTool.IsVideoFile file' in script and 'RP_ImportVideo file' in script
    assert 'ui_PlayerWindow.ImportVideo executable file ClipboardCacheRoot frameRate' in script
    assert 'VideoTool.CachedFps thepath' in script
    with tempfile.TemporaryDirectory(prefix='refplayer-video-') as temp:
        temp = Path(temp)
        video = temp / '参考 video & sample.mp4'
        subprocess.run([str(FFMPEG), '-nostdin', '-hide_banner', '-loglevel', 'error', '-f', 'lavfi',
                        '-i', 'testsrc2=size=64x48:rate=24', '-t', '1', '-c:v', 'libx264', '-pix_fmt', 'yuv420p', str(video)], check=True, timeout=30)
        cache = temp / '缓存 % folder'
        cs = temp / 'video.cs'
        cs.write_text(extract(script, 'PlayerForm') + STUB + HARNESS, encoding='utf-8-sig')
        exe = temp / 'video.exe'
        subprocess.run([str(CSC), '/nologo', f'/out:{exe}', '/reference:System.Windows.Forms.dll',
                        '/reference:System.Drawing.dll', str(cs)], check=True)
        run_exe([str(exe), str(FFMPEG), str(video), str(cache)])


if __name__ == '__main__':
    main()
