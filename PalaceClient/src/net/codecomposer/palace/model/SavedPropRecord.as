package net.codecomposer.palace.model
{
	[Bindable]
	public class SavedPropRecord
	{
		public var id:int;
		public var crc:uint;
		public var imageDataURL:String;
		public var guid:String;
		public var width:uint;
		public var height:uint;
		
		public function SavedPropRecord()
		{
		}
	}
}