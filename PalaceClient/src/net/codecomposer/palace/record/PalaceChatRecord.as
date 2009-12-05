package net.codecomposer.palace.record
{
	public class PalaceChatRecord
	{
		public static const INCHAT:int = 0;
		public static const OUTCHAT:int = 1;
		
		public var direction:int;
		public var whochat:int;
		public var whotarget:int;
		public var chatstr:String;
		
		public function PalaceChatRecord(direction:int = INCHAT, whochat:int = 0, whotarget:int = 0, chatstr:String = "")
		{
			this.direction = direction;
			this.whochat = whochat;
			this.whotarget = whotarget;
			this.chatstr = chatstr;			
		}
		
		public function get whisper():Boolean {
			return whotarget != 0;
		}
	}
}