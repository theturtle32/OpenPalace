package net.codecomposer.palace.model
{
	import net.codecomposer.palace.view.ChatBubble;

	public class ChatMessage
	{
		private var _text:String;
		public var isWhisper:Boolean;
		private var _x:int;
		private var _y:int;
		public var tint:uint;
		public var user:PalaceUser;
		public var chatBubble:ChatBubble;
		
		private static const locationRegex:RegExp = /^\@([\d]+),([\d]+)\s*(.*)$/; 
		
		public function set text(newValue:String):void {
			_text = newValue;
		}
		
		public function get text():String {
			if (_text) {
				var match:Array = _text.match(locationRegex);
				if (match && match.length > 3) {
					return match[3];
				}
				else {
					return _text;
				}
			}
			return "";
		}
		
		public function get rawText():String {
			return _text ? _text : "";
		}
		
		public function get x():int {
			var match:Array = _text.match(locationRegex);
			if (match && match.length > 0) {
				return int(match[1]);
			}
			return _x;
		}
		
		public function set x(newValue:int):void {
			_x = newValue;
		}
		
		public function get y():int {
			var match:Array = _text.match(locationRegex);
			if (match && match.length > 0) {
				return int(match[2]);
			}
			return _y;
		}
		
		public function set y(newValue:int):void {
			_y = newValue;
		}
		
		public function ChatMessage()
		{
			
		}
	}
}