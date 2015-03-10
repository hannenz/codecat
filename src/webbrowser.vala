using Gtk;
using WebKit;

namespace CodeCat {

	public class WebBrowser : Container {

		// private Gtk.ScrolledWindow swin;

		public string url { get; set; default = "http://www.google.com"; }

		protected WebView view;

		public WebBrowser () {

/* 			this.view = new WebView ();
			this.view.open (url);

			this.swin = new Gtk.ScrolledWindow (null, null);
			this.swin.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
			this.swin.add (this.view);
			this.add (this.swin);
			this.show_all ();
 */		}
	}
}