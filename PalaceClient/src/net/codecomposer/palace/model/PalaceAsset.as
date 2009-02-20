package net.codecomposer.palace.model
{
	import flash.utils.ByteArray;
	
	public class PalaceAsset
	{
		public var id:uint;
		public var crc:uint;
		public var type:int;
		public var name:String;
		public var flags:uint;
		public var blockSize:int;
		public var blockCount:int;
		public var blockOffset:int;
		public var blockNumber:int;
		public var data:Array;
		
		public function PalaceAsset()
		{
		}

	}
}