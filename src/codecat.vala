using Gtk;
using Notify;

namespace CodeCat {

	public enum MessageType {
		INFO,
		SUCCESS,
		WARNING,
		ERROR
	}

	/* Columns for project list store */
	public enum ProjectColumn {
		PROJECT,
		NAME,
		PATH,
		RUNNING,
		N_COLUMNS
	}

	/* Columns for project files tree store */
	public enum ProjectFileColumn {
		PATH,
		NAME,
		ICON,
		FILE_TYPE,
		N_COLUMNS
	}

	public class CodeCat : Gtk.Application {


		public WebSocketServer websocket_server;

		public ApplicationWindow window;

		public Gtk.ListStore projects;

		public Gtk.TreeStore filetree;

		public Gtk.TreeModelFilter filetree_filter;

		public Gtk.TextBuffer log_buffer;

		public CodeCat () {
			application_id = "de.hannenz.codecat";
			log_buffer = new Gtk.TextBuffer(null);

			Notify.init("CodeCat");
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

			projects = new Gtk.ListStore (
				ProjectColumn.N_COLUMNS,
				typeof (Object),	// Project
				typeof (string),	// Name
				typeof (string), 	// Path
				typeof(bool)		// Running
			);

			filetree = new TreeStore (
				ProjectFileColumn.N_COLUMNS,
				typeof (string),	// path
				typeof (string),	// name
				typeof (GLib.Icon),	// icon name (GIcon)
				typeof (int)		// FileType (GLib.FileType)
			);

			filetree_filter = new TreeModelFilter(filetree, null);

			filetree_filter.set_visible_func ( (model, iter) => {
					string name;
					model.get(iter, 1, out name);
					return (name != null && name.length > 0 && name[0] != '.');
				});



			TreeIter iter;
			Project project;

			// project = new Project (this, 8001);
			// project.name = "Württembergische Landesbünne";
			// project.path = "/var/www/html/wlb/";
			// project.custom_web_server = "http://wlb.localhost/";
			// project.start();
			// projects.append(out iter);
			// projects.set(iter,
			// 	ProjectColumn.PROJECT, project,
			// 	ProjectColumn.NAME, project.name,
			// 	ProjectColumn.PATH, project.path,
			// 	ProjectColumn.RUNNING,
			// 	project.running
			// );

			project = new Project (this, 8002);
			project.name = "Wolfgang Braun";
			project.path = "/var/www/html/wolfgang-braun";
			project.custom_web_server = "http://wolfgang-braun.localhost/";
			project.start();
			projects.append (out iter);
			projects.set(iter,
				ProjectColumn.PROJECT, project,
				ProjectColumn.NAME, project.name,
				ProjectColumn.PATH, project.path,
				ProjectColumn.RUNNING,
				project.running
			);

			// project = new Project (this, 8003);
			// project.name = "Versichern Online";
			// project.path = "/mnt/wind-www/html/versichern.online/";
			// project.custom_web_server = "http://versichern.online.homelinux.lan/";
			// project.start();
			// projects.append (out iter);
			// projects.set(iter,
			// 	ProjectColumn.PROJECT, project,
			// 	ProjectColumn.NAME, project.name,
			// 	ProjectColumn.PATH, project.path,
			// 	ProjectColumn.RUNNING,
			// 	project.running
			// );

			window = new ApplicationWindow(this);

			// window.projects_treeview.row_activated.connect ( (path, col) => {
			// 		TreeIter iter1;
			// 		Project new_project;
			// 		projects.get_iter (out iter1, path);
			// 		projects.get(iter1, 0, out new_project);

			// 		switch_to_project (new_project);
			// 	});

			window.project_files.row_activated.connect ( (path, col) => {

					window.sidebar.set_reveal_child (false);

					TreeIter iter2;
					string name;
					Icon icon;
					FileType file_type;

					filetree_filter.get_iter (out iter2, path);
					filetree_filter.get(iter2, ProjectFileColumn.NAME, out name, ProjectFileColumn.ICON, out icon, ProjectFileColumn.FILE_TYPE, out file_type);
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

		public void preferences_activated() {
			var prefs = new Preferences(window);
			prefs.present();
		}

		public void quit_activated () {
			debug ("Quit activated");
			quit();
		}



		/* Guaranteed to be called once for each primary application instance: */
		public override void startup () {
			base.startup ();

			// App Menu

			var action = new GLib.SimpleAction("preferences", null);
			action.activate.connect (preferences_activated);
			add_action (action);

			action = new GLib.SimpleAction("quit", null);
			action.activate.connect (quit_activated);
			add_action (action);
			add_accelerator ("<Ctrl>Q", "app.quit", null);

			var builder = new Gtk.Builder.from_resource("/de/hannenz/codecat/app_menu.ui");
			GLib.MenuModel app_menu = builder.get_object("appmenu") as GLib.MenuModel;
			set_app_menu(app_menu);
		}

		public void switch_to_project (Project project) {
			assert (project != null);

			debug ("Switching to Project: %s at %s", project.name, project.path);

			window.sidebar.set_reveal_child (false);

			window.view.open("http://localhost:%u".printf( project.http_port));
		}

		/**
		 * Log a message to the GUI log, show notification
		 * 
		 * @param string  				The message
		 * @param CodeCat.MessageType 	The message's type
		 *
		 * @return void
		 */
		public void log(string mssg, MessageType type = 0) {

			TextIter iter;
			var date = new DateTime.now(new TimeZone.local());
			var dateText = date.to_string();

//			var text = "<b>%s:</b> %s\n\n".printf(date.to_string(), mssg);


			// Try to extract line nr. and file from (error) message
			string error_line;
			string error_filename;
			string error_mssg = "";
			MatchInfo match_info;

			try {
				var regex = new Regex("on line (\\d+) of .*\\/(.*)$", RegexCompileFlags.MULTILINE);
				if (regex.match(mssg, 0, out match_info)) {
					error_line = match_info.fetch(1);
					error_filename = match_info.fetch(2);
					error_mssg = "%s: %s".printf(error_line, error_filename);
				}
				else {
					debug ("No match in " + mssg);
				}
			}
			catch (Error e) {
				error("Error: " + e.message);
			}

			this.log_buffer.get_start_iter(out iter);
			string fg_color;	// FG color for log

			switch (type) {
				case MessageType.SUCCESS:
					fg_color = "green";
					break;
				case MessageType.ERROR:
					fg_color = "red";
					break;
				default:
					fg_color = "black";
					break;
			}

			// Log to log
			var tag = log_buffer.create_tag(null, "weight", "bold", "foreground", fg_color, null);
			this.log_buffer.insert_with_tags(ref iter, dateText, -1, tag, null);

			this.log_buffer.insert(ref iter, " " + mssg + "\n\n", -1);

			// Show notification
			try {

				GLib.Settings settings = new GLib.Settings("de.hannenz.codecat");

				switch (type) {
					case MessageType.SUCCESS:
						if (settings.get_boolean("show-success-notifications")) {
							var notification = new Notify.Notification("CodeCat", mssg, "dialog-ok");
							notification.show();
						}
						break;
					case MessageType.ERROR:
						if (settings.get_boolean("show-error-notifications")) {
							var notification = new Notify.Notification("CodeCat", error_mssg, "dialog-error");
							notification.show();
						}
						break;
					default:
						break;
				}

			}
			catch (Error e) {
				error("Error: %s", e.message);
			}
		}
	}
}
