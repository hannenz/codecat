using Gtk;

namespace CodeCat {

	public class Project : Object {

		public enum State {
			WATCHING,
			SERVING,
			SYNCING
		}

		/* Signals */
		public signal void watch_start();
		public signal void watch_end();
		public signal void serve_start();
		public signal void serve_end();
		public signal void sync_start();
		public signal void sync_end();

		public int state { get; set; default = 0; }

		public string name { get; set; default=""; }

		public string path { get; set; default=""; }

		public string custom_web_server { get; set; default=""; }

		public int http_port { get; set; default = 8000; }

		public WebServer server;
		
		private CodeCat app;
		
		private FileMonitor monitor;

		public bool running { get; set; default = false; }

		public Project (CodeCat app, int http_port) {
		    this.app = app;
			this.http_port = http_port;
			server = new WebServer(this.http_port);
		}

		public void start () {

			server.document_root = path;
			server.custom_web_server = custom_web_server;

			if (custom_web_server.length > 0) {
				server.document_root = custom_web_server;
			}

			debug ("Starting WebServer on Port %u".printf(http_port));

			server.run_async();
			running = true;
			
			load_directory(path);

			// Monitor the whole directory
			try {
				File dir = File.new_for_path(path);
				monitor = dir.monitor_directory(FileMonitorFlags.NONE, null);
				monitor.changed.connect(on_file_changed);
			}
			catch (Error e) {
				warning ("Failed to setup file monitor");
			}
		}

		public void stop () {

			debug ("Stopping WebServer on Port %u".printf(http_port));

			server.quit ();
			running = false;
		}
		
		private void load_directory_children_sync (File file, TreeIter? parent_iter = null, Cancellable? cancellable = null) throws Error {
		
		    FileEnumerator enumerator = file.enumerate_children ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, cancellable);
		    FileInfo info = null;

		    while (cancellable.is_cancelled () == false && ((info = enumerator.next_file (cancellable)) != null)) {

			    string icon_name = "gtk-file";

			    TreeIter iter;
			    this.app.filetree.append  (out iter, parent_iter);
			    //filetree.insert  (out iter, parent_iter, -1);

			    if (info.get_file_type () == FileType.DIRECTORY) {
				    File subdir = file.resolve_relative_path (info.get_name ());
				    load_directory_children_sync (subdir, iter, cancellable);
				    icon_name = "gtk-directory";
			    }

			    var icon = new ThemedIcon (icon_name);
			    var file_type = info.get_file_type ();

        		this.app.filetree.set(iter, 0, file.get_path (), 1, info.get_name (), 2, monitor, 3, icon, 4, (int)file_type);
    		}
    	}

		// FIXME: Use async! see if it is faster..

		public void load_directory (string path) {

			this.app.filetree.clear ();

			try {
				var dir = File.new_for_path(path);

				load_directory_children_sync (dir, null, new Cancellable ());
			}
			catch (Error e) {
				stderr.printf("Error: %s\n", e.message);
			}
		}

		public void on_file_changed (File file, File? other_file, FileMonitorEvent event) {

		    var filename = file.get_basename();

			if (event == FileMonitorEvent.CHANGES_DONE_HINT) {

				stdout.printf ("Change detected to \"%s\" : %s\n", file.get_path(), event.to_string ());

			    if (Regex.match_simple ("^[^_\\.].*\\.scss$", filename)) {
					compile_sass_file(file);
				}
			}
		}

		public bool compile_sass_file(File file) {

			var ctx = new Sass.FileContext(file.get_path());
			var opt = ctx.get_options();
			opt.set_precision(1);
			opt.set_output_style(Sass.OutputStyle.COMPRESSED);
			opt.set_source_comments(false);
			ctx.set_options(opt);

			var compiler = new Sass.Compiler.from_file_context(ctx);
			compiler.parse();
			compiler.execute();

			var output = ctx.get_output_string();

			var error_status = ctx.get_error_status();

			if (error_status == 0) {
//				stdout.printf("%s\n", output);

				try {
					File outfile;
					outfile = File.new_for_path("/var/www/html/wolfgang-braun/css/main.css");
					var os = outfile.replace(null, false, FileCreateFlags.NONE);
					var dos = new DataOutputStream(os);
					dos.put_string(output);

//					this.websocket_server.send("refresh");
				}
				catch (Error e) {
					stderr.printf("Failed to write output file\n");
				}
			}
			else {
				stderr.printf("Failed to parse file: %u: %s\n", error_status, ctx.get_error_message());
				return false;
			}

			return true;
		}
	}
}
