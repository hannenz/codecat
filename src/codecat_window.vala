using Gtk;
using WebKit;

namespace CodeCat {

	[GtkTemplate (ui = "/de/hannenz/codecat/codecat.ui")]
	public class ApplicationWindow : Gtk.ApplicationWindow {

		[GtkChild]
		public Gtk.Stack stack;

		[GtkChild]
		public Gtk.TreeView projects_treeview;

		private CodeCat app;

		public ApplicationWindow (CodeCat application) {
			GLib.Object (application:application);
			this.app = application;

			projects_treeview.set_model (app.projects);

			var swin = new ScrolledWindow (null, null);
			swin.hexpand = true;
			swin.vexpand = true;

			// var web_view_settings = new WebKit.Settings ();
			// web_view_settings.enable_developer_extras = true;

			var view = new WebView ();
			view.show ();

			view.get_inspector ().show ();

			swin.show_all ();
			swin.add (view);
			stack.add_titled (swin, "browser", "Browser");

			view.open ("http://localhost:9999/");
		}
	}
}