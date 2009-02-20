package net.codecomposer.palace
{
	import net.codecomposer.palace.rpc.PalaceSocket;
	
	public class Palace
	{
		private var _client:PalaceSocket = PalaceSocket.getInstance();
		
		public function Palace()
		{
		}
		
		public function get client():PalaceSocket {
			return _client;
		}

	}
}