using Soup;

namespace CodeCat {
	
	public class WebServer : Soup.Server {

		public string document_root { get; set; default="/var/www"; }

		public string custom_web_server {get; set; default = ""; }

		protected uint8[] javascript;

		public WebServer  (int http_port) {
			Object (port : http_port);

			assert (this != null);

			document_root = "/var/www/html";

			this.add_handler (null, default_handler);

			try {
				string etag_out;
				File jsfile;

				jsfile = File.new_for_path("src/websocket_injection.js");
				jsfile.load_contents(null, out javascript, out etag_out);
			}
			catch (Error e) {
				stderr.printf("Failed to load javascript file for websocket injection\n");
			}
		}

		public void default_handler (Server server, Soup.Message msg, string path, HashTable<string, string>? query, ClientContext client) {

			string mime_type = "text/html";
			var request_headers = msg.request_headers;
			request_headers.foreach (( name, value) => {
				if ( name == "Accept"  && value != "*/*") {
					mime_type = value;
				}
			});

			try {
				uint8[] contents;
				string etag_out;
				File resource;

				if (custom_web_server.length == 0) {
					if (path == "/") {
						path = "/index.html";
					}
					resource = File.new_for_path (document_root + path);
				}
				else {
					resource = File.new_for_uri (custom_web_server + path);
					// debug ("Loading content from: " + custom_web_server + path);
				}

				resource.load_contents (null, out contents, out etag_out);

				// Get the resource's mime type
				FileInfo info;
				info = resource.query_info("*", 0);
				var mime = ContentType.get_mime_type(info.get_content_type());
				// debug ("Response MIME Type: " + mime);

				string pageload = (string)contents;

				if (Regex.match_simple("text/html", mime)/* && Regex.match_simple ("\\.html$", path)*/) {
					inject_websocket_connection (ref pageload);
				}

				msg.set_status (200);
				msg.set_response (mime, Soup.MemoryUse.COPY, pageload.data);
			}
			catch (Error e) {
				stderr.printf ("Failed to load resource: %s\n", document_root + path);
				msg.set_status (404);
			}
		}

		public void inject_websocket_connection (ref string html) {

			string[] parts = html.split("</head>", 2);

			if (parts.length == 2) {
				html = parts[0] + "<script>" + (string)this.javascript + "</script></head>" + parts[1];
			}
		}
	}
}