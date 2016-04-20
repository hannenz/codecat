using Gtk;

namespace CodeCat {

	public class CodeCat : Gtk.Application {

		public WebServer server;

		public WebSocketServer websocket_server;

		public ApplicationWindow window;

		public Gtk.ListStore projects;

		public TreeStore filetree;

		public TreeModelFilter filetree_filter;

		public CodeCat () {
			application_id = "de.hannenz.codecat";
		}

		/* Activate is called when the application is launched without command line parameters */
		public override void activate () {

			this.server = new WebServer ();
			this.server.run_async ();

			this.websocket_server = new WebSocketServer ("127.0.0.1", 9090);
			websocket_server.client_connected.connect ((socket) => {
					debug ("Client %s has connected to websocket server", socket.get_data <string> ("sec_websocket_key"));
					int n = websocket_server.get_n_clients ();
					window.refresh_browser_button.set_label ("Refresh %u browsers".printf (n));
				});
			websocket_server.client_disconnected.connect ((key) => {
					debug ("Client %s has disconnected from websocket server", key);
					int n = websocket_server.get_n_clients ();
					window.refresh_browser_button.set_label ("Refresh %u browsers".printf (n));
				});

			projects = new Gtk.ListStore (3, typeof (Object), typeof (string), typeof (string));

			TreeIter iter;

			var project = new Project ();
			project.name = "Test";
			project.path = "/home/hannenz/sampleweb";
			projects.append(out iter);
			projects.set(iter, 0, project, 1, project.name, 2, project.path);

			project = new Project ();
			project.name = "THERA Trainer Redesign";
			project.path = "/home/hannenz/smbtom/htdocs/thera-trainer-redesign";
			projects.append (out iter);
			projects.set (iter, 0, project, 1,  project.name, 2, project.path);

			project = new Project ();
			project.name = "Timingplaner";
			project.path = "/home/hannenz/smbtom/htdocs/timingplaner";
			projects.append (out iter);
			projects.set (iter, 0, project, 1,  project.name, 2, project.path);

			project = new Project ();
			project.name = "Hilcona AG Website";
			project.path = "/home/hannenz/smbtom/htdocs/hilcona";
			projects.append (out iter);
			projects.set (iter, 0, project, 1,  project.name, 2, project.path);

			filetree = new TreeStore (
				5,
				typeof (string),	// 0 path
				typeof (string),	// 1 name
				typeof (Object),	// 2 FileMonitor
				typeof (Icon),		// 3 icon name (GIcon)
				typeof (int)		// 4 FileType (GLib.FileType)
			);

			filetree_filter = new TreeModelFilter(filetree, null);

			filetree_filter.set_visible_func ( (model, iter) => {
					string name;
					model.get(iter, 1, out name);
					return (name != null && name.length > 0 && name[0] != '.');
				});

			window = new ApplicationWindow(this);

			window.projects_treeview.row_activated.connect ( (path, col) => {
					TreeIter iter1;
					Project new_project;
					projects.get_iter (out iter1, path);
					projects.get(iter1, 0, out new_project);

					switch_to_project (new_project);
				});

			window.project_files.row_activated.connect ( (path, col) => {

					window.sidebar.set_reveal_child (false);

					TreeIter iter2;
					string name;
					Icon icon;
					FileType file_type;

					filetree_filter.get_iter (out iter2, path);
					filetree_filter.get(iter2, 1, out name, 3, out icon, 4, out file_type);
					if (file_type == FileType.REGULAR) {
						window.sidebar_primary_icon.set_from_gicon (icon, IconSize.DIALOG);

						window.sidebar_primary_label.set_label (name);
						window.sidebar.set_reveal_child (true);
					}
				});

			TreeIter iter_first_project;
			Project first_project;
			projects.get_iter (out iter_first_project, new TreePath.first ());
			projects.get(iter_first_project, 0, out first_project);
			switch_to_project (first_project);

			window.present ();
		}

		/* Guaranteed to be called once for each primary application instance: */
		public override void startup () {
			base.startup ();
		}

		public void switch_to_project (Project project) {
			assert (project != null);

			debug ("Switching to Project: %s at %s", project.name, project.path);

			server.document_root = project.path;
		
			load_directory (project.path);

			window.sidebar.set_reveal_child (false);

			window.view.reload ();
		}

		private void load_directory_children_sync (File file, TreeIter? parent_iter = null, Cancellable? cancellable = null) throws Error {
			
			FileEnumerator enumerator = file.enumerate_children ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, cancellable);
			FileInfo info = null;

			while (cancellable.is_cancelled () == false && ((info = enumerator.next_file (cancellable)) != null)) {

				string icon_name = "gtk-file";

				FileMonitor monitor = null;

				TreeIter iter;
				filetree.append  (out iter, parent_iter);
				//filetree.insert  (out iter, parent_iter, -1);

				if (info.get_file_type () == FileType.DIRECTORY) {
					File subdir = file.resolve_relative_path (info.get_name ());
					load_directory_children_sync (subdir, iter, cancellable);
					icon_name = "gtk-directory";
				}
				else {
					// For testing: Only watch .scss files not starting with an underscore;

					var filename = info.get_name ();
					if (Regex.match_simple ("^[^_\\.].*\\.scss$", filename)) {

						File subfile = file.resolve_relative_path (info.get_name ());
						
						monitor = subfile.monitor (FileMonitorFlags.NONE, null);

						stdout.printf("** Monitoring %s\n", filename);

						monitor.changed.connect (on_file_changed);
					}
				}

				var icon = new ThemedIcon (icon_name);
				var file_type = info.get_file_type ();

				filetree.set(iter, 0, file.get_path (), 1, info.get_name (), 2, monitor, 3, icon, 4, (int)file_type);
			}
		}

		// FIXME: Use async! see if it is faster..

		public void load_directory (string path) {

			filetree.clear ();

			try {
				var dir = File.new_for_path(path);

				load_directory_children_sync (dir, null, new Cancellable ());
			}
			catch (Error e) {
				stderr.printf("Error: %s\n", e.message);
			}
		}

		public void on_file_changed (File file, File? other_file, FileMonitorEvent event) {

			if (event == FileMonitorEvent.CHANGES_DONE_HINT) {
				stdout.printf ("Change detected to \"%s\" : %s\n", file.get_path(), event.to_string ());
			}
		}
	}
}
