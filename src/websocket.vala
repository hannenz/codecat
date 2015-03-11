using Gee;
using Linux.Socket;

namespace CodeCat {
	
	public class WebSocket  {

		protected Socket master;

		protected ArrayList<Socket> sockets;

		protected ArrayList<string> users;

		public WebSocket (string address, uint16 port) {

			try {
				master = new Socket (SocketFamily.IPV4, SocketType.STREAM, SocketProtocol.TCP);
				master.set_option (SOL_SOCKET, SO_REUSEADDR, 1);

				var addr = new InetAddress.from_string (address);

				master.bind (new InetSocketAddress(addr, port), true);
				master.listen();

				say ("Server started on " + new DateTime.now_local ().format ("%F %T"));
				say ("Listening on      " + address + ":" + port.to_string ());
			}
			catch (Error e) {
				stderr.printf ("Failed to create socket: %s\n", e.message);
			}
		}

		public void say (string mssg) {
			print ("%s\n".printf(mssg));
		}
	}
}