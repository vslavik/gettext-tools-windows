
GNU gettext tools for Windows
=============================

This is an unofficial build of *GNU gettext* tools for Windows. The repository
contains build scripts, but there are also up-to-date binaries published at
https://github.com/vslavik/gettext-tools-windows/releases, as well as a NuGet
package.

It is a spin-off project from my translations editor Poedit: http://poedit.net


How to build it
---------------

The easiest way to use these tools is to just download the binaries or use the
NuGet package. If you prefer to build it yourself, it's simple enough:

1. You need to have a recent version of MinGW installed, including the
   `mingw-get` tool.
2. Run the `./setup-mingw.sh` command from the MinGW shell to install required
   packages.
3. Run `make dist` or `make archive` to build everything.

Good luck, building GNU gettext on MinGW tends to break once in a while due to
MinGW or gettext or gnulib changes (hence this project...).


License
-------

The LICENSE file in this directory applies to GNU gettext itself, which is
licensed under GPLv3. The makefiles and scripts for building it on Windows are
in the public domain.


---

I'm @vslavik on Twitter.

https://github.com/vslavik/gettext-tools-windows
