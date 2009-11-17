package org.openpalace.iptscrae
{
	public class IptToken
	{
		public function IptToken()
		{
		}
		
		public function clone():IptToken {
			return new IptToken();
		}
		
		public function toBoolean():Boolean {
			return true;
		}
	}
}