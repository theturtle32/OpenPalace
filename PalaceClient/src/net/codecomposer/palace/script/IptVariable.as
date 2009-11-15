package net.codecomposer.palace.script
{
	public class IptVariable
	{
		public var name:String;
		public var value:int;
		public var type:int;
		public var flags:int;
		
		public static const FLAG_GLOBAL:int = 0x01;
		public static const FLAG_SPECIAL_VARIABLE:int = 0x02;
		
		public function IptVariable(name:String = null, type:int = 0, value:int = 0, flags:int = 0)
		{
			this.name = name;
			this.type = type;
			this.value = value;
			this.flags = flags;
		}
	}
}