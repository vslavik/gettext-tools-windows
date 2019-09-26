
GETTEXT_VERSION   = 0.20.1
LIBICONV_VERSION  = 1.16

# version of the gettext-tools-windows package; usually same as GETTEXT_VERSION
# use "-n" suffix; for NuGet, use ".00n" suffix instead, e.g. 0.20.1-1 and 0.20.1.001
PACKAGE_VERSION   = $(GETTEXT_VERSION)-1
NUGET_VERSION     = $(GETTEXT_VERSION).001

_space := $(subst ,, )
GETTEXT_VERSION_SHORT := $(subst $(_space),.,$(wordlist 1,2,$(subst ., ,$(GETTEXT_VERSION))))

# Awful trickery to undo MSYS's magical path conversion (see
# http://www.mingw.org/wiki/Posix_path_conversion) which happens to break
# gettext's executable relocation support.
MSYS_PREFIX       = c:/usr/local
UNIX_PREFIX       = /usr/local

LIBICONV_FLAGS    = --prefix=$(MSYS_PREFIX) \
					--disable-static \
					--disable-dependency-tracking \
					--disable-rpath \
					--disable-nls

GETTEXT_FLAGS     = --prefix=$(MSYS_PREFIX) \
					--disable-static \
					--disable-dependency-tracking \
					--enable-silent-rules \
					--with-libiconv-prefix=$(USR_LOCAL) \
					--disable-rpath \
					--enable-nls \
					--disable-csharp \
					--disable-java \
					--enable-threads=windows \
					--enable-relocatable \
					ac_cv_func__set_invalid_parameter_handler=no

CFLAGS  := -O2
LDFLAGS := -Wl,--dynamicbase -Wl,--nxcompat -Wl,--no-seh

PATCHESDIR  = $(CURDIR)/patches
BUILDDIR    = $(CURDIR)/build
DOWNLOADDIR = $(BUILDDIR)/download
COMPILEDIR  = $(BUILDDIR)/compile
STAGEDIR    = $(BUILDDIR)/stage
USR_LOCAL   = $(STAGEDIR)/usr/local
DISTDIR     = $(BUILDDIR)/dist

ARCHIVE_FILE = $(BUILDDIR)/gettext-tools-windows-$(PACKAGE_VERSION).zip
NUGET_FILE   = $(BUILDDIR)/Gettext.Tools.$(NUGET_VERSION).nupkg

LIBICONV_FILE := libiconv-$(LIBICONV_VERSION).tar.gz
LIBICONV_URL  := http://ftp.gnu.org/pub/gnu/libiconv/$(LIBICONV_FILE)

GETTEXT_FILE := gettext-$(GETTEXT_VERSION).tar.gz
GETTEXT_URL  := http://ftp.gnu.org/pub/gnu/gettext/$(GETTEXT_FILE)

LIBICONV_DOWNLOAD := $(DOWNLOADDIR)/$(LIBICONV_FILE)
LIBICONV_COMPILE  := $(COMPILEDIR)/LIBICONV.built
LIBICONV_STAGE    := $(COMPILEDIR)/LIBICONV.staged

GETTEXT_DOWNLOAD := $(DOWNLOADDIR)/$(GETTEXT_FILE)
GETTEXT_COMPILE  := $(COMPILEDIR)/GETTEXT.built
GETTEXT_PATCHES  := $(wildcard $(PATCHESDIR)/gettext*)
GETTEXT_STAGE    := $(COMPILEDIR)/GETTEXT.staged


all: archive

compile: $(LIBICONV_COMPILE) $(GETTEXT_COMPILE)
stage: $(LIBICONV_STAGE) $(GETTEXT_STAGE)


$(LIBICONV_DOWNLOAD):
	mkdir -p $(DOWNLOADDIR)
	wget -O $@ $(LIBICONV_URL)

$(LIBICONV_COMPILE): $(LIBICONV_DOWNLOAD)
	mkdir -p $(COMPILEDIR)
	tar -C $(COMPILEDIR) -xzf $<
	cd $(COMPILEDIR)/libiconv-$(LIBICONV_VERSION) && \
		./configure $(LIBICONV_FLAGS) CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" && \
		make
	touch $@

$(LIBICONV_STAGE): $(LIBICONV_COMPILE)
	mkdir -p $(STAGEDIR)
	cd $(COMPILEDIR)/libiconv-$(LIBICONV_VERSION) && \
		make install DESTDIR=$(STAGEDIR) prefix=$(UNIX_PREFIX)
	touch $@



$(GETTEXT_DOWNLOAD):
	mkdir -p $(DOWNLOADDIR)
	wget -O $@ $(GETTEXT_URL)

$(GETTEXT_COMPILE): $(GETTEXT_DOWNLOAD) $(LIBICONV_COMPILE)
	mkdir -p $(COMPILEDIR)
	tar -C $(COMPILEDIR) -xzf $<
	cd $(COMPILEDIR)/gettext-$(GETTEXT_VERSION) && \
	for p in $(GETTEXT_PATCHES) ; do \
		patch -p1 < $$p ; \
	done
	cd $(COMPILEDIR)/gettext-$(GETTEXT_VERSION) && \
		./configure $(GETTEXT_FLAGS) CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" && \
		make -C libtextstyle && \
		make -C gettext-tools
	touch $@

$(GETTEXT_STAGE): $(GETTEXT_COMPILE) $(LIBICONV_STAGE)
	mkdir -p $(STAGEDIR)
	cd $(COMPILEDIR)/gettext-$(GETTEXT_VERSION) && \
		make -C libtextstyle install DESTDIR=$(STAGEDIR) prefix=$(UNIX_PREFIX) && \
		make -C gettext-tools install DESTDIR=$(STAGEDIR) prefix=$(UNIX_PREFIX)
	rm -f $(STAGEDIR)$(UNIX_PREFIX)/share/locale/locale.alias
	touch $@


dist: stage
	rm -rf $(DISTDIR)
	mkdir -p $(DISTDIR)/{bin,lib/gettext,share,doc}
	cp -a LICENSE $(DISTDIR)/license.txt
	cp -a README.md $(DISTDIR)/readme.txt
	cp -a $(USR_LOCAL)/bin/msg*.exe $(DISTDIR)/bin/
	cp -a $(USR_LOCAL)/bin/recode-sr-latin.exe $(DISTDIR)/bin/
	cp -a $(USR_LOCAL)/bin/xgettext.exe $(DISTDIR)/bin/
	cp -a $(USR_LOCAL)/bin/*.dll $(DISTDIR)/bin/
	cp -a /mingw32/bin/libgcc_s_dw*.dll $(DISTDIR)/bin
	cp -a /mingw32/bin/libstdc++*.dll $(DISTDIR)/bin
	cp -a /mingw32/bin/libgomp*.dll $(DISTDIR)/bin
	cp -a /mingw32/bin/libwinpthread*.dll $(DISTDIR)/bin
	cp -a $(USR_LOCAL)/lib/gettext/cldr-plurals.exe $(DISTDIR)/lib/gettext
	cp -a $(USR_LOCAL)/share/gettext-$(GETTEXT_VERSION_SHORT) $(DISTDIR)/share/gettext
	cp -a $(USR_LOCAL)/share/gettext/styles $(DISTDIR)/share/gettext/
	cp -a $(USR_LOCAL)/share/locale $(DISTDIR)/share/
	cp -a $(USR_LOCAL)/share/doc/gettext/*.html $(DISTDIR)/doc/
	strip --strip-all $(DISTDIR)/bin/*.dll $(DISTDIR)/bin/*.exe


archive: dist
	rm -f $(ARCHIVE_FILE)
	cd $(DISTDIR) && zip -9 -r $(ARCHIVE_FILE) *

$(NUGET_FILE): Gettext.Tools.nuspec dist
	rm -f $@
	nuget pack Gettext.Tools.nuspec -OutputDirectory $(BUILDDIR)

nuget-push: $(NUGET_FILE)
	nuget push $(NUGET_FILE) -Source https://www.nuget.org/api/v2/package

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean compile stage dist archive nuget-push
