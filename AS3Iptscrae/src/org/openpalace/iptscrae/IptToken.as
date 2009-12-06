package org.openpalace.iptscrae
{
	import flash.events.EventDispatcher;

	public class IptToken extends EventDispatcher
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
		
		override public function toString():String {
			return "[" + IptUtil.className(this) + "]";
		}
	}
}