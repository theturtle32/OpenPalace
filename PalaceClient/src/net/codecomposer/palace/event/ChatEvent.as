package net.codecomposer.palace.event
{
	import flash.events.Event;
	
	import net.codecomposer.palace.model.PalaceUser;

	public class ChatEvent extends Event
	{
		public var chatText:String;
		public var user:PalaceUser;
		
		public static const CHAT:String = "chat";
		
		public function ChatEvent(user:PalaceUser, chatText:String)
		{
			this.chatText = chatText;
			this.user = user;
			super(CHAT, false, true);
		}
		
	}
}