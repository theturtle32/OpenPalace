package net.codecomposer.palace.script
{
	public class IptAtom
	{
		public var type:int;
		public var value:int;
		
		public static const TYPE_ERROR_OR_UNKNOWN_OR_STACK_EMPTY:int = 0;
		public static const TYPE_INTEGER:int = 1;
		public static const TYPE_VARIABLE:int = 2;
		public static const TYPE_ATOMLIST:int = 3; // ??
		public static const TYPE_STRING:int = 4;
		public static const TYPE_ARRAY_MARK:int = 5;
		public static const TYPE_ARRAY:int = 6;
		
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