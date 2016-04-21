namespace CodeCat {

	public class Project : Object {

		public string name { get; set; default=""; }

		public string path { get; set; default=""; }

		public string custom_web_server { get; set; default=""; }

		public Project () {

		}
	}
}