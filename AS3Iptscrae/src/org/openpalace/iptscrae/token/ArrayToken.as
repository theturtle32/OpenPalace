package org.openpalace.iptscrae.token
{
	import org.openpalace.iptscrae.IptToken;

	public class ArrayToken extends IptToken
	{
		public var data:Vector.<IptToken>;
		
		public function ArrayToken(data:Vector.<IptToken> = null)
		{
			if (data == null) {
				data = new Vector.<IptToken>();
			}
			this.data = data;
		}
		
		override public function clone():IptToken {
			return new ArrayToken(data);
		}
	}
}