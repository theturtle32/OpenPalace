package net.codecomposer.palace.iptscrae
{
	import org.openpalace.iptscrae.IptTokenList;

	public class IptEventHandler
	{
		public static const TYPE_SELECT:int = 0;
		public static const TYPE_LOCK:int = 1;
		public static const TYPE_UNLOCK:int = 2;
		public static const TYPE_HIDE:int = 3; // Unused
		public static const TYPE_SHOW:int = 4; // Unused
		public static const TYPE_STARTUP:int = 5; // Unused
		public static const TYPE_ALARM:int = 6;
		public static const TYPE_CUSTOM:int = 7; // Unused
		public static const TYPE_INCHAT:int = 8;
		public static const TYPE_PROPCHANGE:int = 9; // Unused
		public static const TYPE_ENTER:int = 10;
		public static const TYPE_LEAVE:int = 11;
		public static const TYPE_OUTCHAT:int = 12;
		public static const TYPE_SIGNON:int = 13;
		public static const TYPE_SIGNOFF:int = 14;
		public static const TYPE_MACRO0:int = 15;
		public static const TYPE_MACRO1:int = 16;
		public static const TYPE_MACRO2:int = 17;
		public static const TYPE_MACRO3:int = 18;
		public static const TYPE_MACRO4:int = 19;
		public static const TYPE_MACRO5:int = 20;
		public static const TYPE_MACRO6:int = 21;
		public static const TYPE_MACRO7:int = 22;
		public static const TYPE_MACRO8:int = 23;
		public static const TYPE_MACRO9:int = 24;
		public static const TYPE_PPA_MACRO:int = 25; // ?? Unused.. PalacePresents
		public static const TYPE_UNHANDLED:int = 27;
		public static const TYPE_PPA_MESSAGE:int = 32; // Unused... PalacePresents Message
		
		public static const EVENT_NAME:Object = {
			0: "SELECT",
			1: "LOCK",
			2: "UNLOCK",
			3: "HIDE",
			4: "SHOW",
			5: "STARTUP",
			6: "ALARM",
			7: "CUSTOM",
			8: "INCHAT",
			9: "PROPCHANGE",
			10: "ENTER",
			11: "LEAVE",
			12: "OUTCHAT",
			13: "SIGNON",
			14: "SIGNOFF",
			15: "MACRO0",
			16: "MACRO1",
			17: "MACRO2",
			18: "MACRO3",
			19: "MACRO4",
			20: "MACRO5",
			21: "MACRO6",
			22: "MACRO7",
			23: "MACRO8",
			24: "MACRO9",
			25: "PPA_MACRO",
			27: "UNHANDLED",
			32: "PPA_MESSAGE"
		};
		
		public var eventType:int;
		[Bindable]
		public var script:String;
		public var tokenList:IptTokenList;
		
		public static function getEventType(token:String):int
		{
			switch (token) {
				case "SELECT":
					return IptEventHandler.TYPE_SELECT;
					break;
				case "LOCK":
					return IptEventHandler.TYPE_LOCK;
					break;
				case "UNLOCK":
					return IptEventHandler.TYPE_UNLOCK;
					break;
				case "ALARM":
					return IptEventHandler.TYPE_ALARM;
					break;
				case "INCHAT":
					return IptEventHandler.TYPE_INCHAT;
					break;
				case "ENTER":
					return IptEventHandler.TYPE_ENTER;
					break;
				case "LEAVE":
					return IptEventHandler.TYPE_LEAVE;
					break;
				case "OUTCHAT":
					return IptEventHandler.TYPE_OUTCHAT;
					break;
				case "SIGNON":
					return IptEventHandler.TYPE_SIGNON;
					break;
				case "SIGNOFF":
					return IptEventHandler.TYPE_SIGNOFF;
					break;
				case "MACRO0":
					return IptEventHandler.TYPE_MACRO0;
					break;
				case "MACRO1":
					return IptEventHandler.TYPE_MACRO1;
					break;
				case "MACRO2":
					return IptEventHandler.TYPE_MACRO2;
					break;
				case "MACRO3":
					return IptEventHandler.TYPE_MACRO3;
					break;
				case "MACRO4":
					return IptEventHandler.TYPE_MACRO4;
					break;
				case "MACRO5":
					return IptEventHandler.TYPE_MACRO5;
					break;
				case "MACRO6":
					return IptEventHandler.TYPE_MACRO6;
					break;
				case "MACRO7":
					return IptEventHandler.TYPE_MACRO7;
					break;
				case "MACRO8":
					return IptEventHandler.TYPE_MACRO8;
					break;
				case "MACRO9":
					return IptEventHandler.TYPE_MACRO9;
					break;
				default:
					return IptEventHandler.TYPE_UNHANDLED;
					break;
			}
		}
		
		public function get label():String {
			var name:String = EVENT_NAME[eventType];
			return (name) ? name : "(unknown event)";
		}
		
		public function IptEventHandler(type:int = 0, script:String = null, tokenList:IptTokenList = null)
		{
			this.eventType = type;
			this.script = script;
			this.tokenList = tokenList;
		}
	}
}