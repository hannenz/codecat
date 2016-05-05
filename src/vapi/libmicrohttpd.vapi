[CCode (cheader_filename = "microhttpd.h")]
namespace MHD {

	[CCode (cname = "enum MHD_FLAG", cprefix = "MHD_")]
	public enum Flag {
		NO_FLAG,
		USE_DEBUG,
		USE_SSEL,
		USE_THREAD_PER_CONNECTION,
		USE_SELECT_INTERNALLY,
		USE_IPv6,
		USE_DUAL_STACK,
		USE_PEDANTIC_CHECKS,
		USE_POLL,
		USE_EPOLL_LINUX_ONLY,
		SUPPRESS_DATE_NO_CLOCK,
		USE_NO_LISTEN_SOCKET,
		USE_PIPE_FOR_SHUTDOWN,
		USE_SUSPEND_RESUME,
		USE_TCP_FASTOPEN
	}

	[CCode (cname = "enum MHD_OPTION", cprefix = "MHD_OPTION_")]
	public enum Option {
		END,
		CONNECTION_MEMORY_LIMIT,
		CONNECTION_MEMORY_INCREMENT,
		CONNECTION_LIMIT,
		CONNECTION_TIMEOUT,
		NOTIFY_COMPLETED,
		NOTIFY_CONNECTION,
		PER_IP_CONNECTION_LIMIT,
		SOCK_ADDR,
		URI_LOG_CALLBACK,
		HTTPS_MEM_KEY,
		HTTPS_KEY_PASSWORD,
		HTTPS_MEM_CERT,
		HTTPS_MEM_TRUST,
		HTTPS_CRED_TYPE,
		HTTPS_PRIORITIES,
		HTTPS_CERT_CALLBACK,
		DIGEST_AUTH_RANDOM,
		NONCE_NC_SIZE,
		LISTEN_SOCKET,
		EXTERNAL_LOGGER,
		THREAD_POOL_SIZE,
		ARRAY,
		UNESCAPE_CALLBACK,
		THREAD_STACK_SIZE,
		TCP_FASTQUEUE_QUEUE_SIZE,
		HTTPS_MEM_DHPARAMS,
		LISTENING_ADDRESS_REUSE
	}

	[CCode (cname = "enum MHD_ValueKind", cprefix = "MHD_")]
	public enum ValueKind {
		RESPONSE_HEADER_KIND,
		HEADER_KIND,
		COOKIE_KIND,
		POSTDATA_KIND,
		GET_ARGUMENT_KIND,
		FOOTER_KIND
	}

	[CCode (cname = "enum MHD_RequestTerminationCode", cprefix = "MHD_REQUEST_TERMINATED_")]
	public enum RequestTerminationCode {
		COMPLETED_OK,
		WITH_ERROR,
		TIMEOUT_REACHED,
		DAEMON_SHUTDOWN
	}
	[CCode (cname = "enum MHD_ResponseMemoryMode", cprefix = "MHD_RESPMEM_")]
	public enum ResponseMemoryMode {
		PERSISTENT,
		MUST_FREE,
		MUST_COPY
	}

	[CCode (cname = "enum MHD_ResponseFlags", cprefix = "MHD_RF_")]
	public enum ResponseFlags {
		NONE,
		HTTP_VERSION_1_0_ONLY
	}

	[CCode (cname = "enum MHD_ResponseOptions", cprefix = "MHD_RO_")]
	public enum ResponseOptions {
		END
	}


	// Delegates (Callbacks)
	[CCode (cname = "MHD_AcceptPolicyCallback", has_target = true, delegate_target_pos=0)]
	public delegate AcceptPolicyCallback ()


	[CCode (cname = "struct MHD_Daemon", free_function = "")]
	[Compact]
	public class Daemon {

		[CCode (cname = "MHD_start_daemon")]
		public Daemon (Flag flags, int port, ...);


	}
}