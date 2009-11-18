package org.openpalace.iptscrae
{
	public class IptError extends Error
	{
		public var characterOffset:int;
		
		public function IptError(message:String, characterOffset:int = -1, id:*=0)
		{
			super(message, id);
			this.characterOffset = characterOffset;
		}
	}
}