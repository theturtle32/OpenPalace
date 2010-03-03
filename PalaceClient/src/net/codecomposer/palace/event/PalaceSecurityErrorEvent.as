package net.codecomposer.palace.event
{
	import flash.events.Event;
	
	public class PalaceSecurityErrorEvent extends Event
	{
		public static const SECURITY_ERROR:String = "securityError";
		
		public function PalaceSecurityErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}