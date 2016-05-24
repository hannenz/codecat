namespace CodeCat {

	[GtkTemplate (ui="/de/hannenz/codecat/preferences.ui")]
	public class Preferences : Gtk.Dialog {

		private GLib.Settings settings;

		[GtkChild]
		private Gtk.ComboBoxText transition;

		[GtkChild]
		private Gtk.CheckButton show_success_notifications;

		[GtkChild]
		private Gtk.CheckButton show_error_notifications;

		public Preferences (ApplicationWindow window) {

			GLib.Object (transient_for: window, use_header_bar: 1);

			settings = new GLib.Settings("de.hannenz.codecat");
			settings.bind("transition", transition, "active-id", GLib.SettingsBindFlags.DEFAULT);

			show_success_notifications.toggled.connect( () => {
					settings.set_boolean ("show-success-notifications", show_success_notifications.active);
				});

			show_error_notifications.toggled.connect( () => {
					settings.set_boolean ("show-error-notifications", show_error_notifications.active);
				});
		}
	}
}