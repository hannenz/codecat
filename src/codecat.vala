using Gtk;

namespace CodeCat {

	public class CodeCat : Gtk.Application {

		public WebServer server;

		public ApplicationWindow window;

		public ListStore projects;

		public TreeStore filetree;

		public CodeCat () {
			application_id = "de.hannenz.codecat";
		}

		public override void activate () {

			this.server = new WebServer ();
			this.server.run_async ();
			
			projects = new ListStore (3, typeof (Object), typeof (string), typeof (string));

			TreeIter iter;
			var project = new Project ();

			project.name = "THERA Trainer Redesign";
			project.path = "/home/hannenz/smbtom/htdocs/thera-trainer-redesign";
			projects.append (out iter);
			projects.set (iter, 0, project, 1,  project.name, 2, project.path);

			project.name = "Foo Bar";
			project.path = "/home/hannenz/smbtom/htdocs/foo-bar";
			projects.append (out iter);
			projects.set (iter, 0, project, 1,  project.name, 2, project.path);

			filetree = new TreeStore (2, 
				typeof (string),	// full path
				typeof (string)		// name
			);

			load_directory ("/home/hannenz/codecat");
			
			window = new ApplicationWindow(this);
			window.present ();
		}


		private void load_directory_children (obj, res) {
					try {
						FileEnumerator enumerator = file.enumerate_children_async.end (res);
						FileInfo info;
						while ((info = enumerator.next_file (null)) != null) {
							stdout.printf ("%s\n", info.get_name ());
							stdout.printf ("\t%s\n", info.get_file_type ().to_string ());
							stdout.printf ("\t%s\n", info.get_is_symlink ().to_string ());
							stdout.printf ("\t%s\n", info.get_is_hidden ().to_string ());
							stdout.printf ("\t%s\n", info.get_is_backup ().to_string ());
							stdout.printf ("\t%"+int64.FORMAT+"\n", info.get_size ());
						}
					}
					catch (Error e) {
						stdout.printf ("Error: %s\n", e.message);
					}
		}

		public void load_directory (string path) {

			filetree.clear ();

			var file = File.new_for_path(path);

			file.enumerate_children_async.begin ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, Priority.DEFAULT, null, load_directory_children);
		}

		public override void startup () {
			base.startup ();
		}
	}
}