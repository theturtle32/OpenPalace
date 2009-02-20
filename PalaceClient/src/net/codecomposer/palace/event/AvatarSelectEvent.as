package net.codecomposer.palace.event
{
	import flash.events.Event;

	public class AvatarSelectEvent extends Event
	{
		public static const AVATAR_SELECT:String = "avatarSelect";
		public var userId:int = -1;
		public function AvatarSelectEvent(type:String, userId:int)
		{
			this.userId = userId;
			super(AVATAR_SELECT, false, true);
		}
		
	}
}