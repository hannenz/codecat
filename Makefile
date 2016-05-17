#
# Install dependencies on Debian/Ubuntu:
#
# sudo apt install automake libtool valac libgtk-3-dev libsoup2.4-dev libwebkitgtk-3.0-dev libsqlite3-dev libgee-0.8-dev
# git clone ssh://git@github.com/sass/libsass
# cd libsass
# autoreconf --force --install
# ./configure --disable-tests --disable-static --enable-shared --prefix=/usr
# sudo make -j5 install
#
PRG = codecat
CC = gcc
VALAC = valac
PKGCONFIG = $(shell which pkg-config)
# PACKAGES = gtk+-3.0 libsoup-2.4 webkitgtk-3.0 sqlite3 gee-0.8 linux libsass json-glib-1.0
PACKAGES = gtk+-3.0 libsoup-2.4 webkitgtk-3.0  gee-0.8 linux libsass json-glib-1.0
CFLAGS = `$(PKGCONFIG) --cflags $(PACKAGES)`
LIBS = `$(PKGCONFIG) --libs $(PACKAGES)`
VALAFLAGS = --vapidir=src/vapi $(patsubst %, --pkg %, $(PACKAGES)) --target-glib=2.38 --gresources data/codecat.gresource.xml 

SOURCES =	src/main.vala\
			src/codecat.vala\
			src/codecat_window.vala\
			src/webserver.vala\
			src/webbrowser.vala\
			src/project.vala\
			src/websocket.vala

UIFILES = 	data/codecat.ui\
			data/app_menu.ui\
			data/codecat.gresource.xml

#Disable implicit rules by empty target .SUFFIXES
.SUFFIXES:

.PHONY: all clean distclean

all: $(PRG)
$(PRG): $(SOURCES) $(UIFILES)
	glib-compile-resources data/codecat.gresource.xml --target=src/resources.c --generate-source --sourcedir="./data"
	$(VALAC) -o $(PRG) $(SOURCES) src/resources.c $(VALAFLAGS)

clean:
	rm -f $(OBJS)
	rm -f $(PRG)

distclean: clean
	rm -f src/*.vala.c
