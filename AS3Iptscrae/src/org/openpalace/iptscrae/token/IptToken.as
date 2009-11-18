package org.openpalace.iptscrae.token
{
	public class IptToken
	{
		public var scriptCharacterOffset:int;
		
		public function IptToken(characterOffset:int = -1)
		{
			scriptCharacterOffset = characterOffset;
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