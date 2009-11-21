package org.openpalace.iptscrae.token
{
	import org.openpalace.iptscrae.IptToken;
	
	public class StringToken extends IptToken
	{
		public var data:String;
		
		public function StringToken(value:String, characterOffset:int = -1)
		{
			super(characterOffset);
			data = value;
		}
		
		public override function clone():IptToken {
			return new StringToken(data);
		}
		
		override public function toString():String {
			return "[StringToken value=\"" + data + "\"]";
		}
	}
}