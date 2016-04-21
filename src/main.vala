using Sass;

namespace CodeCat {

	public static int main (string[] args) {

		uint8[] page;
		string etag_out;

		// File f = File.new_for_uri("http://wolfgang-braun.localhost/");
		// f.load_contents(null, out page, out etag_out);
		// stdout.printf("%s\n", (string)page);

		stdout.printf("LibSass Version: %s\n", Sass.version());

		var app = new CodeCat ();
		return app.run ();
	}
}
