/*
This file is part of OpenPalace.

OpenPalace is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

OpenPalace is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenPalace.  If not, see <http://www.gnu.org/licenses/>.
*/

package net.codecomposer.palace.rpc
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import net.codecomposer.palace.crypto.PalaceEncryption;
	import net.codecomposer.palace.message.IncomingMessageTypes;
	import net.codecomposer.palace.message.OutgoingMessageTypes;
	import net.codecomposer.palace.model.AssetManager;
	import net.codecomposer.palace.model.PalaceAsset;
	import net.codecomposer.palace.model.PalaceCurrentRoom;
	import net.codecomposer.palace.model.PalacePropStore;
	import net.codecomposer.palace.model.PalaceRoom;
	import net.codecomposer.palace.model.PalaceUser;
	
	
	public class PalaceClient
	{
		private static var instance:PalaceClient;
		
		private var socket:Socket = null;
				
		public var version:int;
		public var id:int = 0;
		
		// Variables to keep state between packets if we didn't have enough
		// data available in the first packet.
		public var messageID:int = 0;
		public var messageSize:int = 0;
		public var messageP:int = 0;
		public var waitingForMore:Boolean = false;
		
		[Bindable]
		public var utf8:Boolean = false;
		[Bindable]
		public var port:int = 0;
		[Bindable]
		public var host:String = null;
		[Bindable]
		public var state:int = STATE_DISCONNECTED;
		[Bindable]
		public var connected:Boolean = false;
		[Bindable]
		public var serverName:String = "No Server";
		[Bindable]
		public var userName:String;
		[Bindable]
		public var population:int = 0;
		[Bindable]
		public var mediaServer:String = "";
		[Bindable]
		public var userList:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var currentRoom:PalaceCurrentRoom = new PalaceCurrentRoom();
		[Bindable]
		public var roomList:ArrayCollection = new ArrayCollection();
		public var roomById:Object = {};
		
		private var assetRequestQueueTimer:Timer = null;
		private var assetRequestQueue:ByteArray = new ByteArray();
		private var assetRequestQueueCounter:int = 0;
		
		// States
		public static const STATE_DISCONNECTED:int = 0;
		public static const STATE_HANDSHAKING:int = 1;
		public static const STATE_READY:int = 2; 
		
		public static function getInstance():PalaceClient {
			if (PalaceClient.instance == null) {
				PalaceClient.instance = new PalaceClient();
			}
			return PalaceClient.instance;
		}
		
		public function PalaceClient()
		{
			if (PalaceClient.instance != null) {
				throw new Error("Cannot create more than one instance of a singleton.");
			}
		}
		
		private function resetState():void {
			messageID = 0;
			messageSize = 0;
			messageP = 0;
			connected = false;
			currentRoom.name = "No Room";
			currentRoom.users.removeAll();
			currentRoom.usersHash = {};
			currentRoom.backgroundFile = null;
			currentRoom.selectedUser = null;
			currentRoom.removeAllUsers();
			serverName = "No Server"
			roomList.removeAll();
			userList.removeAll();
			socket = null;
		}
		
		// ***************************************************************
		// Begin public functions for user interaction
		// ***************************************************************

		public function connect(userName:String, host:String, port:int = 9998):void {
			this.host = host;
			this.port = port;
			this.userName = userName;
			
			if (connected || (socket && socket.connected)) {
				disconnect();
			}
			else {
				resetState();
			}
			socket = new Socket(this.host, this.port);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			socket.addEventListener(Event.CONNECT, onConnect);
			socket.addEventListener(Event.CLOSE, onClose);
		}
		
		public function disconnect():void {
			if (socket && socket.connected) {
				socket.writeInt(OutgoingMessageTypes.BYE);
				socket.writeInt(0);
				socket.writeInt(id);
				socket.flush();
				socket.close();
			}
			resetState();
		}

		public function say(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
			
			var whispering:Boolean = currentRoom.selectedUser != null;
			
			var messageBytes:ByteArray = PalaceEncryption.getInstance().encrypt(message, utf8, 254);
			messageBytes.position = 0;
			
			if (whispering) {
				socket.writeInt(OutgoingMessageTypes.WHISPER);
				socket.writeInt(messageBytes.length + 7); // length + 2 bytes for short, + 4 bytes for id
				socket.writeInt(id);
				socket.writeInt(currentRoom.selectedUser.id);
			}
			else {
				socket.writeInt(OutgoingMessageTypes.SAY);
				socket.writeInt(messageBytes.length + 3);
				socket.writeInt(id);
			}
			socket.writeShort(messageBytes.length + 3);
			socket.writeBytes(messageBytes);
			socket.writeByte(0);
			socket.flush();
		}
		
		public function move(x:int, y:int):void {
			var user:PalaceUser = currentRoom.getUserById(id);
			
			if (!connected || !user || x < 0 || y < 0) {
				return;
			}
			
			socket.writeInt(OutgoingMessageTypes.MOVE);
			socket.writeInt(4);
			socket.writeInt(id);
			socket.writeShort(y);
			socket.writeShort(x);
			socket.flush();
			
			user.x = x;
			user.y = y;
		}
				
		public function requestRoomList():void {
			if (!connected) {
				return;
			}
			socket.writeInt(OutgoingMessageTypes.REQUEST_ROOM_LIST);
			socket.writeInt(0);
			socket.writeInt(0);
			socket.flush();
		}
		
		public function requestUserList():void {
			if (!connected) {
				return;
			}
			socket.writeInt(OutgoingMessageTypes.REQUEST_USER_LIST);
			socket.writeInt(0);
			socket.writeInt(id);
			socket.flush();
		}
		
		public function gotoRoom(roomId:int):void {
			if (!connected) {
				return;
			}
			socket.writeInt(OutgoingMessageTypes.GOTO_ROOM);
			socket.writeInt(2); // length
			socket.writeInt(id);
			socket.writeShort(roomId);
			socket.flush();
		}
		
		public function requestAsset(assetType:int, assetId:uint, assetCrc:uint):void {
			// Asset requests queue up because flushing once every request is slow.
			// Instead we batch an arbitrarily chosen 16 requests together.
			// The buffer will flush when there are 16 assets to be requested, or if
			// 250 milliseconds have elapsed since the last asset was added to the queue.
			if (!connected) {
				return;	
			}
			trace("Requesting asset (Type:" + assetType.toString(16) + ") (ID:" + assetId + ") (CRC:" + assetCrc + ")");
			if (assetRequestQueueTimer == null) {
				assetRequestQueueTimer = new Timer(250, 1);
				assetRequestQueueTimer.addEventListener(TimerEvent.TIMER, sendAssetRequests);
			}

			assetRequestQueue.writeInt(OutgoingMessageTypes.REQUEST_ASSET);
			assetRequestQueue.writeInt(12); // size
			assetRequestQueue.writeInt(id);
			assetRequestQueue.writeInt(assetType);
			assetRequestQueue.writeInt(assetId);
			assetRequestQueue.writeInt(assetCrc);
			
			if (++assetRequestQueueCounter >= 16) {
				sendAssetRequests();
			}
			else {
				assetRequestQueueTimer.reset();
				assetRequestQueueTimer.start();			
			}
		}
		
		private function sendAssetRequests(event:TimerEvent=null):void {
			if (!connected || !socket || !socket.connected) {
				assetRequestQueue = new ByteArray()
				assetRequestQueueCounter = 0;
				return;
			}
			assetRequestQueueTimer.reset();
			assetRequestQueueCounter = 0;
			assetRequestQueue.position = 0;
			trace("Flushing asset requests to socket.");
			while (assetRequestQueue.bytesAvailable >= 4) {
				socket.writeInt(assetRequestQueue.readInt());
			}
			socket.flush();
			assetRequestQueue = new ByteArray();
		}
				
		
		
		
		
		// ***************************************************************
		// Begin private functions to messages from the server
		// ***************************************************************
				
		private function onConnect(event:Event):void {
			connected = true;
			state = STATE_HANDSHAKING;
			trace("Connected");
		}
		
		private function onClose(event:Event):void {
			onSocketData();
			connected = false;
			resetState();
			trace("Disconnected");
			Alert.show("Connection to server lost.");
		}
		
		private function onSocketData(event:ProgressEvent=null):void {
			trace("Got data: " + socket.bytesAvailable + " bytes available");
			var size:int;
			var p:int;
			
//			try {
			
				while (socket.bytesAvailable > 0) {
				
					if (state == STATE_HANDSHAKING) {
						handshake();
					}
					else if (state == STATE_READY) {
						if (messageID == 0) {
							if (socket.bytesAvailable >= 12) { // Header is 12 bytes
								messageID = socket.readInt();
								messageSize = socket.readInt();
								messageP = socket.readInt();
							}
							else {
								trace("Not enough bytes to grab the next message header.  Waiting for more data.");
								return;
							}
						}
						size = messageSize;
						p = messageP;
	
						if (size > socket.bytesAvailable) {
							trace("Message " + messageID + " expected bytes: " + size + " socket bytesAvailable: " + socket.bytesAvailable);
							return;
						}
	
						switch (messageID) {
							case IncomingMessageTypes.ALTERNATE_LOGON_REPLY:
								trace("Alternate Logon Reply");
								alternateLogon(size, p);
								break;
							
							case IncomingMessageTypes.SERVER_VERSION:
								handleReceiveServerVersion(size, p);
								break;
								
							case IncomingMessageTypes.SERVER_INFO:
								handleReceiveServerInfo(size, p);
								break;
								
							case IncomingMessageTypes.USER_STATUS:
								handleReceiveUserStatus(size, p);
								break;
							
							case IncomingMessageTypes.USER_LOGGED_ON_AND_MAX:
								handleReceiveUserLog(size, p);
								break;
							
							case IncomingMessageTypes.GOT_HTTP_SERVER_LOCATION:
								handleReceiveMediaServer(size, p);
								break;
							
							case IncomingMessageTypes.GOT_ROOM_DESCRIPTION:
							case IncomingMessageTypes.GOT_ROOM_DESCRIPTION_ALT:
								handleReceiveRoomDescription(size, p);
								break;
								
							case IncomingMessageTypes.GOT_USER_LIST:
								handleReceiveUserList(size, p);
								break;
								
							case IncomingMessageTypes.GOT_REPLY_OF_ALL_USERS:
								handleReceiveFullUserList(size, p);
								break;
							
							case IncomingMessageTypes.GOT_ROOM_LIST:
								handleReceiveRoomList(size, p);
								break;
							
							case IncomingMessageTypes.ROOM_DESCEND: // No idea...
								handleReceiveRoomDescend(size, p);
								break;
								
							case IncomingMessageTypes.USER_NEW:
								handleUserNew(size, p);
								break;
								
							case IncomingMessageTypes.PINGED:
								handlePing(size, p);
								break;
								
							case IncomingMessageTypes.RECEIVE_CHAT:
								handleReceiveChat(size, p);
								break;
								
							case IncomingMessageTypes.RECEIVE_WHISPER:
								handleReceiveWhisper(size, p);
								break;
							
							case IncomingMessageTypes.ALT_RECEIVE_CHAT:
								handleAltReceiveChat(size, p);
								break;
								
							case IncomingMessageTypes.ALT_RECEIVE_WHISPER:
								handleAltReceiveWhisper(size, p);
								break;
							
							case IncomingMessageTypes.ASSET_INCOMING:
								handleReceiveAsset(size, p);
								break;
							
							case IncomingMessageTypes.MOVEMENT:
								handleMovement(size, p);
								break;
								
							case IncomingMessageTypes.USER_COLOR:
								handleUserColor(size, p);
								break;
							
							case IncomingMessageTypes.USER_FACE:
								handleUserFace(size, p);
								break;
							
							case IncomingMessageTypes.USER_PROP:
								handleUserProp(size, p);
								break;
							case IncomingMessageTypes.USER_DESCRIPTION: // (prop)
								handleUserDescription(size, p);
								break;
	//						
	//						case IncomingMessage.USER_PROP:
	//							handleUserProp(size, p);
	//							break;
							
							case IncomingMessageTypes.USER_RENAME:
								handleUserRename(size, p);
								break;
								
							case IncomingMessageTypes.USER_LEAVING:
								handleUserLeaving(size, p);
								break;

							case IncomingMessageTypes.USER_EXIT_ROOM:
								handleUserExitRoom(size, p);
								break;
								
	//						case IncomingMessage.CONNECTION_DIED:
	//							handleConnectionDied(size, p);
	//							break;
	//							
	//						case IncomingMessage.INCOMING_FILE:
	//							handleIncomingFile(size, p);
	//							break;
							
							default:
								trace("Unhandled MessageID: " + messageID.toString());
								_throwAwayData(size, p);
								break;
						}
						messageID = 0;
					}
				}
//			}	
//			catch (error:EOFError) {
//				Alert.show("There was a problem reading data from the server.  You have been disconnected.");
//				disconnect();
//			}		
			
		}
		
		private function onIOError(event:IOErrorEvent):void {
			trace("IO Error!");
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void {
			trace("Security Error!");
		}
		
		// Handshake
		private function handshake():void {
			var messageID:int;
			var size:int;
			var p:int;
			
			messageID = socket.readInt();
			
			switch (messageID) {
				case IncomingMessageTypes.UNKNOWN_SERVER: //1886610802
					trace("Untested Server Version");
					break;
				case IncomingMessageTypes.LITTLE_ENDIAN_SERVER: //1920559476
					trace("Server is Little Endian");
					socket.endian = Endian.LITTLE_ENDIAN;
					size = socket.readInt();
					p = socket.readInt();
					logOn(size, p);
					break;
				case IncomingMessageTypes.BIG_ENDIAN_SERVER: //1953069426
					trace("Server is Big Endian");
					socket.endian = Endian.BIG_ENDIAN;
					size = socket.readInt();
					p = socket.readInt();
					logOn(size, p);
					break;
				default:
					trace("Unhandled MessageID: " + messageID.toString());
					break;
			}
		}
		
		// Server Op Handlers
		private function logOn(a:int, b:int):void {
			var i:int;
			
			trace("Logging on.  a: " + a + " - b: " + b);
			// a is validation
			currentRoom.selfUserId = id = b;


			// bk.c(eb) writes a,b,c, no flush
			socket.writeInt(1919248233);
			socket.writeInt(128);
			socket.writeInt(id); // client id/room number?
			// working from id
			socket.writeInt(0x5905f923);// b[0]
			socket.writeInt(0xcf07309c);// b[1]

			// Username has to be ISO-8859-1
			var userNameBA:ByteArray = new ByteArray();
			userNameBA.writeMultiByte(userName, 'iso-8859-1');
			userNameBA.position = 0;
			socket.writeByte(userNameBA.bytesAvailable);
			socket.writeBytes(userNameBA); //? name  or super.a?
			
			i = 64 - (1 + userName.length);
			if (i < 0) { 	// padding???
				i = 0;
			}
			for(; i > 0; i--) { 
				socket.writeByte(0);
			}
	
			/*
			socket.writeInt(5);	// 5 
			*/
			socket.writeInt(0x80000004);

			//socket.writeInt(0);	// unset or d?
			socket.writeInt(0xf5dc385e);
	
        	//socket.writeInt(0); // e?
			socket.writeInt(0xc144c580);
	
        	//socket.writeInt(0); // f?
			socket.writeInt(0x00002a30);
	
        	//socket.writeInt(0); // g?
			socket.writeInt(0x00021df9);
	
        	//socket.writeInt(0); // h?
			socket.writeInt(0x00002a30);
        
			//WriteShort(1); // i? room id?
			socket.writeShort(0); // i? room id?

			/*	// version
	        WriteBytes((unsigned char *)"J2.0", 4); 
			WriteByte(0);
			WriteByte(0); */
			socket.writeMultiByte("350211", "iso-8859-1");
	
	        socket.writeInt(0);

	        //socket.writeInt(0);
    	    socket.writeInt(1);

        	//socket.writeInt(0);
	        socket.writeInt(0x00000111);

        	//socket.writeInt(0);
        	socket.writeInt(1);

        	//socket.writeInt(0);
        	socket.writeInt(1);

        	socket.writeInt(0);
			socket.flush();
			
			state = STATE_READY;
			
			requestRoomList();
			requestUserList();
		}
		
		
		// not fully implemented
		// a bounced logon message?
		private function alternateLogon(a:int, b:int):void {
			// orig logon id seems to be bullshit?
			//id = b;
			//	FILE * fp = fopen("altlogonrx.hex", "w+");
			for(var i:int = 0; i < a; i++) {
				socket.readByte();
			}
			//		fputc(ReadByte(), fp);	// unknown server params
			//	fclose(fp);
		}
		
		private function handleReceiveServerVersion(a:int, b:int):void {
			version = b;
			trace("Server version: " + b);
		}
		
		private function handleReceiveServerInfo(a:int, b:int):void {
			var unknown:int = socket.readInt();
			var size:int = socket.readByte();
			serverName = socket.readMultiByte(size, 'iso-8859-1');
			trace("Server name: " + serverName);
		}
		
		// not fully implemented
		private function handleReceiveUserStatus(a:int, b:int):void {
			// a is length? b is client id
			var data:String = socket.readMultiByte(a, 'iso-8859-1');
			trace("User status?  Data: \n" + data); 			
		}
		
		//class c2
		private function handleReceiveUserLog(a:int, b:int):void {
			population = socket.readInt();
			trace("Got population: " + population);
		}
		
		private function handleReceiveMediaServer(a:int, b:int):void {
			mediaServer = socket.readMultiByte(a, 'iso-8859-1');
			trace("Got media server: " + mediaServer);
		}
		
		private function outputHexView(bytes:Array):void {
			var output:String = "";
			var outputLineHex:String = "";
			var outputLineAscii:String = "";
			for (var byteNum:int = 0; byteNum < bytes.length; byteNum++) {
				var hexNum:String = uint(bytes[byteNum]).toString(16).toUpperCase();
				if (hexNum.length == 1) {
					hexNum = "0" + hexNum;
				}

				if (byteNum % 16 == 0) {
					output = output.concat(outputLineHex, "      ", outputLineAscii, "\n");
					outputLineHex = "";
					outputLineAscii = "";
				}
				else if (byteNum % 4 == 0) {
					outputLineHex = outputLineHex.concat("  ");
					outputLineAscii = outputLineAscii.concat(" ");
				}
				else {
					outputLineHex = outputLineHex.concat(" ");
				}
				outputLineHex = outputLineHex.concat(hexNum);
				outputLineAscii = outputLineAscii.concat(
					(bytes[byteNum] >= 32 && bytes[byteNum] <= 126) ? String.fromCharCode(bytes[byteNum]) : " "
				);
			}
			output = output.concat(outputLineHex, "      ", outputLineAscii, "\n");
			trace(output);
		}

		
		// not fully implemented
		private function handleReceiveRoomDescription(size:int, referenceNumber:int):void {
			var roomFlags:int = socket.readInt();
			var face:int = socket.readInt();
			var roomID:int = socket.readShort();
			var roomNameOffset:int = socket.readShort();
			var imageNameOffset:int = socket.readShort();
			var artistNameOffset:int = socket.readShort();
			var passwordOffset:int = socket.readShort();
			var hotSpotCount:int = socket.readShort();
			var hotSpotOffset:int = socket.readShort();
			var imageCount:int = socket.readShort();
			var imageOffset:int = socket.readShort();
			var drawCommandsCount:int = socket.readShort();
			var firstDrawCommand:int = socket.readShort();
			var peopleCount:int = socket.readShort();
			var loosePropCount:int = socket.readShort();
			var firstLooseProp:int = socket.readShort();
			socket.readShort();
			var roomDataLength:int = socket.readShort();
			var roomBytes:Array = new Array(roomDataLength);

			trace("Reading in room description: " + roomDataLength + " bytes to read.");
			for (var i:int = 0; i < roomDataLength; i++) {
				roomBytes[i] = socket.readUnsignedByte();
			}
			
			outputHexView(roomBytes);
			
			var padding:int = size - roomDataLength - 40;
			for (i=0; i < padding; i++) {
				socket.readByte();
			}
			
			var byte:int;
			
			// Room Name
			var roomNameLength:int = roomBytes[roomNameOffset];
			var roomName:String = "";
			var ba:ByteArray = new ByteArray();
			for (i=0; i < roomNameLength; i++) {
				byte = roomBytes[i+roomNameOffset+1];
				ba.writeByte(byte);
			}
			ba.position = 0;
			roomName = ba.readUTFBytes(roomNameLength);
			
			// Image Name
			var imageNameLength:int = roomBytes[imageNameOffset];
			var imageName:String = "";
			for (i=0; i < imageNameLength; i++) {
				byte = roomBytes[i+imageNameOffset+1];
				imageName += String.fromCharCode(byte);
			}
			
			// Hotspots -- Can't get this to work
			currentRoom.hotSpots.removeAll();
//			for (i=0; i < hotSpotCount; i++) {
//				var hs:PalaceHotspot = new PalaceHotspot();
//				hs.fromBytes(socket.endian, roomBytes, hotSpotOffset);
//				hotSpotOffset += hs.size;
//				currentRoom.hotSpots.addItem(hs);
//			}
			
			// Images
			var images:Object = {};
			for (i=0; i < imageCount; i++) {
//				var imageOverlay:PalaceImageOverlay = new PalaceImageOverlay();
//				var imageBA:ByteArray = new ByteArray();
//				//imageBA.endian = Endian.BIG_ENDIAN;
//				for (var j:int=imageOffset-1; j < imageOffset+12-1; j++) {
//					imageBA.writeByte(roomBytes[j]);
//				}
//				imageBA.position = 0;
//				imageOverlay.refCon = imageBA.readInt();
//				imageOverlay.id = imageBA.readShort();
//				var picNameOffset:int = imageBA.readShort();
//				imageOverlay.transparencyColor = imageBA.readShort();
//				imageBA.readShort(); // ??
//				var picNameLength:int = roomBytes[picNameOffset];
//				var picName:String = "";
//				for (j=0; j < picNameLength; j++) {
//					var imageNameByte:int = roomBytes[picNameOffset+j+1]; 
//					picName += String.fromCharCode(imageNameByte);
//				}
//				imageOverlay.filename = picName;
//				images[imageOverlay.id] = imageOverlay; 
//				trace("picture id: " + imageOverlay.id + " - Name: " + imageOverlay.filename);
//				imageOffset += 12;
			}
			currentRoom.images = images;
			
			// Loose props
			var looseProps:Object = {};
			var ofst:int = firstLooseProp;
			for (i=0; i < loosePropCount; i++) {
				// Not implemented
			}
			
			
			currentRoom.backgroundFile = imageName;
			trace("Background Image: " + currentRoom.backgroundFile);
			
			currentRoom.name = roomName;
			trace("Room name: " + currentRoom.name);
			
			currentRoom.selectedUser = null;
			
			currentRoom.users.removeAll();
			currentRoom.usersHash = {};
		}
		
		// List of users in current room
		private function handleReceiveUserList(a:int, b:int):void {
			// b is count
			currentRoom.removeAllUsers();
			
			for(var i:int = 0; i < b; i++){
				var userId:int = socket.readInt();
				var y:int = socket.readShort();
				var x:int = socket.readShort();
				var propIds:Array = []; // 9 slots
				var propCrcs:Array = []; // 9 slots

				// props
				var i1:int = 0;
				do {
					propIds[i1] = socket.readInt();
					propCrcs[i1] = socket.readInt();
				}
				while (++i1 < 9);
				
				var roomId:int = socket.readShort(); // room
				var face:int = socket.readShort(); // face
				var color:int = socket.readShort(); // color
				socket.readShort(); // 0?
				socket.readShort(); // 0?
				var propnum:int = socket.readShort(); // number of props
				if(propnum < 9) {
					propIds[propnum] = propCrcs[propnum] = 0;
				}
				var userNameLength:int = socket.readByte();
				var userName:String = socket.readMultiByte(userNameLength, 'iso-8859-1'); // Length = 32
				socket.readMultiByte(31-userNameLength, 'iso-8859-1');

				var user:PalaceUser = new PalaceUser();
				user.id = userId;
				user.name = userName;
				user.propCount = propnum;
				user.x = x;
				user.y = y;
				user.propIds = propIds;
				user.propCrcs = propCrcs;
				user.face = face;
				user.color = color;
				user.loadProps();
				
				currentRoom.addUser(user);
			}
			trace("Got list of users in room.  Count: " + currentRoom.users.length);
		}
		
		private function handleReceiveRoomList(size:int, referenceNumber:int):void {
			var numAdded:int = 0;
			var roomCount:int = referenceNumber;
			roomList.removeAll();
			for (var i:int = 0; i < roomCount; i++) {
				var room:PalaceRoom = new PalaceRoom();
				room.id = socket.readInt();
				room.flags = socket.readShort();
				room.userCount = socket.readShort();
				var length:int = socket.readByte();
				var paddedLength:int = (length + (4 - (length & 3))) - 1;
				room.name = socket.readUTFBytes(paddedLength);
				roomList.addItem(room);
				roomById[room.id] = room;
			}
			trace("There are " + roomCount + " rooms in this palace.");
		}
		
		private function handleReceiveFullUserList(size:int, referenceNumber:int):void {
			userList.removeAll();
			var userCount:int = referenceNumber;
			for (var i:int = 0; i < userCount; i++) {
				var user:PalaceUser = new PalaceUser();
				user.id = socket.readInt();
				user.flags = socket.readShort();
				user.roomID = socket.readShort();
				if (roomById[user.roomID]) {
					user.roomName = roomById[user.roomID].name;
				}
				else {
					user.roomName = "(Unknown Room)";
				}
				var userNameLength:int = socket.readByte();
				var userNamePaddedLength:int = (userNameLength + (4 - (userNameLength & 3))) - 1;
				if (utf8) {
					user.name = socket.readUTFBytes(userNamePaddedLength);
				}
				else {
					user.name = socket.readMultiByte(userNamePaddedLength, 'iso-8859-1');
				}
				//trace("User List - got user: " + user.name);
				userList.addItem(user);
			}
			trace("There are " + userList.length + " users in this palace.");
		}
		
		private function handleReceiveRoomDescend(a:int, b:int):void {
			//No idea...
		}
		
		private function handleUserNew(a:int, b:int):void {
			var userId:int = socket.readInt();
			var y:int = socket.readShort();
			var x:int = socket.readShort();
			var propIds:Array = []; // Props, 9 slots
			var propCrcs:Array = []; // Prop Checksums, 9 slots
			
			var i1:int = 0;
			do {
				propIds[i1] = socket.readInt();
				propCrcs[i1] = socket.readInt();
			}
			while (++i1 < 9); // props
			
			var roomId:int = socket.readShort(); //room
			var face:int = socket.readShort();
			var color:int = socket.readShort();
			socket.readShort(); // zero?
			socket.readShort(); // zero?
			var propnum:int = socket.readShort(); // number of props
			for (var pc:int = propnum; pc < 9; pc ++ ) {
				propIds[pc] = propCrcs[pc] = 0;
			}
			
			var userNameLength:int = socket.readByte();
			var userName:String;
			if (utf8) {
				userName = socket.readUTFBytes(userNameLength); // Length = 32
			}
			else {
				userName = socket.readMultiByte(userNameLength, 'iso-8859-1'); // Length = 32
			}
			socket.readMultiByte(31-userNameLength, 'iso-8859-1');
			//userName = userName.substring(1);

			var user:PalaceUser = new PalaceUser();
			user.id = userId;
			user.x = x;
			user.y = y;
			user.propIds = propIds;
			user.propCrcs = propCrcs;
			user.propCount = propnum;
			user.name = userName;
			user.roomID = roomId;
			user.face = face;
			user.color = color;
			user.loadProps();
			
			currentRoom.addUser(user);
			
			trace("User " + user.name + " entered.");
		}

		private function handlePing(a:int, b:int):void {
			if (b != id) {
				trace("ID didn't match during ping, bailing");
				return;
			}
			
			socket.writeInt(OutgoingMessageTypes.PING_BACK);
			socket.writeInt(0);
			socket.writeInt(0);
			socket.flush();
			
			trace("Pinged.");
		}
		
		private function handleAltReceiveChat(size:int, referenceNumber:int):void {
			var messageBytes:ByteArray = new ByteArray();
			var message:String;
			if (utf8) {
				message = socket.readUTFBytes(size-1);
			}
			else {
				message = socket.readMultiByte(size-1, 'iso-8859-1');
			}
			if (socket.bytesAvailable > 0) {
				socket.readByte();
			}
			currentRoom.roomMessage(message);
			trace("Got Room Message: " + message);
		}
		
		private function handleAltReceiveWhisper(size:int, referenceNumber:int):void {
			var messageBytes:ByteArray = new ByteArray();
			var message:String;
			if (utf8) {
				message = socket.readUTFBytes(size-1);
			}
			else {
				message = socket.readMultiByte(size-1, 'iso-8859-1');
			}
			if (socket.bytesAvailable > 0) {
				socket.readByte();
			}
			currentRoom.roomWhisper(message);
			trace("Got ESP: " + message);
		}
		
		private function handleReceiveChat(a:int, b:int):void {
			var length:int = socket.readShort();
			var messageBytes:ByteArray = new ByteArray();
			socket.readBytes(messageBytes, 0, length-3);
			if (socket.bytesAvailable > 0) {
				socket.readByte();
			}
			var message:String = PalaceEncryption.getInstance().decrypt(messageBytes, utf8);
			currentRoom.chat(b, message);
			trace("Got chat from userID " + b + ": " + message);
		}
		
		private function handleReceiveWhisper(size:int, referenceNumber:int):void {
			var length:int = socket.readShort();
			var messageBytes:ByteArray = new ByteArray();
			socket.readBytes(messageBytes, 0, length-3);
			if (socket.bytesAvailable > 0) {
				socket.readByte();
			}
			var message:String = PalaceEncryption.getInstance().decrypt(messageBytes, utf8);
			currentRoom.whisper(referenceNumber, message);
			trace("Got whisper from userID " + referenceNumber + ": " + message);
		}
		
		private function handleMovement(a:int, b:int):void {
			// a is four, b is userID
			var y:int = socket.readShort();
			var x:int = socket.readShort();
			var user:PalaceUser = currentRoom.getUserById(b);
			user.x = x;
			user.y = y;
			trace("User " + b + " moved to " + x + "," + y);
		}
		
		private function handleUserColor(a:int, b:int):void {
			var user:PalaceUser = currentRoom.getUserById(b);
			user.color = socket.readShort();
			trace("User " + b + " changed color to " + user.color); 
		}
		
		private function handleUserFace(a:int, b:int):void {
			var user:PalaceUser = currentRoom.getUserById(b);
			user.face = socket.readShort();
			trace("User " + b + " changed face to " + user.face);
		}
		
		private function handleUserRename(a:int, b:int):void {
			var user:PalaceUser = currentRoom.getUserById(b);
			var userNameLength:int = socket.readByte();
			var userName:String;
			if (utf8) {
				userName = socket.readUTFBytes(userNameLength);
			}
			else {
				userName = socket.readMultiByte(userNameLength, 'iso-8859-1');
			}
			trace("User " + user.name + " changed their name to " + userName);
			user.name = userName;
		}
		
		private function handleUserExitRoom(a:int, b:int):void {
			currentRoom.removeUserById(b);
			trace("User " + b + " left the room");
		}
		
		private function handleUserLeaving(a:int, b:int):void {
			population = socket.readInt();
			if (currentRoom.getUserById(b) != null) {
				currentRoom.removeUserById(b);
			}
			trace("User " + b + " logged off");
		}
		
		private function handleReceiveAsset(size:int, referenceId:int):void {
			var assetType:int = socket.readInt();
			var assetId:uint = socket.readUnsignedInt();
			var assetCrc:uint = socket.readUnsignedInt();
			var blockSize:int = socket.readInt();
			var blockOffset:int = socket.readInt();
			var blockNumber:int = socket.readShort();
			var blockCount:int = socket.readShort();
			var flags:uint = 0;
			var assetSize:int = 0;
			var assetName:String = "";
			var data:Array = [];
			if (blockNumber == 0) {
				flags = socket.readUnsignedInt();
				assetSize = socket.readInt();
				var nameLength:int = socket.readByte();
				assetName = socket.readMultiByte(nameLength, 'iso-8859-1');
				for (var j:int = 0; j < 31-nameLength; j++) {
					socket.readByte();
				}
			}
			for (var i:int = 0; i < blockSize; i ++) {
				data[i] = socket.readByte();
			}
			var padding:int = size - (blockSize + 64);
			for (i=0; i < padding; i++) {
				socket.readByte();
			}
			var asset:PalaceAsset = new PalaceAsset();
			asset.id = assetId;
			asset.crc = assetCrc;
			asset.blockSize = blockSize;
			asset.blockCount = blockCount;
			asset.flags = flags;
			asset.blockNumber = blockNumber;
			asset.data = data;
			asset.type = assetType;
			asset.name = assetName;
			trace("Received asset: (Type:" + asset.type.toString(16) + ") (ID:"+asset.id+") (CRC:" + asset.crc + ") (Name:" + asset.name + ")");
			if (asset.type == AssetManager.ASSET_TYPE_PROP) {
				PalacePropStore.getInstance().injectAsset(asset);
			}
		}
		
		private function handleUserProp(size:int, referenceId:int):void {
			var user:PalaceUser = currentRoom.getUserById(referenceId);
			var propCount:int = socket.readInt();
			var propIds:Array = [];
			var propCrcs:Array = [];
			for (var i:int = 0; i < propCount; i++) {
				propIds[i] = socket.readUnsignedInt();
				propCrcs[i] = socket.readUnsignedInt();
			}
			user.propCount = propCount;
			user.propIds = propIds;
			user.propCrcs = propCrcs;
			user.loadProps();
		}
		
		private function handleUserDescription(size:int, referenceId:int):void {
			var user:PalaceUser = currentRoom.getUserById(referenceId);
			user.face = socket.readShort();
			user.color = socket.readShort();
			var propCount:int = socket.readInt();
			var propIds:Array = [];
			var propCrcs:Array = [];
			for (var i:int = 0; i < propCount; i++) {
				propIds[i] = socket.readUnsignedInt();
				propCrcs[i] = socket.readUnsignedInt();
			}
			user.propCount = propCount;
			user.propIds = propIds;
			user.propCrcs = propCrcs;
			user.loadProps();
		}
		
		private function _throwAwayData(a:int, b:int):void {
			for (var i:int = 0; i < a && socket.bytesAvailable > 0; i++) {
				socket.readByte();
			}
			trace("Throwing away data.");
		}

	}
}