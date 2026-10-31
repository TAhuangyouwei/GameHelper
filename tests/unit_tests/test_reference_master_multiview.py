"""Validate shared original-window code and grouping without starting Max.

Run on Windows: python tests/unit_tests/test_reference_master_multiview.py
Max UI/menu/frame loading still requires an in-Max integration check.
"""
from pathlib import Path
import os
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
ENTRY = ROOT / 'scripts/实用工具/动画/参考大师v1.06.ms'
CORE = ENTRY.with_name('参考大师_窗口.ms')
CSC = Path(os.environ['WINDIR']) / 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
STUB = 'namespace MaxCustomControls { public class MaxForm : System.Windows.Forms.Form {} }'

HARNESS = r'''
class CornerProbe : RefPlayer.PlayerForm
{
    public int Hit(System.Drawing.Point point)
    {
        return (int)typeof(RefPlayer.PlayerForm).GetMethod("HitTestCorner", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic).Invoke(this, new object[] { point });
    }
    public System.Drawing.Rectangle DragBounds(System.Drawing.Rectangle start, System.Drawing.Point delta, int corner)
    {
        return (System.Drawing.Rectangle)typeof(RefPlayer.PlayerForm).GetMethod("CornerBounds", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic).Invoke(this, new object[] { start, delta, corner });
    }
    public void MoveAt(System.Drawing.Point point) { base.OnMouseMove(new System.Windows.Forms.MouseEventArgs(System.Windows.Forms.MouseButtons.None, 0, point.X, point.Y, 0)); }
    public void DoubleAt(System.Drawing.Point point) { base.OnMouseDoubleClick(new System.Windows.Forms.MouseEventArgs(System.Windows.Forms.MouseButtons.Left, 2, point.X, point.Y, 0)); }
    public bool Command(System.Windows.Forms.Keys keys)
    {
        var message = new System.Windows.Forms.Message();
        return base.ProcessCmdKey(ref message, keys);
    }
    public void NativePaste()
    {
        var message = System.Windows.Forms.Message.Create(System.IntPtr.Zero, 0x0312, (System.IntPtr)0x5250, System.IntPtr.Zero);
        base.WndProc(ref message);
    }
}
class Test
{
    [System.Runtime.InteropServices.DllImport("kernel32.dll")]
    static extern uint SetErrorMode(uint mode);
    static void Check(bool value, string message) { if (!value) throw new System.Exception(message); }
    [System.STAThread]
    static void Main(string[] args)
    {
        SetErrorMode(2);
        try { Run(); if (args.Length > 0) CheckExternalSparseFolder(args[0]); }
        catch (System.Exception error)
        {
            System.Console.Error.WriteLine(error.GetType().FullName + ": " + error.Message);
            System.Console.Error.WriteLine(error.StackTrace);
            System.Environment.Exit(1);
        }
    }
    static void Run()
    {
        System.Windows.Forms.Application.SetUnhandledExceptionMode(System.Windows.Forms.UnhandledExceptionMode.ThrowException);
        using (var first = new RefPlayer.PlayerForm())
        using (var second = new RefPlayer.PlayerForm())
        {
            first.FormBorderStyle = second.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            first.StartPosition = second.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            first.Size = second.Size = new System.Drawing.Size(420, 240);
            first.Location = new System.Drawing.Point(100, 100);
            second.PlaceBeside(first);
            first.JoinGroup();
            second.JoinGroup();
            Check(first.LinkedMovement, "Movement and resize are linked by default");
            first.LinkedMovement = false;
            Check(first.ViewCount == 2, "Two full player instances join one group");
            Check(first.Controls.Count == 0 && second.Controls.Count == 0, "No extra toolbar or replacement UI");
            Check(first.FormBorderStyle == second.FormBorderStyle, "Identical frameless windows");
            var firstPosition = first.Location;
            second.Location = new System.Drawing.Point(second.Left + 25, second.Top + 10);
            Check(first.Location == firstPosition, "Independent movement");
            var secondPosition = second.Location;
            first.LinkedMovement = true;
            Check(second.LinkedMovement, "Shared link state in each middle-click menu");
            first.Location = new System.Drawing.Point(first.Left + 30, first.Top + 15);
            Check(second.Left == secondPosition.X + 30 && second.Top == secondPosition.Y + 15, "Move the first window with group");
            firstPosition = first.Location;
            second.Location = new System.Drawing.Point(second.Left - 12, second.Top + 20);
            Check(first.Left == firstPosition.X - 12 && first.Top == firstPosition.Y + 20, "Move another window with group without recursion");
            firstPosition = first.Location;
            secondPosition = second.Location;
            using (var third = new RefPlayer.PlayerForm())
            {
                third.PlaceBeside(second);
                third.JoinGroup();
                Check(first.Location == firstPosition && second.Location == secondPosition, "Adding a linked window preserves existing positions");
                Check(third.ViewCount == 3 && third.LinkedMovement, "More views use the same group and link setting");
                var thirdPosition = third.Location;
                first.Location = new System.Drawing.Point(first.Left + 8, first.Top - 5);
                Check(third.Left == thirdPosition.X + 8 && third.Top == thirdPosition.Y - 5, "All three windows move together");
                third.LinkedMovement = false;
                Check(!first.LinkedMovement && !second.LinkedMovement, "Unlink from any window");
                firstPosition = first.Location;
                third.Location = new System.Drawing.Point(-20, 600);
                Check(first.Location == firstPosition, "Place a view freely after unlinking");
                var thirdBounds = third.Bounds;
                var firstBounds = first.Bounds;
                second.Size = new System.Drawing.Size(800, 450);
                Check(first.Bounds == firstBounds && third.Bounds == thirdBounds, "Each image window adapts its size independently");
                second.Close();
                Check(first.ViewCount == 2 && !first.IsDisposed && !third.IsDisposed, "Closing any window leaves other views open");
            }
            Check(first.ViewCount == 1, "Disposed views leave the movement group");
        }
        using (var next = new RefPlayer.PlayerForm())
            Check(next.ViewCount == 0, "Closing the final view releases the group");
        CheckResizeLinks();
        CheckCornerResize();
        CheckBatchLayout();
        CheckSharedSettings();
        CheckUnifySizes();
        CheckClipboardPaste();
        CheckPoseTrack();
        CheckCacheCleanup();
        CheckSparseFolder();
        System.Console.WriteLine("PASS: identical window type, no overlay UI, independent/linked movement, resize, per-window close, cleanup");
    }

    static void CheckSparseFolder()
    {
        string root = System.IO.Path.Combine(System.IO.Path.GetTempPath(), "refplayer-sparse-test-" + System.Guid.NewGuid().ToString("N"));
        System.IO.Directory.CreateDirectory(root);
        try
        {
            using (var poses = new RefPlayer.PoseTrack())
            {
                foreach (int frame in new int[] { 135, 1, 11, 6 })
                    System.IO.File.WriteAllText(System.IO.Path.Combine(root, "snapshot." + frame.ToString("D4") + ".png"), "fixture");
                Check(poses.TryLoadSparseFolder(root) && poses.Count == 4, "Detect numeric gaps in an imported folder");
                Check(poses.FrameAt(0) == 1 && poses.FrameAt(1) == 6 && poses.FrameAt(2) == 11 && poses.FrameAt(3) == 135, "Use exact original file frame numbers");
                Check(poses.IndexAt(5) == 0 && poses.IndexAt(6) == 1 && poses.IndexAt(134) == 2, "Hold references throughout the missing frame intervals");
                Check(poses.SetStartFrame(20) && poses.FrameAt(1) == 25 && poses.FrameAt(2) == 30 && poses.FrameAt(3) == 154, "Position the first image and shift all keys while preserving gaps");
                Check(poses.SetStartFrame(-10) && poses.FrameAt(0) == -10 && poses.FrameAt(3) == 124, "Allow a negative first frame");
                Check(!poses.SetStartFrame(System.Int32.MaxValue) && poses.FrameAt(0) == -10, "Reject an overflowing shift without losing keys");
                System.IO.File.WriteAllText(System.IO.Path.Combine(root, "other.0040.jpg"), "fixture");
                Check(!poses.TryLoadSparseFolder(root) && poses.FrameAt(0) == -10, "Mixed name prefixes leave the existing track intact");
            }
            string dense = System.IO.Path.Combine(root, "dense");
            System.IO.Directory.CreateDirectory(dense);
            foreach (int frame in new int[] { 1, 2, 3 })
                System.IO.File.WriteAllText(System.IO.Path.Combine(dense, "shot" + frame + ".png"), "fixture");
            using (var poses = new RefPlayer.PoseTrack())
            {
                Check(!poses.TryLoadSparseFolder(dense) && poses.Count == 0, "Keep dense image sequences on their existing playback path");
                System.IO.File.WriteAllText(System.IO.Path.Combine(dense, "shot1.jpg"), "duplicate");
                Check(!poses.TryLoadSparseFolder(dense), "Duplicate frame numbers are not silently merged");
            }
        }
        finally { System.IO.Directory.Delete(root, true); }
        System.Console.WriteLine("PASS: sparse numbered-folder import, exact file frames, hold intervals, first-frame alignment, dense/mixed/duplicate isolation");
    }

    static void CheckExternalSparseFolder(string folder)
    {
        using (var poses = new RefPlayer.PoseTrack())
        {
            Check(poses.TryLoadSparseFolder(folder), "The supplied image folder must import as sparse keys");
            for (int i = 0; i < poses.Count; i++)
            {
                int frame = poses.FrameAt(i);
                var image = poses.ImageAt(frame);
                Check(image != null && image.Width > 0 && image.Height > 0, "Each actual pose image decodes");
                Check(poses.IndexAt(frame) == i, "Actual frame switches happen exactly at each key");
                if (i + 1 < poses.Count) Check(poses.IndexAt(poses.FrameAt(i + 1) - 1) == i, "Hold each actual pose until the next key");
            }
            int lastGap = poses.FrameAt(poses.Count - 1) - poses.FrameAt(0);
            Check(poses.SetStartFrame(20) && poses.FrameAt(poses.Count - 1) == 20 + lastGap, "Actual imported poses keep their rhythm after first-frame alignment");
            System.Console.WriteLine("PASS: supplied folder: " + poses.Count + " image keys decode and hold correctly; first-frame shift preserves " + lastGap + " frames");
        }
    }

    static void CheckCacheCleanup()
    {
        string root = System.IO.Path.Combine(System.IO.Path.GetTempPath(), "refplayer-cleanup-test-" + System.Guid.NewGuid().ToString("N"));
        using (var first = new RefPlayer.PlayerForm())
        using (var second = new RefPlayer.PlayerForm())
        using (var image = new System.Drawing.Bitmap(8, 8))
        {
            first.JoinGroup(); second.JoinGroup();
            Check(first.ClearClipboardCache(root).Deleted == 0 && !System.IO.Directory.Exists(root), "Cleaning an absent cache creates nothing");
            try
            {
                var data = new System.Windows.Forms.DataObject(System.Windows.Forms.DataFormats.Bitmap, image);
                string a = RefPlayer.PlayerForm.CacheClipboardImage(data, root);
                string b = RefPlayer.PlayerForm.CacheClipboardImage(data, root);
                string reference = RefPlayer.PlayerForm.CacheClipboardImage(data, root);
                string unused = RefPlayer.PlayerForm.CacheClipboardImage(data, root);
                first.Poses.Set(0, System.IO.Path.Combine(a, "clipboard.png").ToUpperInvariant());
                second.Poses.Set(30, System.IO.Path.Combine(b, "clipboard.png"));
                first.ReferenceFolder = reference + System.IO.Path.DirectorySeparatorChar;
                string unrelated = System.IO.Path.Combine(root, "my-images");
                System.IO.Directory.CreateDirectory(unrelated);
                image.Save(System.IO.Path.Combine(unrelated, "clipboard.png"));
                string extra = RefPlayer.PlayerForm.CacheClipboardImage(data, root);
                System.IO.File.WriteAllText(System.IO.Path.Combine(extra, "user-notes.txt"), "keep");
                string rootFile = System.IO.Path.Combine(root, "personal.png");
                image.Save(rootFile);
                var result = first.ClearClipboardCache(root);
                Check(result.Deleted == 1 && result.InUse == 3 && result.Failed == 0 && !System.IO.Directory.Exists(unused), "Delete unused caches and protect every active reference/pose window");
                Check(System.IO.File.Exists(rootFile) && System.IO.Directory.Exists(extra) && System.IO.Directory.Exists(unrelated), "A custom directory keeps unrelated files and folders");
                second.Dispose();
                result = first.ClearClipboardCache(root);
                Check(result.Deleted == 1 && result.InUse == 2 && !System.IO.Directory.Exists(b), "A closed window's cache becomes removable");
                first.Poses.Clear(); first.ReferenceFolder = null;
                result = first.ClearClipboardCache(root);
                Check(result.Deleted == 2 && result.InUse == 0, "Released pose and sequence references can be cleaned");
                string locked = RefPlayer.PlayerForm.CacheClipboardImage(data, root);
                string lockedFile = System.IO.Path.Combine(locked, "clipboard.png");
                System.IO.File.SetAttributes(lockedFile, System.IO.FileAttributes.ReadOnly);
                try
                {
                    result = first.ClearClipboardCache(root);
                    Check(result.Failed == 1 && System.IO.File.Exists(lockedFile), "Report files that cannot be deleted");
                }
                finally { System.IO.File.SetAttributes(lockedFile, System.IO.FileAttributes.Normal); }
            }
            finally { if (System.IO.Directory.Exists(root)) System.IO.Directory.Delete(root, true); }
        }
        System.Console.WriteLine("PASS: unused-cache cleanup, active references across windows, custom-folder file protection, closed views, deletion failures");
    }

    static void CheckPoseTrack()
    {
        using (var first = new RefPlayer.PlayerForm())
        using (var second = new RefPlayer.PlayerForm())
        {
            first.Poses.Set(0, "idle");
            second.Poses.Set(10, "attack");
            Check(first.Poses.FrameAt(0) == 0 && second.Poses.FrameAt(0) == 10, "Each reference view has an independent pose track");
            first.Dispose();
            Check(first.Poses.Count == 0 && second.Poses.Count == 1, "Closing one pose view clears only its own track");
        }
        using (var poses = new RefPlayer.PoseTrack())
        {
            Check(poses.IndexAt(0) == -1 && poses.ImageAt(0) == null, "An empty pose track is safe");
            poses.Set(30, "idle-end"); poses.Set(0, "idle"); poses.Set(16, "recover"); poses.Set(5, "charge"); poses.Set(10, "attack");
            int[] frames = { 0, 5, 10, 16, 30 };
            for (int i = 0; i < frames.Length; i++) Check(poses.FrameAt(i) == frames[i], "Sort sparse pose keys by frame");
            for (int frame = -2; frame <= 33; frame++)
            {
                int expected = frame >= 30 ? 4 : frame >= 16 ? 3 : frame >= 10 ? 2 : frame >= 5 ? 1 : 0;
                Check(poses.IndexAt(frame) == expected, "Hold each pose until the next key, including before/after the sequence");
            }
            poses.Set(10, "new-attack");
            Check(poses.Count == 5, "Pasting at an existing key replaces it");
            Check(poses.Move(10, 12) && poses.IndexAt(10) == 1 && poses.IndexAt(12) == 2, "Moving a pose immediately changes playback rhythm");
            Check(!poses.Move(12, 16) && poses.Count == 5 && poses.FrameAt(2) == 12, "Reject collisions without losing either pose");
            Check(poses.Move(12, 12), "Moving a key to its own frame is safe");
            Check(poses.Move(5, -5) && poses.FrameAt(0) == -5, "Keys can cross other keys and use negative frames");
            poses.Remove(16);
            Check(poses.Count == 4 && poses.IndexAt(20) == 2, "Deleting a key extends the preceding pose hold");
            poses.Clear();
            Check(poses.Count == 0 && poses.ImageAt(30) == null, "Clearing a track releases its state");
        }
        System.Console.WriteLine("PASS: 0/5/10/16/30 sparse poses, hold playback, replacement, editable timing, collision protection, deletion");
    }

    static void CheckClipboardPaste()
    {
        using (var first = new CornerProbe())
        using (var second = new CornerProbe())
        {
            int a = 0, b = 0;
            first.PasteRequested += delegate { a++; };
            second.PasteRequested += delegate { b++; };
            var paste = System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.V;
            Check(second.Command(paste) && a == 0 && b == 1, "Ctrl+V targets only the selected empty reference window");
            first.HasSequence = true;
            Check(first.Command(paste) && a == 1, "Ctrl+V also works after a sequence is loaded");
            first.Command(System.Windows.Forms.Keys.V);
            first.Command(paste | System.Windows.Forms.Keys.Shift);
            first.clickThrough = true;
            first.Command(paste);
            first.clickThrough = false;
            first.SuspendLinkedResize = true;
            first.Command(paste);
            Check(a == 1, "Plain keys, other modifiers, locked and minimized windows do not paste");
            first.SuspendLinkedResize = false;
            first.NativePaste();
            Check(a == 2 && b == 1, "Native Ctrl+V delivery bypasses Max key accelerators without duplicating another view");
        }
        string root = System.IO.Path.Combine(System.IO.Path.GetTempPath(), "refplayer-paste-test-" + System.Guid.NewGuid().ToString("N"));
        string cache = System.IO.Path.Combine(root, "cache");
        try
        {
            var text = new System.Windows.Forms.DataObject(System.Windows.Forms.DataFormats.Text, "text only");
            Check(RefPlayer.PlayerForm.CacheClipboardImage(text, cache) == null && !System.IO.Directory.Exists(cache), "Non-image data changes no files");
            using (var image = new System.Drawing.Bitmap(64, 32))
            {
                image.SetPixel(10, 5, System.Drawing.Color.FromArgb(128, 200, 100, 50));
                var data = new System.Windows.Forms.DataObject(System.Windows.Forms.DataFormats.Bitmap, image);
                string one = RefPlayer.PlayerForm.CacheClipboardImage(data, cache);
                string two = RefPlayer.PlayerForm.CacheClipboardImage(data, cache);
                Check(one != two && System.IO.Directory.GetFiles(one).Length == 1 && System.IO.Directory.GetFiles(two).Length == 1,
                    "Each paste is isolated as a single frame, with no accidental sequence merging");
                using (var loaded = new System.Drawing.Bitmap(System.IO.Path.Combine(one, "clipboard.png")))
                {
                    Check(loaded.Width == 64 && loaded.Height == 32, "Pasting preserves image dimensions");
                    Check(loaded.GetPixel(10, 5).ToArgb() == image.GetPixel(10, 5).ToArgb(), "PNG cache preserves pixel color and transparency");
                }
                using (var poses = new RefPlayer.PoseTrack())
                {
                    poses.Set(0, System.IO.Path.Combine(one, "clipboard.png"));
                    var shown = poses.ImageAt(0);
                    Check(shown.Size == image.Size && object.ReferenceEquals(shown, poses.ImageAt(4)), "Pose playback reuses the held image");
                    poses.Set(5, System.IO.Path.Combine(two, "clipboard.png"));
                    Check(poses.ImageAt(5).Size == image.Size, "Pose image switching loads the next key");
                    poses.Clear();
                    Check(poses.ImageAt(0) == null, "Image cache clears with the track");
                }
                string original = System.IO.Path.Combine(root, "original.png");
                image.Save(original, System.Drawing.Imaging.ImageFormat.Png);
                var files = new System.Windows.Forms.DataObject(System.Windows.Forms.DataFormats.FileDrop, new string[] { original });
                string folder = RefPlayer.PlayerForm.CacheClipboardImage(files, cache);
                using (var copied = new System.Drawing.Bitmap(System.IO.Path.Combine(folder, "clipboard.png")))
                    Check(copied.Size == image.Size, "Explorer-copied image files paste as a single image");
                System.IO.File.Delete(original);
                Check(System.IO.File.Exists(System.IO.Path.Combine(folder, "clipboard.png")), "The reference keeps its own copy and releases the source file");
            }
        }
        finally { if (System.IO.Directory.Exists(root)) System.IO.Directory.Delete(root, true); }
        System.Console.WriteLine("PASS: per-view Ctrl+V, empty/loaded windows, image/file clipboard formats, PNG pixels, isolated caches, no system clipboard writes");
    }

    static void CheckSharedSettings()
    {
        using (var first = new RefPlayer.PlayerForm())
        using (var second = new RefPlayer.PlayerForm())
        using (var closed = new RefPlayer.PlayerForm())
        {
            first.JoinGroup(); second.JoinGroup(); closed.JoinGroup();
            first.LinkedMovement = false;
            string received = null;
            int self = 0, updates = 0, stale = 0;
            first.SharedSettingsChanged += delegate { self++; };
            second.SharedSettingsChanged += delegate(object sender, System.ComponentModel.PropertyChangedEventArgs args)
            {
                Check(sender == second, "Settings events belong to the receiving view");
                received = args.PropertyName;
                updates++;
            };
            closed.SharedSettingsChanged += delegate { stale++; };
            closed.Dispose();
            foreach (string category in new[] { "GridSetting", "RAMSetting", "RecordSetting", "DisplaySetting", "CacheSetting" })
            {
                first.BroadcastSettings(category);
                Check(received == category, "All shared categories reach other windows while movement is unlinked");
            }
            Check(updates == 5 && self == 0 && stale == 0, "Settings do not echo to the source or reach closed windows");
            second.BroadcastSettings("GridSetting");
            Check(self == 1 && updates == 5, "Settings can be changed from either window");
        }
        System.Console.WriteLine("PASS: immediate shared-setting notifications, independent movement, per-category updates, closed-window cleanup");
    }

    static void CheckUnifySizes()
    {
        using (var first = new RefPlayer.PlayerForm())
        using (var second = new RefPlayer.PlayerForm())
        using (var third = new RefPlayer.PlayerForm())
        using (var below = new RefPlayer.PlayerForm())
        {
            first.LinkedMovement = false;
            var group = new[] { first, second, third, below };
            foreach (var view in group)
            {
                view.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
                view.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
                view.JoinGroup();
            }
            first.Bounds = new System.Drawing.Rectangle(100, 100, 400, 300);
            second.Bounds = new System.Drawing.Rectangle(512, 100, 200, 160);
            third.Bounds = new System.Drawing.Rectangle(724, 100, 600, 500);
            below.Bounds = new System.Drawing.Rectangle(100, 412, 250, 200);
            foreach (var view in group) { var handle = view.Handle; }
            int updates = 0;
            second.LinkedResized += delegate { updates++; };
            int partialLayouts = 0;
            foreach (var view in group) view.Layout += delegate
            {
                foreach (var peer in group) if (peer.Size != first.Size) { partialLayouts++; break; }
            };
            var firstBounds = first.Bounds;
            third.UnifySizesToFirst();
            Check(partialLayouts == 0, "All real windows reach equal sizes before layout callbacks run");
            foreach (var view in group) Check(view.Size == first.Size, "Unify from any middle menu always uses the first view");
            Check(first.Bounds == firstBounds && !first.LinkedMovement, "Keep first-view bounds and the manual unlink setting");
            Check(second.Left - first.Right == 12 && third.Left - second.Right == 12 && below.Top - first.Bottom == 12,
                "Keep horizontal and vertical edge gaps after equalizing different sizes");
            Check(updates == 1, "Refresh the resized reference display state");
            var unchanged = third.Bounds;
            second.UnifySizesToFirst();
            Check(third.Bounds == unchanged && updates == 1, "Repeated equalization is stable");
            second.Size = new System.Drawing.Size(300, 200);
            second.SuspendLinkedResize = true;
            first.LinkedMovement = true;
            var folded = second.Bounds;
            below.UnifySizesToFirst();
            Check(second.Bounds == folded && first.LinkedMovement, "Leave minimized windows and the link setting unchanged");
            second.SuspendLinkedResize = false;
            third.UnifySizesToFirst();
            Check(second.Size == first.Size && first.Bounds == firstBounds, "Unify while linked without scaling the leader");
            first.SuspendLinkedResize = true;
            Check(!third.CanUnifySizes, "Disable equalization while the first view is minimized");
            var before = third.Bounds;
            third.UnifySizesToFirst();
            Check(third.Bounds == before, "A minimized leader cannot spread its folded size");
        }
        System.Console.WriteLine("PASS: one-click first-view dimensions, 4-view spacing, linked/unlinked operation, repeated use, minimized-window isolation");
    }

    static void CheckResizeLinks()
    {
        using (var first = new RefPlayer.PlayerForm())
        using (var second = new RefPlayer.PlayerForm())
        using (var third = new RefPlayer.PlayerForm())
        using (var below = new RefPlayer.PlayerForm())
        {
            first.LinkedMovement = false;
            foreach (var view in new RefPlayer.PlayerForm[] { first, second, third, below })
            {
                view.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
                view.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            }
            first.Bounds = new System.Drawing.Rectangle(100, 100, 400, 300);
            second.Bounds = new System.Drawing.Rectangle(512, 100, 200, 160);
            first.JoinGroup();
            second.JoinGroup();
            first.HasSequence = second.HasSequence = true;
            first.LinkedMovement = true;
            Check(second.MatchLinkedSize() && second.Size == first.Size, "A newly loaded reference matches the existing window size");
            Check(first.Size == new System.Drawing.Size(400, 300) && second.Left - first.Right == 12, "Matching does not resize the reference window or change its gap");
            first.LinkedMovement = false;
            first.Bounds = new System.Drawing.Rectangle(100, 100, 200, 120);
            second.Bounds = new System.Drawing.Rectangle(312, 100, 200, 120);
            third.Bounds = new System.Drawing.Rectangle(524, 100, 200, 120);
            below.Bounds = new System.Drawing.Rectangle(100, 232, 200, 120);
            third.JoinGroup();
            below.JoinGroup();
            int refreshes = 0;
            second.LinkedResized += delegate { refreshes++; };
            first.LinkedMovement = true;
            first.Size = new System.Drawing.Size(400, 240);
            Check(second.Size == first.Size && third.Size == first.Size && below.Size == first.Size, "Resize all linked windows");
            Check(second.Left - first.Right == 12 && third.Left - second.Right == 12 && below.Top - first.Bottom == 12, "Preserve horizontal and vertical edge gaps across several windows");
            Check(second.Top == first.Top && below.Left == first.Left && refreshes > 0, "Preserve alignment and refresh linked display state");
            second.Size = new System.Drawing.Size(300, 180);
            Check(first.Size == second.Size && third.Size == second.Size && below.Size == second.Size, "Resize from a middle window");
            Check(second.Left - first.Right == 12 && third.Left - second.Right == 12 && below.Top - first.Bottom == 12, "Preserve gaps when the middle view changes size");
            first.Size = new System.Drawing.Size(200, 120);
            Check(second.Left - first.Right == 12 && third.Left - second.Right == 12, "Shrink without accumulating spacing errors");
            var secondBounds = second.Bounds;
            first.SuspendLinkedResize = true;
            var originalSize = first.Size;
            first.Size = new System.Drawing.Size(40, 52);
            first.Size = originalSize;
            first.SuspendLinkedResize = false;
            Check(second.Bounds == secondBounds, "Minimize and restore do not shrink the whole group");
            first.LinkedMovement = false;
            var firstBounds = first.Bounds;
            var thirdBounds = third.Bounds;
            second.Size = new System.Drawing.Size(700, 400);
            Check(first.Bounds == firstBounds && third.Bounds == thirdBounds && !second.MatchLinkedSize(), "Manual unlink restores independent resize and image fitting");
        }
        System.Console.WriteLine("PASS: same-size loading, resize linkage, multi-view edge spacing, middle-window scaling, minimize isolation, manual unlink");
    }

    static void CheckCornerResize()
    {
        using (var window = new CornerProbe())
        using (var peer = new RefPlayer.PlayerForm())
        {
            window.StartPosition = peer.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            window.FormBorderStyle = peer.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            window.Bounds = new System.Drawing.Rectangle(100, 100, 400, 300);
            peer.Bounds = new System.Drawing.Rectangle(512, 100, 400, 300);
            window.JoinGroup();
            peer.JoinGroup();
            window.LinkedMovement = false;
            window.ConfigureCornerResize(10, 135, 135);
            var points = new System.Drawing.Point[] { new System.Drawing.Point(1, 1), new System.Drawing.Point(398, 1), new System.Drawing.Point(1, 298), new System.Drawing.Point(398, 298) };
            for (int i = 0; i < 4; i++)
            {
                Check(window.Hit(points[i]) == i + 1, "Detect all four corners");
                window.MoveAt(points[i]);
                Check(window.Cursor == (i == 0 || i == 3 ? System.Windows.Forms.Cursors.SizeNWSE : System.Windows.Forms.Cursors.SizeNESW), "Show the matching diagonal resize cursor");
            }
            window.MoveAt(new System.Drawing.Point(200, 150));
            Check(window.Hit(new System.Drawing.Point(200, 150)) == 0 && window.Cursor == System.Windows.Forms.Cursors.Default, "Keep ordinary body dragging outside the corners");
            Check(window.Hit(new System.Drawing.Point(-1, 0)) == 0 && window.Hit(new System.Drawing.Point(400, 300)) == 0, "Do not resize from outside the window");
            int doubles = 0;
            window.MouseDoubleClick += delegate { doubles++; };
            window.DoubleAt(points[3]);
            window.DoubleAt(new System.Drawing.Point(200, 150));
            Check(doubles == 1, "Corner double-click does not invoke the old close action");
            var start = window.Bounds;
            var deltas = new System.Drawing.Point[] { new System.Drawing.Point(-80, -60), new System.Drawing.Point(80, -60), new System.Drawing.Point(-80, 60), new System.Drawing.Point(80, 60) };
            for (int i = 0; i < 4; i++)
            {
                var bounds = window.DragBounds(start, deltas[i], i + 1);
                Check(bounds.Size == new System.Drawing.Size(480, 360), "Resize proportionally from each corner");
                Check((i == 0 || i == 2 ? bounds.Right == start.Right : bounds.Left == start.Left) &&
                      (i < 2 ? bounds.Bottom == start.Bottom : bounds.Top == start.Top), "Keep the opposite corner anchored");
            }
            var minimum = window.DragBounds(start, new System.Drawing.Point(-10000, -10000), 4);
            Check(minimum.Width >= 135 && minimum.Height >= 135 && minimum.Width * 3 == minimum.Height * 4, "Respect minimum dimensions and image ratio");
            window.LinkedMovement = true;
            window.Bounds = window.DragBounds(start, deltas[3], 4);
            Check(peer.Size == window.Size && peer.Left - window.Right == 12, "Corner resizing keeps linked sizes and spacing");
            window.LinkedMovement = false;
            var peerBounds = peer.Bounds;
            window.Bounds = window.DragBounds(window.Bounds, new System.Drawing.Point(40, 30), 4);
            Check(peer.Bounds == peerBounds, "Corner resizing can be detached");
            window.clickThrough = true;
            Check(window.Hit(new System.Drawing.Point(1, 1)) == 0, "Disable corner resizing while locked");
            window.clickThrough = false;
            window.SuspendLinkedResize = true;
            Check(window.Hit(new System.Drawing.Point(1, 1)) == 0, "Disable corner resizing while minimized");
            window.SuspendLinkedResize = false;
            window.ConfigureCornerResize(20, 135, 135);
            Check(window.Hit(new System.Drawing.Point(15, 15)) == 1, "Scale the corner grip for high DPI");
        }
        System.Console.WriteLine("PASS: four corner grips/cursors, proportional resizing, anchored opposite corners, minimum size, linked spacing, lock/minimize exclusions");
    }

    static void CheckBatchLayout()
    {
        using (var first = new RefPlayer.PlayerForm())
        using (var second = new RefPlayer.PlayerForm())
        {
            first.LinkedMovement = false;
            first.StartPosition = second.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            first.FormBorderStyle = second.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            first.Bounds = new System.Drawing.Rectangle(100, 100, 400, 300);
            second.Bounds = new System.Drawing.Rectangle(512, 100, 400, 300);
            var a = first.Handle; var b = second.Handle;
            first.JoinGroup(); second.JoinGroup();
            var leftImage = new System.Windows.Forms.PictureBox();
            var rightImage = new System.Windows.Forms.PictureBox();
            leftImage.Dock = rightImage.Dock = System.Windows.Forms.DockStyle.Fill;
            first.Controls.Add(leftImage); second.Controls.Add(rightImage);
            first.LinkedMovement = true;
            int layouts = 0, partialLayouts = 0;
            System.Windows.Forms.LayoutEventHandler layout = delegate
            {
                layouts++;
                if (first.Size != second.Size || second.Left - first.Right != 12) partialLayouts++;
            };
            first.Layout += layout; second.Layout += layout;
            first.Size = new System.Drawing.Size(600, 450);
            Check(layouts > 0 && partialLayouts == 0, "Layout must not see the leader updated before its peer");
            for (int i = 0; i < 300; i++)
            {
                first.Size = new System.Drawing.Size(600 + i % 100, 450 + i % 70);
                second.Location = new System.Drawing.Point(second.Left + 1, second.Top - 1);
                Check(first.Size == second.Size && second.Left - first.Right == 12, "Rapid native-window updates keep dimensions and spacing in sync");
            }
            Check(partialLayouts == 0 && leftImage.Size == first.ClientSize && rightImage.Size == second.ClientSize,
                "Both image layouts finish at the same group state");
        }
        System.Console.WriteLine("PASS: real window handles, batched coherent layouts, rapid linked resize/move, final image bounds");
    }
}
'''

CACHE_HARNESS = r'''
class CacheTest
{
    [System.Runtime.InteropServices.DllImport("kernel32.dll")]
    static extern uint SetErrorMode(uint mode);
    [System.STAThread]
    static void Main(string[] args)
    {
        SetErrorMode(2);
        try { Run(args); }
        catch (System.Exception error)
        {
            System.Console.Error.WriteLine(error.GetType().FullName + ": " + error.Message);
            System.Environment.Exit(1);
        }
    }
    static void Run(string[] args)
    {
        var legacy = System.Reflection.Assembly.Load(System.IO.File.ReadAllBytes(args[0]));
        if (legacy.GetType("RefPlayer.PlayerForm").GetProperty("ViewCount") != null)
            throw new System.Exception("Legacy fixture must lack the new API");
        for (int i = 1; i <= 2; i++)
        {
            var assembly = System.Reflection.Assembly.Load(System.IO.File.ReadAllBytes(args[i]));
            string prefix = "RefPlayerMV_" + i + ".";
            System.Type type = null;
            foreach (var loaded in System.AppDomain.CurrentDomain.GetAssemblies())
                if (loaded.GetType(prefix + "PlayerForm") != null) { type = loaded.GetType(prefix + "PlayerForm"); break; }
            if (type == null || type.Assembly != assembly || type.Assembly == legacy)
                throw new System.Exception("Selected a cached assembly");
            foreach (string component in new string[] { "Win32HandleWrapper", "ToolStripEX", "RecordWindow", "FormEvents", "WinApi", "GifCreator", "PictureBoxEx" })
                if (assembly.GetType(prefix + component) == null) throw new System.Exception("Missing component: " + component);
            using (var instance = (System.IDisposable)System.Activator.CreateInstance(type))
            {
                type.GetMethod("JoinGroup").Invoke(instance, null);
                if ((int)type.GetProperty("ViewCount").GetValue(instance, null) != 1)
                    throw new System.Exception("Missing original player instance");
            }
            var recorderType = assembly.GetType(prefix + "RecordWindow");
            using (var recorder = (System.Windows.Forms.Form)System.Activator.CreateInstance(recorderType))
            using (var strip = (System.Windows.Forms.ToolStrip)System.Activator.CreateInstance(assembly.GetType(prefix + "ToolStripEX")))
            {
                recorder.Controls.Add(strip);
                recorderType.GetField("toolStrip").SetValue(recorder, strip);
                recorder.MinimumSize = new System.Drawing.Size(216, 170);
                recorder.MaximumSize = new System.Drawing.Size(0, 0);
                // Windows still caps top-level forms to desktop dimensions. Test the real
                // recording form up to the visible desktop, including 4K when available.
                var desktop = System.Windows.Forms.SystemInformation.VirtualScreen;
                var fullDesktop = new System.Drawing.Size(desktop.Width - 6, desktop.Height - strip.Height - 6);
                foreach (var size in new[] { new System.Drawing.Size(1280, 720), new System.Drawing.Size(1920, 1080), fullDesktop })
                {
                    recorderType.GetMethod("SetRecordRes").Invoke(recorder, new object[] { size });
                    var actual = (System.Drawing.Size)recorderType.GetMethod("GetRecordRes").Invoke(recorder, null);
                    if (actual != size) throw new System.Exception("Recording size was capped: " + size + " -> " + actual);
                }
                recorder.MinimumSize = recorder.Size;
                recorder.MaximumSize = recorder.Size;
                recorder.MinimumSize = new System.Drawing.Size(216, 170);
                recorder.MaximumSize = new System.Drawing.Size(0, 0);
                var smaller = new System.Drawing.Size(1280, 720);
                recorderType.GetMethod("SetRecordRes").Invoke(recorder, new object[] { smaller });
                if ((System.Drawing.Size)recorderType.GetMethod("GetRecordRes").Invoke(recorder, null) != smaller)
                    throw new System.Exception("Preview size lock remained after resetting recording limits");
            }
        }
        System.Console.WriteLine("PASS: complete embedded components compile; isolated sessions; recorder accepts 720p/1080p/desktop size and releases preview size lock");
    }
}
'''


def extract(script, component):
    match = re.search(r'\b' + component + r'\s*=\s*"((?:\\.|[^"\\])*)"', script, re.S)
    assert match, f'Missing source: {component}'
    return re.sub(r'\\(.)', lambda m: {'n': '\n', 'r': '\r', 't': '\t'}.get(m[1], m[1]), match[1])


def run_exe(command):
    result = subprocess.run(command, capture_output=True, text=True, errors='replace', timeout=30)
    print((result.stdout + result.stderr).encode('ascii', 'backslashreplace').decode('ascii'))
    result.check_returncode()
    assert 'PASS:' in result.stdout, result.stdout + result.stderr


def main():
    entry = ENTRY.read_text(encoding='utf-8-sig')
    script = CORE.read_text(encoding='utf-8-sig')
    recorder_limits = script[script.index('fn uifn_SetRecorderMinMaxSize ='):script.index('uifn_SetRecorderMinMaxSize()', script.index('fn uifn_SetRecorderMinMaxSize ='))]
    assert 'ui_RecordWindow.MaximumSize = dotnetobject "System.Drawing.Size" 0 0' in recorder_limits
    assert 'RPMaxRecordReslotion' not in script, 'Remove the obsolete 960px recording cap and its description'
    assert 'local RPMaxRecordSeconds' in script and '= 20' in script
    assert 'ui_RecordWindow.MaximumSize = ui_RecordWindow.Size' in script, 'Keep preview size fixed'
    assert 'fileIn CorePath' in entry and entry.count('session.CreateView()') == 1
    assert 'session.CreateView beside:firstView' not in entry
    assert 'local pending = for quitView in CloseCallbacks collect quitView' in entry
    assert 'local pending = for quitView in previousSession.CloseCallbacks collect quitView' in entry
    assert 'copy CloseCallbacks' not in entry
    assert entry.index('::RefPlayer_Close()') < entry.index('global RefPlayerSession = session')
    assert 'FloatingReferenceForm' not in script and 'SequenceView' not in script and 'ViewToolbar' not in script
    assert 'RPSession.Assembly = CompileCSharpCode()' in script
    assert 'fn RP_TypeName className = RPNamespace + "." + className' in script
    assert 'menuItem AddReferenceView "新增参考窗口"' in script
    assert 'on AddReferenceView picked do RPSession.CreateView beside:ui_PlayerWindow' in script
    assert 'LinkReferenceViews.checked = ui_PlayerWindow.LinkedMovement' in script
    assert 'menuItem UnifyReferenceSizes "统一为视图一大小"' in script
    assert 'on UnifyReferenceSizes picked do ui_PlayerWindow.UnifySizesToFirst()' in script
    assert 'UnifyReferenceSizes.enabled = ui_PlayerWindow.CanUnifySizes' in script
    assert 'sharedIniFile = pathConfig.appendPath (getdir #plugcfg) "RefPlayer2020.ini"' in script
    assert 'getINISetting (FileFor InputStruct) Category prop' in script
    assert 'setINISetting (FileFor InputStruct) Category prop' in script
    assert 'if ApplyingSharedSettings do return()' in script
    assert re.search(r'catch\s*\(\s*ApplyingSharedSettings = false\s*throw\(\)\s*\)', script), \
        'MAXScript catch must reset the sharing guard and rethrow without arguments'
    assert '#SharedSettingsChanged' in script
    assert '#PasteRequested' in script and 'fn RP_PasteImage =' in script
    paste_handler = script[script.index('fn RP_PasteImage ='):script.index('fn init_RegisterHotKey =')]
    for operation in ('CacheClipboard ClipboardCacheRoot', 'RP_OpenFile folderPath', 'Poses.Set (currentTime.frame as integer)', 'RP_Update()', 'cDisplay_FitLoadedSequence 1'):
        assert operation in paste_handler
    assert 'dTime_SetStartTime 0' not in paste_handler
    assert 'ui_PlayerWindow.Poses.ImageAt (currentTime.frame as integer)' in script
    assert 'menuItem PastePose "粘贴 Pose 到当前帧（Ctrl+V）"' in script
    assert 'menuItem EditPoseKeys "Pose 关键帧..."' in script
    assert 'RegisterHotKey(Handle, PasteHotKeyId, 0x4002' in script
    assert 'protected override void OnDeactivate' in script and 'ReleasePasteHotKey();' in script
    assert 'rollout PoseKeys_Rollout "Pose 关键帧"' in script
    assert 'group "图片缓存目录"' in script and 'SettingCtrl.Load s_Cache' in script
    assert 'SettingCtrl.Save s_Cache' in script and '"CacheSetting":' in script
    assert 'ui_PlayerWindow.ReferenceFolder = thepath' in script
    assert 'ui_PlayerWindow.Poses.TryLoadSparseFolder thepath' in script
    assert 'ui_PlayerWindow.Poses.SetStartFrame (val as integer)' in script
    assert 'button alignStart "首张图定位到当前帧（整组平移）"' in script
    for category in ('RAMSetting', 'RecordSetting', 'GridSetting', 'DisplaySetting'):
        assert f'"{category}":' in script
    assert script.index('#SharedSettingsChanged') < script.rindex('RP_Start()')
    assert 'FormBorderStyle = ui_PlayerWindow.FormBorderStyle.None' in script
    assert 'popUpMenu rcMenu_Time' in script and 'popUpMenu rcMenu_Display' in script
    assert 'cDisplay_ScaleToRatio 1' in script and 'if RP_OpenFile folderPath do' in script
    assert script.count('fn cDisplay_SetCrop rect') == 1
    assert script.count('ui_PlayerWindow.Show(theHwnd)') == 1
    assert 'RegisterTimeCallBack RP_Update' in script and 'UnRegisterTimeCallBack RP_Update' in script
    assert 'RefPlayer2020_View' in script
    assert '::RefPlayer_Close()' not in script, 'Opening a sibling must not close previous views'
    for code in (entry, script):
        maxscript = re.sub(r'--[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"', '', code, flags=re.S)
        assert not re.search(r'\.\w+\s*\(\s*\)\s*\.', maxscript), 'Unsupported chained MAXScript method call'
    assert not re.search(r'\b(?:dotnetobject|dotnetclass)\s+"RefPlayer\.', script, re.I)

    with tempfile.TemporaryDirectory(prefix='refplayer-test-') as folder:
        folder = Path(folder)
        player_source = folder / 'player.cs'
        player_source.write_text(extract(script, 'PlayerForm') + STUB + HARNESS, encoding='utf-8-sig')
        exe = folder / 'player.exe'
        subprocess.run([str(CSC), '/nologo', f'/out:{exe}', '/reference:System.Windows.Forms.dll',
                        '/reference:System.Drawing.dll', str(player_source)], check=True)
        run_exe([str(exe), *sys.argv[1:]])
        legacy = folder / 'legacy.cs'
        legacy.write_text('namespace RefPlayer { public class PlayerForm {} }', encoding='utf-8')
        legacy_dll = folder / 'legacy.dll'
        subprocess.run([str(CSC), '/nologo', '/target:library', f'/out:{legacy_dll}', str(legacy)], check=True)
        libraries = []
        for i in (1, 2):
            sources = []
            for component in ('RecorderForm', 'WinAPI', 'GifCreator', 'PlayerForm'):
                path = folder / f'{i}_{component}.cs'
                path.write_text(extract(script, component).replace('namespace RefPlayer', f'namespace RefPlayerMV_{i}'), encoding='utf-8-sig')
                sources.append(str(path))
            stub = folder / 'maxform.cs'
            stub.write_text(STUB, encoding='utf-8')
            library = folder / f'current{i}.dll'
            wpf = CSC.parent / 'WPF'
            subprocess.run([str(CSC), '/nologo', '/target:library', f'/out:{library}',
                            '/reference:System.Windows.Forms.dll', '/reference:System.Drawing.dll', '/reference:System.Xaml.dll',
                            f'/reference:{wpf / "PresentationCore.dll"}', f'/reference:{wpf / "WindowsBase.dll"}', str(stub), *sources], check=True)
            libraries.append(str(library))
        cache = folder / 'cache.cs'
        cache.write_text(CACHE_HARNESS, encoding='utf-8')
        cache_exe = folder / 'cache.exe'
        subprocess.run([str(CSC), '/nologo', f'/out:{cache_exe}', '/reference:System.Windows.Forms.dll',
                        '/reference:System.Drawing.dll', str(cache)], check=True)
        run_exe([str(cache_exe), str(legacy_dll), *libraries])


if __name__ == '__main__':
    main()
