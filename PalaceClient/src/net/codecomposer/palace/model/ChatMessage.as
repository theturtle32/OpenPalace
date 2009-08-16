package net.codecomposer.palace.model
{
	import net.codecomposer.palace.view.ChatBubble;

	public class ChatMessage
	{
		public var text:String;
		public var isWhisper:Boolean;
		public var x:int;
		public var y:int;
		public var tint:uint;
		public var user:PalaceUser;
		public var chatBubble:ChatBubble;
		
		public function ChatMessage()
		{
			
		}
	}
}