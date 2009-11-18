package org.openpalace.iptscrae.token
{

	public class ArrayToken extends IptToken
	{
		public var data:Vector.<IptToken>;
		
		public function ArrayToken(data:Vector.<IptToken> = null, characterOffset:int = -1)
		{
			super(characterOffset);
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