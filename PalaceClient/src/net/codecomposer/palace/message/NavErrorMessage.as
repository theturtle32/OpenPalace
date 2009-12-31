package net.codecomposer.palace.message
{
	import flash.utils.ByteArray;
	
	public class NavErrorMessage implements IPalaceServerMessage
	{
		
		public static const INTERNAL_ERROR:int = 0;
		public static const ROOM_UNKNOWN:int = 1;
		public static const ROOM_FULL:int = 2;
		public static const ROOM_CLOSED:int = 3;
		public static const CANT_AUTHOR:int = 4;
		public static const PALACE_FULL:int = 5;
		
		public var referenceId:int;
		public var errorCode:int;
		
		public function read(data:ByteArray, referenceId:int):void
		{
			this.referenceId = referenceId;
			errorCode = referenceId;
		}
		
		public function write():ByteArray
		{
			return null;
		}
	}
}