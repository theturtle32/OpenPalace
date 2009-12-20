package net.codecomposer.palace.record
{
	import org.openpalace.iptscrae.IptTokenList;

	public class PalaceChatRecord
	{
		public static const INCHAT:int = 0;
		public static const OUTCHAT:int = 1;
		
		public var direction:int;
		public var whochat:int;
		public var whotarget:int;
		public var chatstr:String;
		public var whisper:Boolean;
		public var eventHandlers:Vector.<IptTokenList>;
		private var _originalChatstr:String;
		
		public function PalaceChatRecord(direction:int = INCHAT, whochat:int = 0, whotarget:int = 0, chatstr:String = "", isWhisper:Boolean = false)
		{
			this.direction = direction;
			this.whochat = whochat;
			this.whotarget = whotarget;
			this.chatstr = chatstr;
			this.whisper = isWhisper;
			this._originalChatstr = chatstr;
		}
		
		public function get originalChatstr():String {
			return _originalChatstr;
		}
	}
}