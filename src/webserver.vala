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

				// debug ("Serving resource: %s", full_path);

				File resource = File.new_for_path (full_path);
				resource.load_contents (null, out contents, out etag_out);

				string pageload = (string)contents;

				if (Regex.match_simple("text/html", mime_type) && Regex.match_simple ("\\.html$", path)) {
					inject_websocket_connection (ref pageload);
				}

				msg.set_status (200);
				msg.set_response (mime_type, Soup.MemoryUse.COPY, pageload.data);
			}
			catch (Error e) {
				stderr.printf ("Failed to load resource: %s\n", path);
				msg.set_status (404);
			}
		}

		public void inject_websocket_connection (ref string html) {
			// debug ("HTML: %s\n", html);
			string javascript = "<script>var ws = new WebSocket('localhost', 9090); ws.onmessage = function (e){ console.log (e.data); location.reload(); }; </script></head>";	

				string[] parts = html.split("</head>", 2);

			// debug (parts[0]);

			if (parts.length == 2) {
				html = parts[0] + javascript + parts[1];
			}
			// debug (html);
		}
	}
}