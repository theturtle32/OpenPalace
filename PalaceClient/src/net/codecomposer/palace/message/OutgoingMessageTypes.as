package net.codecomposer.palace.message
{
	public final class OutgoingMessageTypes
	{
		// ----------------------------------------------------------------------
		// To Server
		// ----------------------------------------------------------------------
		public static const BYE:int = 0x62796520;
		public static const PING_BACK:int = 0x706f6e67;
		public static const SAY:int = 0x78746c6b;
		public static const WHISPER:int = 0x78776973;
		public static const MOVE:int = 1967943523;
		public static const REQUEST_ROOM_LIST:int = 0x724c7374;
		public static const GOTO_ROOM:int = 0x6e617652;
		public static const REQUEST_USER_LIST:int = 0x754c7374;
		public static const REQUEST_ASSET:int = 0x71417374;
	}
}