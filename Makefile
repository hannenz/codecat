PRG = codecat
CC = gcc
VALAC = valac
PKGCONFIG = $(shell which pkg-config)
PACKAGES = gtk+-3.0 libsoup-2.4 webkitgtk-3.0 sqlite3 gee-0.8 linux sass
CFLAGS = `$(PKGCONFIG) --cflags $(PACKAGES)`
LIBS = `$(PKGCONFIG) --libs $(PACKAGES)`
VALAFLAGS = -X -lsass --vapidir=src/vapi $(patsubst %, --pkg %, $(PACKAGES)) --target-glib=2.38 --gresources data/codecat.gresource.xml 

SOURCES =	src/main.vala\
			src/codecat.vala\
			src/codecat_window.vala\
			src/webserver.vala\
			src/webbrowser.vala\
			src/project.vala\
			src/websocket.vala

UIFILES = 	data/codecat.ui\
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
