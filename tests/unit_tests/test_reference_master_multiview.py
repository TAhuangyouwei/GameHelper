"""Compile and exercise the embedded WinForms view code (Windows/.NET Framework).

Run: python tests/unit_tests/test_reference_master_multiview.py
The MaxForm stand-in permits testing without starting a licensed Max instance.
"""
from pathlib import Path
import os
import re
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / 'scripts/实用工具/动画/参考大师v1.06.ms'
CSC = Path(os.environ['WINDIR']) / 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'

HARNESS = r'''
namespace MaxCustomControls { public class MaxForm : System.Windows.Forms.Form {} }
class Test
{
    static void Check(bool ok, string message)
    {
        if (!ok) throw new System.Exception(message);
    }
    static void MakeFrame(string folder, string name, System.Drawing.Color color)
    {
        using (var bmp = new System.Drawing.Bitmap(32, 16))
        {
            using (var g = System.Drawing.Graphics.FromImage(bmp)) g.Clear(color);
            bmp.Save(System.IO.Path.Combine(folder, name));
        }
    }
    [System.STAThread]
    static void Main(string[] args)
    {
        string a = System.IO.Path.Combine(args[0], "a");
        string b = System.IO.Path.Combine(args[0], "b");
        string empty = System.IO.Path.Combine(args[0], "empty");
        System.IO.Directory.CreateDirectory(a);
        System.IO.Directory.CreateDirectory(b);
        System.IO.Directory.CreateDirectory(empty);
        // Deliberately create in reverse order to check sequence sorting.
        MakeFrame(a, "002.png", System.Drawing.Color.Blue);
        MakeFrame(a, "001.png", System.Drawing.Color.Red);
        MakeFrame(b, "001.PNG", System.Drawing.Color.Green);
        using (var form = new RefPlayer.PlayerForm())
        {
            form.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            form.Size = new System.Drawing.Size(420, 240);
            var primary = new RefPlayer.PictureBoxEx();
            form.Controls.Add(primary);
            form.InitializeViews(primary, 1);
            Check(form.ViewCount == 2 && form.Width == 840, "Default two views");
            Check(primary.Width == 420, "Keep original first-view width");
            form.AddView();
            Check(form.ViewCount == 3 && primary.Width == 420, "Add third view");
            form.LoadExtraView(1, a, 1);
            form.LoadExtraView(2, b, 1);
            var views = new System.Collections.Generic.List<RefPlayer.SequenceView>();
            foreach (System.Windows.Forms.Control control in form.Controls)
                if (control is RefPlayer.SequenceView) views.Add((RefPlayer.SequenceView)control);
            var first = views.Find(v => v.Left == primary.Right);
            var second = views.Find(v => v.Left > primary.Right);
            Check(((System.Drawing.Bitmap)first.Image).GetPixel(0, 0).R == 255, "First sorted frame");
            form.UpdateExtraViews(2);
            Check(((System.Drawing.Bitmap)first.Image).GetPixel(0, 0).B == 255, "Advance long sequence");
            Check(((System.Drawing.Bitmap)second.Image).GetPixel(0, 0).G == 128, "Clamp short sequence independently");
            form.UpdateExtraViews(-10);
            Check(((System.Drawing.Bitmap)first.Image).GetPixel(0, 0).R == 255, "Clamp before start");
            form.UpdateExtraViews(999);
            Check(((System.Drawing.Bitmap)first.Image).GetPixel(0, 0).B == 255, "Clamp after end");
            bool rejected = false;
            try { first.LoadFolder(empty, 1); } catch (System.IO.IOException) { rejected = true; }
            Check(rejected && first.Image != null, "Invalid replacement preserves loaded sequence");
            form.LoadExtraView(1, b, 1);
            Check(((System.Drawing.Bitmap)first.Image).GetPixel(0, 0).G == 128, "Replace only targeted view");
            form.Size = new System.Drawing.Size(900, 300);
            Check(primary.Width == 300 && first.Width == 300 && second.Right == 900, "Resize all columns");
            var p = form.PointToScreen(new System.Drawing.Point(750, 100));
            Check(form.ViewAtScreenPoint(p.X, p.Y) == 2, "Route drop by column");
            form.SetMultiViewState(true, false);
            Check(!first.Visible && !second.Visible, "Hide extras while minimized");
            form.SetMultiViewState(false, true);
            foreach (System.Windows.Forms.Control c in form.Controls)
                if (c is System.Windows.Forms.Button) Check(!c.Visible, "Hide add button while locked");
            form.SetMultiViewState(false, false);
            // Decoding must release file handles even while images are displayed.
            System.IO.Directory.Delete(a, true);
            System.IO.Directory.Delete(b, true);
        }
        System.Console.WriteLine("PASS: layout, independent sequences, sync/clamping, replacement, drop targeting, resource release");
    }
}
'''

CACHE_HARNESS = r'''
class CacheTest
{
    [System.STAThread]
    static void Main(string[] args)
    {
        var legacy = System.Reflection.Assembly.Load(System.IO.File.ReadAllBytes(args[0]));
        string name = "RefPlayer.PlayerForm";
        // Reproduce an existing Max session retaining the pre-multiview type.
        if (legacy.GetType(name).GetProperty("ViewCount") != null)
            throw new System.Exception("Legacy fixture must lack ViewCount");
        for (int i = 1; i <= 2; i++)
        {
            var assembly = System.Reflection.Assembly.Load(System.IO.File.ReadAllBytes(args[i]));
            string uniqueName = "RefPlayerMV_" + i + ".PlayerForm";
            System.Type type = null;
            // MAXScript searches loaded assemblies for unqualified type names.
            foreach (var loaded in System.AppDomain.CurrentDomain.GetAssemblies())
                if (loaded.GetType(uniqueName) != null) { type = loaded.GetType(uniqueName); break; }
            if (type == null) throw new System.Exception("Unique type name not found");
            if (type.Assembly != assembly || type.Assembly == legacy)
                throw new System.Exception("Selected a cached assembly");
            foreach (string component in new string[] { "Win32HandleWrapper", "ToolStripEX", "RecordWindow", "FormEvents", "WinApi", "GifCreator", "PictureBoxEx" })
                if (assembly.GetType("RefPlayerMV_" + i + "." + component) == null)
                    throw new System.Exception("Missing component: " + component);
            using (var instance = (System.IDisposable)System.Activator.CreateInstance(type))
            {
                if ((int)type.GetProperty("ViewCount").GetValue(instance, null) != 1)
                    throw new System.Exception("Missing multiview API");
            }
        }
        System.Console.WriteLine("PASS: old component loaded first, current and repeated compilations select their own types");
    }
}
'''


def main():
    script = SCRIPT.read_text(encoding='utf-8-sig')
    assert 'RPAssembly = CompileCSharpCode()' in script
    assert 'fn RP_TypeName className = RPNamespace + "." + className' in script
    maxscript_code = re.sub(r'--[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"', '', script, flags=re.S)
    assert not re.search(r'\.\w+\s*\(\s*\)\s*\.', maxscript_code), 'MAXScript requires a separate expression before accessing a method result'
    assert 'local rpRunGuid = rpGuidClass.NewGuid()' in script
    assert 'RPNamespace = "RefPlayerMV_" + (rpRunGuid.ToString "N")' in script
    assert 'substituteString source "namespace RefPlayer" ("namespace " + RPNamespace)' in script
    assert not re.search(r'\b(?:dotnetobject|dotnetclass)\s+"RefPlayer\.', script, re.I), 'Unqualified type can select an old assembly'
    embedded = re.search(r'            PlayerForm =\s*"(.*?)\n            "', script, re.S)
    assert embedded, 'Embedded PlayerForm source missing'
    source = re.sub(r'\\(.)', lambda m: {'n': '\n', 'r': '\r', 't': '\t'}.get(m[1], m[1]), embedded[1])
    with tempfile.TemporaryDirectory(prefix='refplayer-test-') as folder:
        source_path = Path(folder) / 'views.cs'
        exe_path = Path(folder) / 'views.exe'
        source_path.write_text(source + HARNESS, encoding='utf-8-sig')
        subprocess.run([str(CSC), '/nologo', '/target:exe', f'/out:{exe_path}',
                        '/reference:System.Windows.Forms.dll', '/reference:System.Drawing.dll',
                        str(source_path)], check=True)
        subprocess.run([str(exe_path), folder], check=True)
        legacy_path = Path(folder) / 'legacy.cs'
        legacy_path.write_text('namespace RefPlayer { public class PlayerForm {} }', encoding='utf-8')
        legacy_dll = Path(folder) / 'legacy.dll'
        subprocess.run([str(CSC), '/nologo', '/target:library', f'/out:{legacy_dll}', str(legacy_path)], check=True)
        current_libraries = []
        for i, name in enumerate(('current', 'repeated'), 1):
            dll = Path(folder) / f'{name}.dll'
            current_sources = []
            for component in ('RecorderForm', 'WinAPI', 'GifCreator', 'PlayerForm'):
                match = re.search(r'\b' + component + r'\s*=\s*"((?:\\.|[^"\\])*)"', script, re.S)
                assert match, f'Missing source: {component}'
                component_source = re.sub(r'\\(.)', lambda m: {'n': '\n', 'r': '\r', 't': '\t'}.get(m[1], m[1]), match[1])
                current_source = Path(folder) / f'{name}_{component}.cs'
                current_source.write_text(component_source.replace('namespace RefPlayer', f'namespace RefPlayerMV_{i}'), encoding='utf-8-sig')
                current_sources.append(str(current_source))
            stub = Path(folder) / 'maxform.cs'
            stub.write_text('namespace MaxCustomControls { public class MaxForm : System.Windows.Forms.Form {} }', encoding='utf-8')
            wpf = CSC.parent / 'WPF'
            subprocess.run([str(CSC), '/nologo', '/target:library', f'/out:{dll}',
                            '/reference:System.Windows.Forms.dll', '/reference:System.Drawing.dll', '/reference:System.Xaml.dll',
                            f'/reference:{wpf / "PresentationCore.dll"}', f'/reference:{wpf / "WindowsBase.dll"}',
                            str(stub), *current_sources], check=True)
            current_libraries.append(str(dll))
        cache_source = Path(folder) / 'cache.cs'
        cache_source.write_text(CACHE_HARNESS, encoding='utf-8')
        cache_exe = Path(folder) / 'cache.exe'
        subprocess.run([str(CSC), '/nologo', f'/out:{cache_exe}', str(cache_source)], check=True)
        subprocess.run([str(cache_exe), str(legacy_dll), *current_libraries], check=True)


if __name__ == '__main__':
    main()
