"""Validate shared original-window code and grouping without starting Max.

Run on Windows: python tests/unit_tests/test_reference_master_multiview.py
Max UI/menu/frame loading still requires an in-Max integration check.
"""
from pathlib import Path
import os
import re
import subprocess
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
}
class Test
{
    [System.Runtime.InteropServices.DllImport("kernel32.dll")]
    static extern uint SetErrorMode(uint mode);
    static void Check(bool value, string message) { if (!value) throw new System.Exception(message); }
    [System.STAThread]
    static void Main()
    {
        SetErrorMode(2);
        try { Run(); }
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
        System.Console.WriteLine("PASS: identical window type, no overlay UI, independent/linked movement, resize, per-window close, cleanup");
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
        }
        System.Console.WriteLine("PASS: complete embedded components compile; old and repeated sessions select their own types");
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
        run_exe([str(exe)])
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
        subprocess.run([str(CSC), '/nologo', f'/out:{cache_exe}', str(cache)], check=True)
        run_exe([str(cache_exe), str(legacy_dll), *libraries])


if __name__ == '__main__':
    main()
