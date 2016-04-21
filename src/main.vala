using Sass;

namespace CodeCat {

	public static int main (string[] args) {

		stdout.printf("LibSass Version: %s\n", Sass.version());
		// var opt = new Sass.Options();
		// opt.set_precision(6);
		// opt.set_output_style(OutputStyle.COMPRESSED);
		// stdout.printf("Precision: %u\nOutput Style: %u", opt.get_precision(), opt.get_output_style());


		var ctx = new Sass.FileContext("/var/www/html/wlb/sass/main.scss");
		var opt = ctx.get_options();
		opt.set_precision(1);
		opt.set_source_comments(true);
		ctx.set_options(opt);

		var compiler = new Sass.Compiler.from_file_context(ctx);
		compiler.parse();
		compiler.execute();

		var ctx2 = ctx.get_context();

		var output = ctx2.get_output_string();

		var error_status = ctx2.get_error_status();

		stdout.printf("%s\n", output);
		stdout.printf("%u\n", error_status);

		return 0;

		var app = new CodeCat ();
		return app.run ();
	}
}
