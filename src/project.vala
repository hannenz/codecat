namespace CodeCat {

	public class Project : Object {

		public string name { get; set; default=""; }

		public string path { get; set; default=""; }

		public string custom_web_server { get; set; default=""; }

		public int http_port { get; set; default = 8000; }

		public WebServer server;

		public bool running { get; set; default = false; }

		public Project (int http_port) {
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
		}

		public void stop () {

			debug ("Stopping WebServer on Port %u".printf(http_port));

			server.quit ();
			running = false;
		}
	}
}