using System.Diagnostics;
using System.Reflection;

namespace GetTextToolsWindows.DotNetTool
{
    public class Program
    {
        public static int Main(string[] args)
        {
            if (args.Length < 1)
            {
                ShowHelp();

                return 1;
            }

            var binFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
            var gettextBinFolder = Path.Combine(binFolder, "..", "..", "bin");

            var toolName = args[0];
            var toolFile = Path.Combine(gettextBinFolder, $"{toolName}.exe");

            if (!File.Exists(toolFile))
            {
                Console.WriteLine("Invalid gettext tool.");
                return 2;
            }


            var startInfo = new ProcessStartInfo(toolFile)
            {
                Arguments = string.Join(" ", args.Skip(1)),
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = false
            };

            // needed to correctly print output from gettext tools
            Console.OutputEncoding = System.Text.Encoding.Latin1;

            using (var p = Process.Start(startInfo))
            {
                if (p == null) return 3;


                Console.WriteLine(p.StandardOutput.ReadToEnd());
                Console.WriteLine(p.StandardError.ReadToEnd());

                p.WaitForExit(10000);

                return p.ExitCode;
            }
        }

        private static void ShowHelp()
        {
            Console.WriteLine("Usage:");
            Console.WriteLine("  Gettext.Tools -- <TOOL_NAME> [tool specific options]");
            Console.WriteLine();
            Console.WriteLine("Examples:");
            Console.WriteLine("  Gettext.Tools -- msgcat --to-code=UTF-8 --no-location --output-file=merged.pot p1.pot p2.pot p3.pot");
            Console.WriteLine("  Gettext.Tools -- msguniq --sort-output --output-file=merged.pot merged-unique.pot");
            Console.WriteLine("  Gettext.Tools -- msgmerge --update --backup=none en.po merged-unique.pot");
            Console.WriteLine("  Gettext.Tools -- msgmerge --update --backup=none de.po merged-unique.pot");
            Console.WriteLine();
            Console.WriteLine("Available Tools:");
            Console.WriteLine("  msgattrib, msgcat, msgcmp, msgcomm, msgconv, msgen, msgexec, msgfilter, msgfmt, msggrep, msginit, msgmerge, msgunfmt, msguniq, recode-sr-latin, xgettext");
            Console.WriteLine("  For more information about the individual tools and their options, please see the gettext documentation at https://www.gnu.org/software/gettext/manual/html_node/index.html");
            Console.WriteLine();
        }
    }
}