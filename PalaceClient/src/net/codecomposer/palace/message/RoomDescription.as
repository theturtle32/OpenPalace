package net.codecomposer.palace.message
{
	import com.adobe.net.URI;
	
	import flash.utils.ByteArray;
	
	import net.codecomposer.palace.model.PalaceConfig;

	public class RoomDescription implements IPalaceServerMessage
	{
		public var messageId:int;
		public var referenceId:int;

		public var roomFlags:int;
		public var roomId:int;
		public var roomNameOffset:int;
		public var imageNameOffset:int
		public var artistNameOffset:int;
		public var passwordOffset:int;
		public var hotSpotCount:int;
		public var hotSpotOffset:int;
		public var imageCount:int;
		public var imageOffset:int;
		public var drawCommandsCount:int;
		public var firstDrawCommandOffset:int;
		public var peopleCount:int;
		public var loosePropCount:int;
		public var firstLoosePropOffset:int;
		public var roomDataLength:int;
		
		public var roomName:String;
		public var backgroundImageName:String;
		
		
		public function read(data:ByteArray, referenceId:int):void {
			messageId = IncomingMessageTypes.GOT_ROOM_DESCRIPTION;
			data.position = 0;
			
			var length:uint;
			
			roomFlags = data.readInt();
			var face:int = data.readInt();
			roomId = data.readShort();
			roomNameOffset = data.readShort();
			imageNameOffset = data.readShort();
			artistNameOffset = data.readShort();
			passwordOffset = data.readShort();
			hotSpotCount = data.readShort();
			hotSpotOffset = data.readShort();
			imageCount = data.readShort();
			imageOffset = data.readShort();
			drawCommandsCount = data.readShort();
			firstDrawCommandOffset = data.readShort();
			peopleCount = data.readShort();
			loosePropCount = data.readShort();
			firstLoosePropOffset = data.readShort();
			data.readShort();
			roomDataLength = data.readShort();
			
			var roomBytes:ByteArray = new ByteArray();
			roomBytes.endian = data.endian;
			data.readBytes(roomBytes, 0, roomDataLength);
			
			roomBytes.position = roomNameOffset;
			length = roomBytes.readUnsignedByte();
			roomName = roomBytes.readMultiByte(length, 'Windows-1252');
			
			roomBytes.position = imageNameOffset;
			length = roomBytes.readUnsignedByte();
			backgroundImageName = roomBytes.readMultiByte(length, 'Windows-1252');
			if (PalaceConfig.URIEncodeImageNames) {
				backgroundImageName = URI.escapeChars(backgroundImageName);
			}
			
			
		}
		
		public function write():ByteArray {
			return new ByteArray();
		}
	}
}