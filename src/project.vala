using Gtk;
using Json;

namespace CodeCat {

	public class Project : GLib.Object {

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
		
		private List<FileMonitor> monitors;

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

			Json.Node root = Json.gobject_serialize(this.app.filetree);
			Json.Generator generator = new Json.Generator();
			generator.set_root(root);
			string json = generator.to_data(null);
			debug (json);
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

			    // string icon_name = Gtk.Stock.FILE;

			    TreeIter iter;
			    this.app.filetree.append  (out iter, parent_iter);
			    //filetree.insert  (out iter, parent_iter, -1);

			    if (info.get_file_type () == FileType.DIRECTORY) {
				    File subdir = file.resolve_relative_path (info.get_name ());
				    load_directory_children_sync (subdir, iter, cancellable);
				    // icon_name = Gtk.Stock.DIRECTORY;
			    }
			    else {
					// Monitor certain files (non partial SASS file for the moment...)
					if (Regex.match_simple("^[^_\\.].*\\.scss$", info.get_name())) {
						try {
							var subfile = file.resolve_relative_path(info.get_name());
							FileMonitor monitor = subfile.monitor_file(FileMonitorFlags.NONE, null);
							debug ("Monitoring file: %s".printf(subfile.get_path()));

							monitor.changed.connect(on_file_changed);
							monitors.append(monitor);
						}
						catch (Error e) {
							warning ("Failed to setup file monitor for " + file.get_path());
						}
					}
			    }

			    // var icon = new ThemedIcon(icon_name);
			    var file_type = info.get_file_type();

        		this.app.filetree.set(iter, 
        			ProjectFileColumn.PATH, file.get_path(),
        			ProjectFileColumn.NAME, info.get_name(),
        			ProjectFileColumn.ICON, info.get_icon(),
        			ProjectFileColumn.FILE_TYPE, (int)file_type
        		);
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
			debug ("File change detected: %s: %s ".printf(file.get_path(), event.to_string()));

			if (event == FileMonitorEvent.CHANGES_DONE_HINT) {

				// stdout.printf ("Change detected to \"%s\" : %s\n", file.get_path(), event.to_string ());

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

			var error_status = ctx.get_error_status();
			if (error_status == 0) {

				var output = ctx.get_output_string();

				try {
					File outfile;
					outfile = File.new_for_path(path + "/css/main.css");
					var os = outfile.replace(null, false, FileCreateFlags.NONE);
					var dos = new DataOutputStream(os);
					dos.put_string(output);

//					this.websocket_server.send("refresh");
				}
				catch (Error e) {
					stderr.printf("Failed to write output file\n");
				}

				var mssg = "Compiled successfully: %s".printf(file.get_path());

				this.app.log(mssg, MessageType.SUCCESS);

				uint ctx_id = this.app.window.statusbar.get_context_id("log");
				this.app.window.statusbar.push(ctx_id, mssg);

				this.app.window.infobar.get_content_area().add(new Gtk.Label (mssg));
				this.app.window.infobar.set_message_type(Gtk.MessageType.INFO);
				this.app.window.infobar.show();
			}
			else {
				var mssg = "Failed to compile: %s".printf(file.get_path());

				this.app.log("%s:\n[error_status: %u]:%s".printf(mssg, error_status, ctx.get_error_message()), MessageType.ERROR);

				uint ctx_id = this.app.window.statusbar.get_context_id("log");
				this.app.window.statusbar.push(ctx_id, mssg);

				this.app.window.infobar.get_content_area().add(new Gtk.Label (mssg));
				this.app.window.infobar.set_message_type(Gtk.MessageType.ERROR);
				this.app.window.infobar.show();

				return false;
			}

			return true;
		}
	}
}
