package org.openpalace.iptscrae.token
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
		
		public function dereference():IptToken {
			return this;
		}
	}
}