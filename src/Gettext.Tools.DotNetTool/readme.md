# Gettext.Tools as dotnet tool

This is an unofficial build of *GNU gettext* tools for Windows. The repository
contains build scripts, but there are also up-to-date binaries published at
https://github.com/vslavik/gettext-tools-windows/releases, as well as a NuGet
package. The nuget package _Gettext.Tools.DotNetTool_ can be used as a dotnet global tool.

It is a spin-off project from my translations editor Poedit: https://poedit.net

## Installation

For installing as global dotnet tool use the following command:

```
dotnet tool install --global Gettext.Tools.DotNetTool
```

## Usage

If using the Gettext.Tools as a dotnet tool, the gettext toolname with the desired options can be passed.

```
Gettext.Tools -- <TOOL_NAME> [tool specific options]
```

Here are some examples for using the gettext tools msgcat, msguniq and msgmerge
```
Gettext.Tools -- msgcat --to-code=UTF-8 --no-location --output-file=merged.pot p1.pot p2.pot p3.pot
Gettext.Tools -- msguniq --sort-output --output-file=merged.pot merged-unique.pot
Gettext.Tools -- msgmerge --update --backup=none en.po merged-unique.pot
Gettext.Tools -- msgmerge --update --backup=none de.po merged-unique.pot
```

## Available tools in this package
- msgattrib
- msgcat
- msgcmp
- msgcomm
- msgconv
- msgen
- msgexec
- msgfilter
- msgfmt
- msggrep
- msginit
- msgmerge
- msgunfmt
- msguniq
- recode-sr-latin
- xgettext

For more information about the individual tools and their options, please see the gettext documentation at https://www.gnu.org/software/gettext/manual/html_node/index.html.
