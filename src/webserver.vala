using Soup;

namespace CodeCat {
	
	public class WebServer : Soup.Server {

		public string document_root { get; set; default="/var/www"; }

		public WebServer  () {
			Object (port : 9999);

			assert (this != null);

			document_root = "/var/www";

//			var server = new Soup.Server (Soup.SERVER_PORT, 9999);
			this.add_handler (null, default_handler);
			// debug ("Running server async");
//			server.run_async ();

			var websocket = new WebSocket ("127.0.0.1", 9090);

		}

		public void default_handler (Server server, Soup.Message msg, string path, HashTable<string, string>? query, ClientContext client) {

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
				string full_path = document_root + path;

				File resource = File.new_for_path (full_path);
				resource.load_contents (null, out contents, out etag_out);
				msg.set_status (200);
				msg.set_response (mime_type, Soup.MemoryUse.COPY, contents);

				// debug ("Serving resource: %s", full_path);
			}
			catch (Error e) {
				stderr.printf ("Failed to load resource: %s\n", path);
				msg.set_status (404);
			}
		}
	}
}