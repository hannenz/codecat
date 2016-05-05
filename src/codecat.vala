using Gtk;

namespace CodeCat {

	public enum ProjectColumn {
		PROJECT,
		NAME,
		PATH,
		RUNNING
	}

	public class CodeCat : Gtk.Application {


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


			projects = new Gtk.ListStore (4, typeof (Object), typeof (string), typeof (string), typeof(bool));

			TreeIter iter;

			var project = new Project (this, 8001);
			project.name = "Württembergische Landesbünne";
			project.path = "/var/www/html/wlb_static/";
			project.custom_web_server = "";
			// project.http_port = 8001;
			project.start();
			projects.append(out iter);
			projects.set(iter,
				ProjectColumn.PROJECT, project,
				ProjectColumn.NAME, project.name,
				ProjectColumn.PATH, project.path,
				ProjectColumn.RUNNING,
				project.running
			);

			project = new Project (this, 8002);
			project.name = "Wolfgang Braun";
			project.path = "/var/www/html/wolfgang-braun";
			project.custom_web_server = "http://wolfgang-braun.localhost/";
			// project.http_port = 8002;
			project.start();
			projects.append (out iter);
			projects.set(iter,
				ProjectColumn.PROJECT, project,
				ProjectColumn.NAME, project.name,
				ProjectColumn.PATH, project.path,
				ProjectColumn.RUNNING,
				project.running
			);

			project = new Project (this, 8003);
			project.name = "Versichern Online";
			project.path = "/mnt/wind-www/html/versichern.online/";
			project.custom_web_server = "http://versichern.online.homelinux.lan/";
			project.start();
			projects.append (out iter);
			projects.set(iter,
				ProjectColumn.PROJECT, project,
				ProjectColumn.NAME, project.name,
				ProjectColumn.PATH, project.path,
				ProjectColumn.RUNNING,
				project.running
			);

			window = new ApplicationWindow(this);

			window.projects_treeview.row_activated.connect ( (path, col) => {
					TreeIter iter1;
					Project new_project;
					projects.get_iter (out iter1, path);
					projects.get(iter1, 0, out new_project);

					switch_to_project (new_project);
				});

/*
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
*/
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

			window.sidebar.set_reveal_child (false);

			window.view.open("http://localhost:%u".printf( project.http_port));
		}

	}
}
