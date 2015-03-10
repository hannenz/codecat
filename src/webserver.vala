using Soup;

namespace CodeCat {
	
	public class WebServer : Soup.Server {

		public WebServer  () {
			Object (port : 9999);

			assert (this != null);

//			var server = new Soup.Server (Soup.SERVER_PORT, 9999);
			this.add_handler (null, default_handler);
			debug ("Running server async");
//			server.run_async ();
		}

		public static void default_handler (Server server, Soup.Message msg, string path, HashTable<string, string>? query, ClientContext client) {

			debug ("WebServer: default_handler");

			string mime_type = "text/html";
			var request_headers = msg.request_headers;
			request_headers.foreach (( name, value) => {
				if ( name == "Accept"  && value != "*/*") {
					mime_type = value;
				}
			});

			if (path == "/") {
				path = "/index.html";
			}

			try {
				uint8[] contents;
				string etag_out;
				string full_path = "/home/hannenz/smbtom/htdocs/thera-trainer-redesign" + path;

				File resource = File.new_for_path (full_path);
				resource.load_contents (null, out contents, out etag_out);
				msg.set_status (200);
				msg.set_response (mime_type, Soup.MemoryUse.COPY, contents);

				debug ("Serving resource: %s", full_path);
			}
			catch (Error e) {
				stderr.printf ("Failed to load resource: %s", path);
				msg.set_status (404);
			}
		}
	}
}