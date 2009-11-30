package org.openpalace.iptscrae.token
{
	import org.openpalace.iptscrae.IptToken;

	public class ArrayToken extends IptToken
	{
		// Had used Vector.<IptToken> but for some reason, Vector.unshift()
		// doesn't work when running under Croatian Windows 7. 
		public var data:Array;
		
		public function ArrayToken(data:Array = null, characterOffset:int = -1)
		{
			super(characterOffset);
			if (data == null) {
				data = [];
			}
			this.data = data;
		}
		
		override public function clone():IptToken {
			return new ArrayToken(data);
		}
		
		override public function toString():String {
			var string:String = "[ArrayToken length=" + data.length + "]\n";
			for each (var token:IptToken in data) {
				string += (" - " + token.toString() + "\n");
			}
			return string;
		}
	}
}