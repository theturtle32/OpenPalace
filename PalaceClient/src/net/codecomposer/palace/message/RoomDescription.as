package net.codecomposer.palace.message
{
	import flash.utils.ByteArray;

	public class RoomDescription
	{		
		public static function read(data:ByteArray):RoomDescription {
			var instance:RoomDescription = new RoomDescription();
			
			return instance;
		}
	}
}