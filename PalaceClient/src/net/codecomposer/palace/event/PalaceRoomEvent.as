package net.codecomposer.palace.event
{
	import flash.events.Event;
	
	import net.codecomposer.palace.model.PalaceUser;

	public class PalaceRoomEvent extends Event
	{
		public var user:PalaceUser;
		
		public static const USER_ENTERED:String = "userEntered";
		public static const USER_LEFT:String = "userLeft";
		public static const ROOM_CLEARED:String = "roomCleared";
		
		public function PalaceRoomEvent(type:String, user:PalaceUser = null)
		{
			this.user = user;
			super(type, false, false);
		}
		
	}
}