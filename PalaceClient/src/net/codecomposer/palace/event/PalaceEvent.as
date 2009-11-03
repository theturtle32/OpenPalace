package net.codecomposer.palace.event
{
	import flash.events.Event;
	
	public class PalaceEvent extends Event
	{
		public static const ROOM_CHANGED:String = "roomChanged";
		
		public static const CONNECT_START:String = "connectStart";
		public static const CONNECT_COMPLETE:String = "connectComplete";
		public static const CONNECT_FAILED:String = "connectFailed";
		public static const DISCONNECTED:String = "disconnected";
		
		public var text:String;
		
		public function PalaceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}