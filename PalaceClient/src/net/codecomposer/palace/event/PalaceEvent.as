package net.codecomposer.palace.event
{
	import flash.events.Event;
	
	public class PalaceEvent extends Event
	{
		public static const ROOM_CHANGED:String = "roomChanged";
		
		public function PalaceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}