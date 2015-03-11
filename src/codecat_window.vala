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
		public Revealer inspector;

		[GtkChild]
		public Label inspector_primary_label;

		[GtkChild]
		public Image inspector_primary_icon;

		public WebView view;

		private CodeCat app;

		[GtkCallback]
		public void on_inspector_close_button_clicked (Button button) {
			inspector.set_reveal_child (false);
		}

		public ApplicationWindow (CodeCat application) {
			GLib.Object (application:application);
			this.app = application;

			projects_treeview.set_model (app.projects);
			project_files.set_model (app.filetree_filter);

			var swin = new ScrolledWindow (null, null);
			swin.hexpand = true;
			swin.vexpand = true;

			// var web_view_settings = new WebKit.Settings ();
			// web_view_settings.enable_developer_extras = true;

			view = new WebView ();
			view.show ();

			view.get_inspector ().show ();

			swin.show_all ();
			swin.add (view);
			stack.add_titled (swin, "browser", "Browser");

			view.open ("http://localhost:9999/");

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

			dd_view.set_settings(settings);

			dd_view.show ();
			swin.show_all ();
			swin.add (dd_view);
			stack.add_titled (swin, "devdocs", "DevDocs");
			dd_view.open ("http://devdocs.io");

		}
	}
}