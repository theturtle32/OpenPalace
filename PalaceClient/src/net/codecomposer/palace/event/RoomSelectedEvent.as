package net.codecomposer.palace.event
{
	import flash.events.Event;

	public class RoomSelectedEvent extends Event
	{
		public var roomID:int = -1;
		public function RoomSelectedEvent(bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super("roomSelected", bubbles, cancelable);
		}
		
	}
}