package org.openpalace.iptscrae.token
{
	
	public class IntegerToken extends IptToken
	{
		public var data:int;
		
		public function IntegerToken(value:int = 0, characterOffset:int = -1)
		{
			super(characterOffset);
			data = value;
		}
		
		override public function clone():IptToken {
			return new IntegerToken(data); 
		}
		
		override public function toBoolean():Boolean {
			return Boolean(data != 0);
		}
	}
}