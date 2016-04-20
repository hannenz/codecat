[CCode (cheader_filename = "sass/context.h")]
namespace Sass {
	[CCode (cname = "libsass_version")]
	public unowned string version ();

	[CCode (cname = "enum Sass_Output_Style", cprefix = "SASS_STYLE_")]
	public enum OutputStyle {
		NESTED,
		EXPANDED,
		COMPACT,
		COMPRESSED
	}

	[CCode (cname = "struct Sass_Options", free_function = "")]
	[Compact]
	public class SassOption {

		[CCode (cname = "sass_make_options")]
		public SassOption();

		[CCode (cname="sass_option_get_precision")]
		public int get_precision();

		[CCode (cname="sass_option_set_precision")]
		public void set_precision(int precision);

		[CCode (cname="sass_option_get_output_style")]
		public OutputStyle get_output_style();

		[CCode (cname="sass_option_set_output_style")]
		public void set_output_style(OutputStyle style);
	}
}