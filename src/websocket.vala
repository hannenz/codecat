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

		public HashMap<string, Socket> sockets;

		public bool on_socket_in (Socket socket, IOCondition condition) {

			try {

				// Accept non-connected socekts
				if (!socket.is_connected ()) {
					Socket conn = socket.accept ();
					SocketSource src = conn.create_source (IOCondition.IN, null);
					src.set_callback (on_socket_in);
					src.attach (MainContext.default ());
					return true;
				}

				debug ("%d sockets", sockets.size);

				// Read payload data
				uint8 inbuffer[4096];

				socket.receive (inbuffer, null);

				debug ((string)inbuffer);

				switch (inbuffer[0] & 0x0f) {
					case 0x08:
					// Handle close requests from clients
						debug ("Received a CLOSE opcode");

						// Search in sockets
						var it = sockets.map_iterator ();
						it.foreach ( (key, value) => {
								if (value == socket) {
									// Close socket and remove
									debug ("Closing %s\n", key);
									socket.close ();
									sockets.unset (it.get_key());
									return false;
								}
								return true;
							});
						break;
					case 0x09:
						debug ("Received a PING"); 
						break;
					case 0x0a:
						debug ("Received a PONG"); 
						break;
				}

				string message = (string)inbuffer;
				string sec_websocket_key = null;
				string[] lines = message.split("\r\n");

				foreach (var line in lines) {
					if (line.has_prefix ("Sec-WebSocket-Key:")) {
						string[] parts = line.split(" ");
						sec_websocket_key = parts[1];
						break;
					}
				}

				if (sec_websocket_key != null) {

					if (!sockets.has_key(sec_websocket_key)) {
						debug ("Shaking hands with %s", sec_websocket_key);
						string cat = sec_websocket_key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
						var checksum = new Checksum (ChecksumType.SHA1);
						checksum.update (cat.data, cat.length);
						uint8 digest[20];
						size_t digest_len = 20;
						checksum.get_digest (digest, ref digest_len);
						string key = Base64.encode(digest);
						string header = 
						"HTTP/1.1 101 Switching Protocols\r\n" +
						"Upgrade: websocket\r\n" +
						"Connection: Upgrade\r\n" +
						"Sec-WebSocket-Accept: %s\r\n".printf (key) +
						"\r\n";

						socket.send (header.data);
						socket.set_data ("sec_websocket_key", sec_websocket_key);
						debug ("Adding socket for %s", sec_websocket_key);
						sockets.set(sec_websocket_key, socket);
					}
				}
			}
			catch (Error e) {
				stderr.printf("Error: %s\n", e.message);
			}
			return true;
		}

		public WebSocket (string address, uint16 port) {
			try {

				sockets = new HashMap<string, Socket> ();

				var socket = new Socket (SocketFamily.IPV4, SocketType.STREAM, SocketProtocol.TCP);
		 		socket.set_option (SOL_SOCKET, SO_REUSEADDR, 1);
				socket.blocking = false;
				assert (socket != null);

				var addr = new InetAddress.from_string (address);
				socket.bind (new InetSocketAddress(addr, port), true);
				socket.set_listen_backlog (10);
				socket.listen ();

				SocketSource source = socket.create_source (IOCondition.OUT | IOCondition.IN, null);
				source.set_callback (on_socket_in);
				source.attach (MainContext.default ());

			}
			catch (Error e) {
				stderr.printf("Error: %s\n", e.message);
			}
		}

		public void send (string message) {

			uint8 len = (uint8)message.length, frame[8192];
			uint index = -1;


			frame[0] = 129;
			if (message.length <= 125) {
				frame[1] = len;
				index = 2;
			}
			else if (len >= 126 && len <= 65535) {
				frame[1] = 126;
				frame[2] = (len >> 8) & 255;
				frame[3] = (len) & 255;
				index = 4;
			}
			else {
				frame[1] = 127;
				frame[2] = (len >> 56) & 255;
				frame[3] = (len >> 48) & 255;
				frame[4] = (len >> 40) & 255;
				frame[5] = (len >> 32) & 255;
				frame[6] = (len >> 24) & 255;
				frame[7] = (len >> 16) & 255;
				frame[8] = (len >> 8) & 255;
				frame[9] = (len) & 255;
				index = 10;
			}

			for (int i = 0; i < len; i++) {
				frame[index + i] = message.data[i];
			}

			foreach (Socket socket in sockets.values) {
				try {
					socket.send (frame);
				}
				catch (Error e) {
					stderr.printf("Error: %s\n", e.message);
				}
			}
		}

	}
}