namespace CodeCat {

	[GtkTemplate (ui="/de/hannenz/codecat/preferences.ui")]
	public class Preferences : Gtk.Dialog {

		private GLib.Settings settings;

		[GtkChild]
		private Gtk.ComboBoxText transition;

		public Preferences (ApplicationWindow window) {

			GLib.Object (transient_for: window, use_header_bar: 1);

			settings = new GLib.Settings("de.hannenz.codecat");
			settings.bind("transition", transition, "active-id", GLib.SettingsBindFlags.DEFAULT);			

		}
	}
}