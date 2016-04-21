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
	[CCode (cname = "enum Sass_Compiler_State", cprefix = "SASS_COMPILER_STATE_")]
	public enum CompilerState {
		CREATED,
		PARSED,
		EXECUTED
	}

	[CCode (cname = "struct Sass_Options", free_function = "")]
	[Compact]
	public class Options {

		[CCode (cname = "sass_make_options")]
		public Options();

		[CCode (cname="sass_option_get_precision")]
		public int get_precision();


		[CCode (cname="sass_option_get_output_style")]
		public OutputStyle get_output_style();

		[CCode (cname="sass_option_get_commentes")]
		public bool get_source_comments();

		[CCode (cname="sass_option_get_source_map_embed")]
		public bool get_source_map_embed();

		[CCode (cname="sass_option_get_source_map_contents")]
		public bool get_source_map_contents();

		[CCode (cname="sass_option_get_omit_source_map_url")]
		public bool get_omit_source_map_url();

		[CCode (cname="sass_option_get_is_indented_syntax_src")]
		public bool get_is_indented_syntax_src();

		[CCode (cname="sass_option_get_indent")]
		public string get_indent();

		[CCode (cname = "sass_option_get_linefeed")]
		public string get_linefeed();

		[CCode (cname = "sass_option_get_input_path")]
		public string get_input_path();
		
		[CCode (cname = "sass_option_get_output_path")]
		public string get_output_path();
		
		[CCode (cname = "sass_option_get_plugin_path")]
		public string get_plugin_path();
		
		[CCode (cname = "sass_option_get_include_path")]
		public string get_include_path();
		
		[CCode (cname = "sass_option_get_source_map_file")]
		public string get_source_map_file();
		
		[CCode (cname = "sass_option_get_source_map_root")]
		public string get_source_map_root();


		[CCode (cname="sass_option_set_precision")]
		public void set_precision(int precision);

		[CCode (cname="sass_option_set_output_style")]
		public void set_output_style(OutputStyle style);

		[CCode (cname = "sass_option_set_source_comments")]
		public void set_source_comments(bool source_comments);
		
		[CCode (cname = "sass_option_set_source_map_embed")]
		public void set_source_map_embed(bool source_map_embed);
		
		[CCode (cname = "sass_option_set_source_map_contents")]
		public void set_source_map_contents(bool source_map_contents);
		
		[CCode (cname = "sass_option_set_omit_source_map_url")]
		public void set_omit_source_map_url(bool omit_source_map_url);
		
		[CCode (cname = "sass_option_set_is_indented_syntax_src")]
		public void set_is_indented_syntax_src(bool is_indented_syntax_src);
		
		[CCode (cname = "sass_option_set_indent")]
		public void set_indent(string indent);
		
		[CCode (cname = "sass_option_set_linefeed")]
		public void set_linefeed(string linefeed);
		
		[CCode (cname = "sass_option_set_input_path")]
		public void set_input_path(string input_path);
		
		[CCode (cname = "sass_option_set_output_path")]
		public void set_output_path(string output_path);
		
		[CCode (cname = "sass_option_set_plugin_path")]
		public void set_plugin_path(string plugin_path);
		
		[CCode (cname = "sass_option_set_include_path")]
		public void set_include_path(string include_path);
		
		[CCode (cname = "sass_option_set_source_map_file")]
		public void set_source_map_file(string source_map_file);
		
		[CCode (cname = "sass_option_set_source_map_root")]
		public void set_source_map_root(string source_map_root);

		[CCode (cname = "sass_option_push_plugin_path")]
		public void push_plugin_path(string path);

		[CCode (cname = "sass_option_push_include_path")]
		public void push_include_path(string path);
	}


	[CCode (cname = "struct Sass_Context", free_function = "")]
	[Compact]
	public class Context {

		[CCode (cname = "sass_context_get_options")]
		public Options get_options();

		[CCode (cname = "sass_context_get_output_string")]
		public string get_output_string();

		[CCode (cname = "sass_context_get_error_status")]
		public int get_error_status();

		[CCode (cname = "sass_context_get_error_json")]
		public string get_error_json();

		[CCode (cname = "sass_context_get_error_text")]
		public string get_error_text();

		[CCode (cname = "sass_context_get_error_message")]
		public string get_error_message();

		[CCode (cname = "sass_context_get_error_file")]
		public string get_error_file();

		[CCode (cname = "sass_context_get_error_src")]
		public string get_error_src();

		[CCode (cname = "sass_context_get_error_line")]
		public int get_error_line();

		[CCode (cname = "sass_context_get_error_column")]
		public int get_error_column();

		[CCode (cname = "sass_context_get_source_map_string")]
		public string get_source_map_string();

		[CCode (cname = "sass_context_get_included_files")]
		public string[] get_included_files();
	}

	[CCode (cname = "struct Sass_File_Context", free_function = "sass_delete_file_context")]
	[Compact]
	public class FileContext {
		[CCode (cname = "sass_make_file_context")]
		public FileContext(string input_path);

		[CCode (cname = "sass_compile_file_context")]
		public int compile();

		[CCode (cname = "sass_file_context_get_options")]
		public Options get_options();

		[CCode (cname = "sass_file_context_set_options")]
		public void set_options(Options options);

		[CCode (cname = "sass_file_context_get_context")]
		public Context get_context();
	}

	[CCode (cname = "struct Sass_Data_Context", free_function = "sass_delete_data_context")]
	[Compact]
	public class DataContext {
		[CCode (cname = "sass_make_data_context")]
		public DataContext(string source_string);

		[CCode (cname = "sass_compile_data_context")]
		public int compile();

		[CCode (cname = "sass_data_context_get_options")]
		public Options get_options();

		[CCode (cname = "sass_data_context_set_options")]
		public void set_options(Options options);

		[CCode (cname = "sass_data_context_get_context")]
		public Context get_context();
	}

	[CCode (cname = "struct Sass_Compiler", free_function = "sass_delete_compiler")]
	[Compact]
	public class Compiler {
		[CCode (cname = "sass_make_file_compiler")]
		public Compiler.from_file_context(FileContext ctx);

		[CCode (cname = "sass_make_data_compiler")]
		public Compiler.from_data_context(DataContext ctx);

		[CCode (cname = "sass_compiler_parse")]
		public int parse();

		[CCode (cname = "sass_compiler_execute")]
		public int execute();

		[CCode (cname = "sass_compiler_get_state")]
		public CompilerState get_state();

		[CCode (cname = "sass_compiler_get_options")]
		public Options get_options();

		[CCode (cname = "sass_compiler_get_import_stack_size")]
		public int get_import_stack_size();
	}
}