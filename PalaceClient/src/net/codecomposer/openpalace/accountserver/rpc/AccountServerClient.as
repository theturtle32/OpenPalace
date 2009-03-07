package net.codecomposer.openpalace.accountserver.rpc
{
	public class AccountServerClient
	{
		private static var _instance:AccountServerClient;
		
		public function AccountServerClient()
		{
			if (_instance != null) {
				throw new Error("You cannot create more than one instance of AccountServerClient");
			}
			_instance = this;
		}

		public static function getInstance():AccountServerClient {
			if (_instance == null) {
				new AccountServerClient();
			}
			return _instance;
		}

	}
}