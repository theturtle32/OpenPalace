package net.codecomposer.palace.event
{
	import flash.events.Event;
	
	import net.codecomposer.palace.model.PalaceHotspot;

	public class HotspotEvent extends Event
	{
		public static const STATE_CHANGED:String = "stateChanged";
		public static const MOVED:String = "moved";
		
		public var state:int;
				
		public function HotspotEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}