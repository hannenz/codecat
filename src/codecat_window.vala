using Gtk;
using WebKit;

namespace CodeCat {

	[GtkTemplate (ui = "/de/hannenz/codecat/codecat.ui")]
	public class ApplicationWindow : Gtk.ApplicationWindow {

		[GtkChild]
		public Stack stack;

		[GtkChild]
		public TreeView projects_treeview;

		[GtkChild]
		public TreeViewColumn project_name_column;

		[GtkChild]
		public CellRendererText project_name_cell_renderer;

		[GtkChild]
		public TreeView project_files;

		[GtkChild]
		public Revealer sidebar;

		[GtkChild]
		public Label sidebar_primary_label;

		[GtkChild]
		public Image sidebar_primary_icon;

		[GtkChild]
		public Gtk.Button refresh_browser_button;

		[GtkChild]
		public Gtk.InfoBar infobar;

		[GtkChild]
		public Gtk.Statusbar statusbar;
		
		public WebView view;

		private CodeCat app;

		private Window inspector_window;

		private GLib.Settings settings;

		[GtkCallback]
		public void on_test_button_clicked (Button button) {
			app.websocket_server.send("reload");
		}

		[GtkCallback]
		public void on_inspector_close_button_clicked (Button button) {
			sidebar.set_reveal_child (false);
		}

		[GtkCallback]
		public void on_project_running_toggled (CellRendererToggle toggle, string path) {

			Gtk.TreePath tree_path = new Gtk.TreePath.from_string (path);
			Gtk.TreeIter iter;
			app.projects.get_iter (out iter, tree_path);
			app.projects.set (iter, 3, !toggle.active);
			
            Project prj;
            app.projects.get(iter, 0, out prj);
            if (toggle.active) {
                prj.start();
            }
            else {
                prj.stop();
            }
		}

		public ApplicationWindow (CodeCat application) {
			GLib.Object (application:application);

			this.app = application;

			settings = new GLib.Settings ("de.hannenz.codecat");
			settings.bind ("transition", stack, "transition-type", GLib.SettingsBindFlags.DEFAULT);

			
			var grey = Gdk.RGBA ();
			grey.parse("#cccccc");

			sidebar.override_background_color (Gtk.StateFlags.NORMAL, grey);

			projects_treeview.set_model (app.projects);
			project_files.set_model (app.filetree_filter);

			var swin = new ScrolledWindow (null, null);
			swin.hexpand = true;
			swin.vexpand = true;

			var web_view_settings = new WebKit.WebSettings ();
			web_view_settings.enable_developer_extras = true;

			view = new WebView ();
			view.set_settings (web_view_settings);
			view.show ();

			var inspector = view.get_inspector ();
			inspector.inspect_web_view.connect ( (p0) => {

					WebView iview = new WebView ();
					unowned WebView b = iview;

					this.inspector_window = new Gtk.Window ();
					this.inspector_window.add  (iview);

					return b;
				});

			inspector.show_window.connect ( () => {
					this.inspector_window.present ();
					return true;
				});

			swin.show_all ();
			swin.add (view);
			stack.add_titled (swin, "browser", "Browser");

			//view.open ("http://localhost:8000");

			project_name_column.set_cell_data_func (project_name_cell_renderer, (column, cell, model, iter) => {
					Project project;
					model.get(iter, 0, out project);
					(cell as CellRendererText).markup = "<b>" + project.name + "</b>\n<small><i>" + project.path + "</i></small>";

				});

			swin = new ScrolledWindow (null, null);
			swin.hexpand = true;
			swin.vexpand = true;

			var dd_view = new WebView ();
			var settings = new WebKit.WebSettings ();
			settings.enable_html5_database = true;
			settings.enable_html5_local_storage = true;
			settings.enable_offline_web_application_cache = true;

			dd_view.set_settings(settings);

			dd_view.show ();
			swin.show_all ();
			swin.add (dd_view);
			stack.add_titled (swin, "devdocs", "DevDocs");
			dd_view.open ("http://devdocs.io");


			swin = new ScrolledWindow(null, null);

		 	var logview = new TextView.with_buffer(this.app.log_buffer);
		 	logview.editable = false;
		 	logview.margin = 10;
		 	logview.override_font(Pango.FontDescription.from_string("monospace"));
		 	swin.add(logview);

			swin.show_all();
			stack.add_titled (swin, "log", "Log");

			this.infobar.add_button("See Log", 1);
			this.infobar.response.connect( (response) => {
					switch (response) {
						case 1:
							this.stack.set_visible_child_name("log");
							this.infobar.hide();
							break;
							
						default:
							this.infobar.hide();
							break;
					}
				});


			this.app.log("CodeCat has been launched");
		}
	}
}
