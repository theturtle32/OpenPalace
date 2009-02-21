package net.codecomposer.palace
{
	import net.codecomposer.palace.rpc.PalaceClient;
	
	public class Palace
	{
		private var _client:PalaceClient = PalaceClient.getInstance();
		
		public function Palace()
		{
		}
		
		public function get client():PalaceClient {
			return _client;
		}

	}
}