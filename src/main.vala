using Sass;

namespace CodeCat {

	public static int main (string[] args) {

		stdout.printf("LibSass Version: %s\n", Sass.version());

		var opt = new SassOption();
		opt.set_precision(6);
		opt.set_output_style(OutputStyle.COMPRESSED);

		stdout.printf("Precision: %u\nOutput Style: %u", opt.get_precision(), opt.get_output_style());


		var app = new CodeCat ();
		return app.run ();
	}
}
