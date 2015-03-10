import gtk

icon_theme = gtk.icon_theme_get_default ()
print icon_theme.list_icons ()

print icon_theme.lookup_icon("gtk-directory", 38, 0).get_filename()



