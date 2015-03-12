using Gee;
using Linux.Socket;

namespace CodeCat {
	
	public class Source : Object {

		public uint16 port { private set; get;	 }

		public Source (uint16 port) {
			this.port = port;
		}
	}

	public class WebSocket  {

		public const uint16 PORT = 9090;

		protected SocketService service;

		private bool handshake = false;

		private string sec_websocket_key = "";

		private SocketConnection connection = null;

		private async void worker_func (SocketConnection connection,  Source source, Cancellable cancellable) {
			try {
				DataInputStream istream = new DataInputStream (connection.input_stream);
				DataOutputStream ostream = new DataOutputStream (connection.output_stream);

				// Get the received message
				InetSocketAddress remote_sock_addr = connection.get_remote_address () as InetSocketAddress;
				InetAddress remote_addr = remote_sock_addr.get_address ();

				stdout.printf ("## Receiving data from %s\n", remote_addr.to_string ());
				string message = "";
				do {
					message = yield istream.read_line_async (Priority.DEFAULT, cancellable);
					message._strip ();
					stdout.printf ("Received: %s\n", message);

					if (message.has_prefix ("Sec-WebSocket-Key:")) {
						string[] parts = message.split(" ");
						sec_websocket_key = parts[1];
						debug (sec_websocket_key);
					}

				} while (message.length > 0);

				// Response
				if (!handshake && sec_websocket_key.length > 0) {

					string cat = sec_websocket_key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
					var checksum = new Checksum (ChecksumType.SHA1);
					checksum.update (cat.data, cat.length);
					uint8[20] digest = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
					size_t digest_len = 20;
					checksum.get_digest (digest, ref digest_len);
					debug ("%d".printf((int)digest_len));

					string key = Base64.encode(digest);
					debug (key);

					ostream.put_string ("HTTP/1.1 101 Switching Protocols\r\n", cancellable);
					ostream.put_string ("Upgrade: websocket\r\n", cancellable);
					ostream.put_string ("Connection: Upgrade\r\n", cancellable);
					ostream.put_string ("Sec-WebSocket-Accept: %s\r\n".printf (key), cancellable);
					ostream.put_string ("\r\n", cancellable);

					handshake = true;
					this.connection = connection;
				}
			}
			catch (Error e) {
				stderr.printf ("Error: %s\n", e.message);
			}		
		}

		public WebSocket () {

			try {
				service = new SocketService ();
				service.add_inet_port (PORT, new Source (PORT));
				Cancellable cancellable = new Cancellable ();
				cancellable.cancelled.connect ( () => {
						service.stop ();
					});

				service.incoming.connect ( (connection, source_object) => {
						Source source = source_object as Source;
						debug ("Accepted! (Source: %d)\n", source.port);
						worker_func.begin (connection, source, cancellable);
						return false;
					});
			}
			catch (Error e) {
				stderr.printf ("Error: %s\n", e.message);
			}
		}

		public void start () {
			service.start ();
		}

		public void send (string message) {
			assert (connection != null);
			var ostream = new DataOutputStream (connection.output_stream);
			ostream.put_string (message, null);
		}

		// protected Socket master;

		// protected ArrayList<Socket> sockets;

		// protected ArrayList<string> users;

		// public WebSocket (string address, uint16 port) {

		// 	try {
		// 		master = new Socket (SocketFamily.IPV4, SocketType.STREAM, SocketProtocol.TCP);
		// 		master.set_option (SOL_SOCKET, SO_REUSEADDR, 1);

		// 		var addr = new InetAddress.from_string (address);

		// 		master.bind (new InetSocketAddress(addr, port), true);
		// 		master.listen();

		// 		say ("Server started on " + new DateTime.now_local ().format ("%F %T"));
		// 		say ("Listening on      " + address + ":" + port.to_string ());
		// 	}
		// 	catch (Error e) {
		// 		stderr.printf ("Failed to create socket: %s\n", e.message);
		// 	}
		// }

		// public void say (string mssg) {
		// 	print ("%s\n".printf(mssg));
		// }
	}
}