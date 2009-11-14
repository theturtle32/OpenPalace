package net.codecomposer.palace.script
{
	public class IptVariable
	{
		public var name:String;
		public var value:int;
		public var type:int;
		public var flags:int;
		
		public function IptVariable(name:String = null, type:int = 0, value:int = 0, flags:int = 0)
		{
			this.name = name;
			this.type = type;
			this.value = value;
			this.flags = flags;
		}
	}
}