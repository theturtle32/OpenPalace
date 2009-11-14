package net.codecomposer.palace.script
{
	public class IptAtom
	{
		public var type:int;
		public var value:int;
		
		public function IptAtom(type:int = 0, value:int = 0)
		{
			this.type = type;
			this.value = value;
		}
		
		public function cloneAtom():IptAtom {
			return new IptAtom(type, value);
		}
	}
}