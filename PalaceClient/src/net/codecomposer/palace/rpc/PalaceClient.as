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
	import com.adobe.net.URI;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import net.codecomposer.openpalace.accountserver.rpc.AccountServerClient;
	import net.codecomposer.palace.crypto.PalaceEncryption;
	import net.codecomposer.palace.event.PalaceEvent;
	import net.codecomposer.palace.event.PropEvent;
	import net.codecomposer.palace.iptscrae.DebugData;
	import net.codecomposer.palace.iptscrae.IptEventHandler;
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.message.IncomingMessageTypes;
	import net.codecomposer.palace.message.OutgoingMessageTypes;
	import net.codecomposer.palace.message.RoomDescription;
	import net.codecomposer.palace.model.AssetManager;
	import net.codecomposer.palace.model.PalaceAsset;
	import net.codecomposer.palace.model.PalaceConfig;
	import net.codecomposer.palace.model.PalaceCurrentRoom;
	import net.codecomposer.palace.model.PalaceHotspot;
	import net.codecomposer.palace.model.PalaceImageOverlay;
	import net.codecomposer.palace.model.PalaceLooseProp;
	import net.codecomposer.palace.model.PalaceProp;
	import net.codecomposer.palace.model.PalacePropStore;
	import net.codecomposer.palace.model.PalaceRoom;
	import net.codecomposer.palace.model.PalaceServerInfo;
	import net.codecomposer.palace.model.PalaceUser;
	import net.codecomposer.palace.record.PalaceDrawRecord;
	import net.codecomposer.palace.view.PalaceSoundPlayer;

	[Event(type="net.codecomposer.event.PalaceEvent",name="connectStart")]
	[Event(type="net.codecomposer.event.PalaceEvent",name="connectComplete")]
	[Event(type="net.codecomposer.event.PalaceEvent",name="connectFailed")]
	[Event(type="net.codecomposer.event.PalaceEvent",name="disconnected")]
	[Event(type="net.codecomposer.event.PalaceEvent",name="gotoURL")]
	[Event(type="net.codecomposer.event.PalaceEvent",name="roomChanged")]
	[Event(type="net.codecomposer.event.PalaceEvent",name="authenticationRequested")]
	
	public class PalaceClient extends EventDispatcher
	{
		
		private static var instance:PalaceClient;
		
		[Bindable]
		public static var loaderContext:LoaderContext = new LoaderContext();

		/* FLAGS */
		
		public static const AUXFLAGS_UNKNOWN_MACHINE:uint = 0;
		public static const AUXFLAGS_MAC68K:uint = 1;
		public static const AUXFLAGS_MACPPC:uint = 2;
		public static const AUXFLAGS_WIN16:uint = 3;
		public static const AUXFLAGS_WIN32:uint = 4;
		public static const AUXFLAGS_JAVA:uint = 5;
		
		public static const AUXFLAGS_OSMASK:uint = 0x0000000F;
		public static const AUXFLAGS_AUTHENTICATE:uint = 0x80000000;
		
		public static const ULCAPS_ASSETS_PALACE:uint = 0x00000001;
		public static const ULCAPS_ASSETS_FTP:uint = 0x00000002;
		public static const ULCAPS_ASSETS_HTTP:uint = 0x00000004;
		public static const ULCAPS_ASSETS_OTHER:uint = 0x00000008;
		public static const ULCAPS_FILES_PALACE:uint = 0x00000010;
		public static const ULCAPS_FILES_FTP:uint = 0x00000020;
		public static const ULCAPS_FILES_HTTP:uint = 0x00000040;
		public static const ULCAPS_FILES_OTHER:uint = 0x00000080;
		public static const ULCAPS_EXTEND_PKT:uint = 0x00000100;
		
		public static const DLCAPS_ASSETS_PALACE:uint = 0x00000001;
		public static const DLCAPS_ASSETS_FTP:uint = 0x00000002;
		public static const DLCAPS_ASSETS_HTTP:uint = 0x00000004;
		public static const DLCAPS_ASSETS_OTHER:uint = 0x00000008;
		public static const DLCAPS_FILES_PALACE:uint = 0x00000010;
		public static const DLCAPS_FILES_FTP:uint = 0x00000020;
		public static const DLCAPS_FILES_HTTP:uint =  0x00000040;
		public static const DLCAPS_FILES_OTHER:uint = 0x00000080;
		public static const DLCAPS_FILES_HTTPSRVR:uint = 0x00000100;
		public static const DLCAPS_EXTEND_PKT:uint = 0x00000200;
		
		private var socket:Socket = null;
		
		private var accountClient:AccountServerClient = AccountServerClient.getInstance();
				
		public var version:int;
		public var id:int = 0;
		
		// Variables to keep state between packets if we didn't have enough
		// data available in the first packet.
		public var messageID:int = 0;
		public var messageSize:int = 0;
		public var messageP:int = 0;
		public var waitingForMore:Boolean = false;
		
		[Bindable]
		public var debugData:DebugData;
		[Bindable]
		public var utf8:Boolean = false;
		[Bindable]
		public var port:uint = 0;
		[Bindable]
		public var host:String = null;
		[Bindable]
		public var initialRoom:uint = 0;
		[Bindable]
		public var state:int = STATE_DISCONNECTED;
		[Bindable]
		public var connected:Boolean = false;
		[Bindable]
		public var connecting:Boolean = false;
		[Bindable]
		public var serverName:String = "No Server";
		[Bindable]
		public var serverInfo:PalaceServerInfo = new PalaceServerInfo();
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
		
		public var chatstr:String = "";
		public var whochat:int = 0;
		public var needToRunSignonHandlers:Boolean = true; 
		
		private var assetRequestQueueTimer:Timer = null;
		private var assetRequestQueue:Array = [];
		private var assetRequestQueueCounter:int = 0;
		private var assetsLastRequestedAt:Date = new Date();
		
		private var puidChanged:Boolean = false;
		private var puidCounter:uint = 0xf5dc385e;
		private var puidCRC:uint = 0xc144c580;
		private var regCounter:uint = 0xcf07309c;
		private var regCRC:uint = 0x5905f923;
		
		private var recentLogonUserIds:ArrayCollection = new ArrayCollection();
		
		private var _userName:String = "OpenPalace User";
		
		[Bindable]
		public var palaceController:PalaceController;
		
		private var temporaryUserFlags:int;
		// We get the user flags before we have the current user
		
		[Bindable(event="userNameChange")]
		public function get userName():String {
			return _userName;
		}
		
		public function set userName(newValue:String):void {
			if (newValue.length > 31) {
				newValue = newValue.slice(0, 31); 
			}
			_userName = newValue;
			dispatchEvent(new Event('userNameChange'));
		}
		
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
			
			palaceController = new PalaceController();
			palaceController.client = this;
		}
		
		public function gotoURL(url:String):void {
			var event:PalaceEvent = new PalaceEvent('gotoURL');
			event.url = url;
			dispatchEvent(event);
		}
		
		private function resetState():void {
			palaceController.clearAlarms();
			needToRunSignonHandlers = true;
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
			currentRoom.clearLooseProps();
			currentRoom.hotSpots.removeAll();
			currentRoom.drawBackCommands.removeAll();
			currentRoom.drawFrontCommands.removeAll();
			currentRoom.drawLayerHistory = new Vector.<uint>();
			currentRoom.id = 0;
			population = 0;
			serverName = "No Server"
			roomList.removeAll();
			userList.removeAll();
			socket = null;
			
			if (puidChanged) {
				trace("Server changed our puid and needs us to reconnect.");
				puidChanged = false;
				connect(userName, host, port);				
			}
		}
		
		// ***************************************************************
		// Begin public functions for user interaction
		// ***************************************************************
		
		public function connect(userName:String, host:String, port:uint = 9998, initialRoom:uint = 0):void {
			PalaceClient.loaderContext.checkPolicyFile = true;
			
			host = host.toLowerCase();
			var match:Array = host.match(/^palace:\/\/(.*)$/);
			if (match && match.length > 0) {
				host = match[1];
			}
			
			this.host = host;
			this.port = port;
			this.initialRoom = initialRoom;
			this.userName = userName;
			
			if (connected || (socket && socket.connected)) {
				disconnect();
			}
			else {
				resetState();
			}
			connecting = true;
			dispatchEvent(new PalaceEvent(PalaceEvent.CONNECT_START));
			socket = new Socket(this.host, this.port);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			socket.addEventListener(Event.CONNECT, onConnect);
			socket.addEventListener(Event.CLOSE, onClose);
		}
		
		public function authenticate(username:String, password:String):void {
			if (socket && socket.connected) {
				trace("Sending auth response");
				var userPass:ByteArray = PalaceEncryption.getInstance().encrypt(username + ":" + password);
				socket.writeInt(OutgoingMessageTypes.AUTHRESPONSE);
				socket.writeInt(userPass.length + 1);
				socket.writeInt(0);
				socket.writeByte(userPass.length);
				socket.writeBytes(userPass);
				socket.flush();
			}
		}
		
		public function disconnect():void {
			if (socket && socket.connected) {
				palaceController.triggerHotspotEvents(IptEventHandler.TYPE_LEAVE);
				palaceController.triggerHotspotEvents(IptEventHandler.TYPE_SIGNOFF);
				socket.writeInt(OutgoingMessageTypes.BYE);
				socket.writeInt(0);
				socket.writeInt(id);
				socket.flush();
				socket.close();
			}
			resetState();
		}
		
		public function changeName(newName:String):void {
			userName = newName;
			if (socket && socket.connected) {
				socket.writeInt(OutgoingMessageTypes.CHANGE_NAME);
				socket.writeInt(userName.length + 1);
				socket.writeInt(0);
				socket.writeByte(userName.length);
				socket.writeMultiByte(userName, 'Windows-1252');
				socket.flush();
			}
		}

		public function roomChat(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
			trace("Saying: " + message);
			var messageBytes:ByteArray = PalaceEncryption.getInstance().encrypt(message, utf8, 254);
			messageBytes.position = 0;

			socket.writeInt(OutgoingMessageTypes.SAY);
			socket.writeInt(messageBytes.length + 3);
			socket.writeInt(id);
			socket.writeShort(messageBytes.length + 3);
			socket.writeBytes(messageBytes);
			socket.writeByte(0);
			socket.flush();
		}
		
		public function privateMessage(message:String, userId:int):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
						
			var messageBytes:ByteArray = PalaceEncryption.getInstance().encrypt(message, utf8, 254);
			messageBytes.position = 0;
			
			socket.writeInt(OutgoingMessageTypes.WHISPER);
			socket.writeInt(messageBytes.length + 7); // length + 2 bytes for short, + 4 bytes for id
			socket.writeInt(id);
			socket.writeInt(userId);
			socket.writeShort(messageBytes.length + 3);
			socket.writeBytes(messageBytes);
			socket.writeByte(0);
			socket.flush();
		}
		
		public function say(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
			
			if (handleClientCommand(message)) { return; }
			
			whochat = currentUser.id;
			if (message.charAt(0) == "/") {
				// Run iptscrae
				palaceController.executeScript(message.substr(1));
				return;
			}
			
			if (message.toLocaleLowerCase() == "clean") {
				deleteLooseProp(-1); // clear loose props
				return;
			}
			
			chatstr = message;
			
			// Handle room outchat handlers
			palaceController.triggerHotspotEvents(IptEventHandler.TYPE_OUTCHAT);
			
			var whispering:Boolean = currentRoom.selectedUser != null;
			
			if (whispering) {
				privateMessage(chatstr, currentRoom.selectedUser.id);
			}
			else {
				roomChat(chatstr);
			}
		}
		
		public function globalMessage(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
			
			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			trace("GLOBALMSG");
			var messageBytes:ByteArray = new ByteArray();
			messageBytes.writeMultiByte(message, "Windows-1252");
			messageBytes.position = 0;
			
			socket.writeInt(OutgoingMessageTypes.GLOBAL_MSG);
			socket.writeInt(messageBytes.length + 1);
			socket.writeInt(0);
			
			socket.writeBytes(messageBytes);
			socket.writeByte(0);
			socket.flush()
		}
		
		public function roomMessage(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
			trace("ROOMMSG");
			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			
			var messageBytes:ByteArray = new ByteArray();
			messageBytes.writeMultiByte(message, "Windows-1252");
			messageBytes.position = 0;
			
			socket.writeInt(OutgoingMessageTypes.ROOM_MSG);
			socket.writeInt(messageBytes.length + 1);
			socket.writeInt(0);
			
			socket.writeBytes(messageBytes);
			socket.writeByte(0);
			socket.flush()
		}
		
		public function superUserMessage(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
			trace("SUSRMSG");
			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			
			var messageBytes:ByteArray = new ByteArray();
			messageBytes.writeMultiByte(message, "Windows-1252");
			messageBytes.position = 0;
			
			socket.writeInt(OutgoingMessageTypes.SUSR_MSG);
			socket.writeInt(messageBytes.length + 1);
			socket.writeInt(0);
			
			socket.writeBytes(messageBytes);
			socket.writeByte(0);
			socket.flush()
		}
		
		private function handleClientCommand(message:String):Boolean {
			var clientCommandMatch:Array = message.match(/^~(\w+) (.*)$/);
			if (clientCommandMatch && clientCommandMatch.length > 0) {
				var command:String = clientCommandMatch[1];
				var argument:String = clientCommandMatch[2];
				switch (command) {
					case "susr":
						trace("You are attempting to become a superuser with password \"" +
								argument + "\"");
						becomeWizard(argument);
						break;
					default:
						trace("Unrecognized command: " + command + " argument " + argument);
				}
				return true;
			}
			else {
				return false;
			}
		}
		
		public function becomeWizard(password:String):void {
			var passwordBytes:ByteArray = PalaceEncryption.getInstance().encrypt(password, false);
			passwordBytes.position = 0;
			socket.writeInt(OutgoingMessageTypes.SUPERUSER);
			socket.writeInt(passwordBytes.length + 1);
			socket.writeInt(0);
			socket.writeByte(passwordBytes.length);
			socket.writeBytes(passwordBytes);
			socket.flush();
		}
		
		public function move(x:int, y:int):void {
			if (!connected || !currentUser || x < 0 || y < 0) {
				return;
			}
			
			trace("Moving user to " + x + "," + y);
			
			socket.writeInt(OutgoingMessageTypes.MOVE);
			socket.writeInt(4);
			socket.writeInt(id);
			socket.writeShort(y);
			socket.writeShort(x);
			socket.flush();
			
			currentUser.x = x;
			currentUser.y = y;
		}
		
		public function setFace(face:int):void {
			if (!connected || currentUser.face == face) {
				return;
			}
			socket.writeInt(OutgoingMessageTypes.USER_FACE);
			socket.writeInt(2);
			socket.writeInt(id);
			face = Math.max(Math.min(face, 15), 0);
			socket.writeShort(face);
			currentUser.face = face;
			socket.flush();
		}
		
		public function setColor(color:int):void {
			if (!connected || currentUser.color == color) {
				return;
			}
			color = Math.max(Math.min(color, 15), 0);
			currentUser.color = color;
			socket.writeInt(OutgoingMessageTypes.USER_COLOR);
			socket.writeInt(2);
			socket.writeInt(id);
			socket.writeShort(color);
			socket.flush();
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
			palaceController.clearAlarms();
			
			needToRunSignonHandlers = false;
			
			palaceController.triggerHotspotEvents(IptEventHandler.TYPE_LEAVE);
			
			socket.writeInt(OutgoingMessageTypes.GOTO_ROOM);
			socket.writeInt(2); // length
			socket.writeInt(id);
			socket.writeShort(roomId);
			socket.flush();
			
			currentRoom.selectedUser = null;
		}
		
		public function lockDoor(roomId:int, spotId:int):void {
			socket.writeInt(OutgoingMessageTypes.DOOR_LOCK);
			socket.writeInt(4);
			socket.writeInt(0);
			socket.writeShort(roomId);
			socket.writeShort(spotId);
			socket.flush();
		}
		
		public function unlockDoor(roomId:int, spotId:int):void {
			socket.writeInt(OutgoingMessageTypes.DOOR_UNLOCK);
			socket.writeInt(4);
			socket.writeInt(0);
			socket.writeShort(roomId);
			socket.writeShort(spotId);
			socket.flush();
		}
		
		public function setSpotState(roomId:int, spotId:int, spotState:int):void {
			trace("Setting spot state");
			socket.writeInt(OutgoingMessageTypes.SPOT_STATE);
			socket.writeInt(6);
			socket.writeInt(0);
			socket.writeShort(roomId);
			socket.writeShort(spotId);
			socket.writeShort(spotState);
			socket.flush();
		}
		
		public function moveLooseProp(propIndex:int, x:int, y:int):void {
			socket.writeInt(OutgoingMessageTypes.PROP_MOVE);
			socket.writeInt(8);
			socket.writeInt(0);
			socket.writeInt(propIndex);
			socket.writeShort(y);
			socket.writeShort(x);
			socket.flush();
		}
		
		public function addLooseProp(propId:int, propCrc:uint, x:int, y:int):void {
			socket.writeInt(OutgoingMessageTypes.PROP_NEW);
			socket.writeInt(12);
			socket.writeInt(0);
			
			socket.writeInt(propId);
			socket.writeUnsignedInt(propCrc);
			socket.writeShort(y);
			socket.writeShort(x);
			
			socket.flush();
		}
		
		public function deleteLooseProp(propIndex:int):void {
			socket.writeInt(OutgoingMessageTypes.PROP_DELETE);
			socket.writeInt(4);
			socket.writeInt(0);
			
			socket.writeInt(propIndex);
			
			socket.flush();
		}
		
		public function sendDrawPacket(drawRecord:PalaceDrawRecord):void {
			var data:ByteArray = drawRecord.generatePacket(socket.endian);
			socket.writeInt(OutgoingMessageTypes.DRAW);
			socket.writeInt(data.length);
			socket.writeInt(0);
			socket.writeBytes(data);
			socket.flush();
		}
		
		public function requestAsset(assetType:int, assetId:uint, assetCrc:uint):void {
			// Assets are requested in packets of up to 20 requests, separated by 1000ms
			// to prevent flooding the server and getting killed.
			if (!connected) {
				return;	
			}
			trace("Requesting asset (Type:" + assetType.toString(16) + ") (ID:" + assetId + ") (CRC:" + assetCrc + ")");
			if (assetRequestQueueTimer == null) {
				assetRequestQueueTimer = new Timer(100, 1);
				assetRequestQueueTimer.addEventListener(TimerEvent.TIMER, sendAssetRequests);
				assetRequestQueueTimer.start();
			}
			
			assetRequestQueue.push([
				assetType,
				assetId,
				assetCrc
			]);
			
			assetRequestQueueTimer.reset();
			assetRequestQueueTimer.start();
		}
		
		private function sendAssetRequests(event:TimerEvent=null):void {
			if (!connected || !socket || !socket.connected) {
				assetRequestQueue = [];
				return;
			}
			
			if (assetRequestQueue.length == 0) {
				assetRequestQueueTimer.reset();
				assetRequestQueueTimer.delay = 100;
				return;
			}

			// only do 20 requests at a time
			var count:int = (assetRequestQueue.length > 20) ? 20 : assetRequestQueue.length;
			
			trace("Requesting a group of props");
			for (var i:int = 0; i < count; i++) {
				var request:Array = assetRequestQueue.shift() as Array;
				socket.writeInt(OutgoingMessageTypes.REQUEST_ASSET);
				socket.writeInt(12);
				socket.writeInt(id);
				for (var j:int = 0; j < 3; j++) {
					socket.writeInt(request[j]);
				}
			}
			socket.flush();
			
			// If there are still assets left to request, schedule another timer.
			if (assetRequestQueue.length > 0) {
				assetRequestQueueTimer.reset();
				assetRequestQueueTimer.delay = 1000;
				assetRequestQueueTimer.start();
			}
		}
		
		private function sendPropToServer(prop:PalaceProp):void {
			if (prop.width != 44 || prop.height != 44 ||
				prop.verticalOffset > 44 || prop.verticalOffset < -44 ||
				prop.horizontalOffset > 44 || prop.horizontalOffset < -44) {
				// web service big prop... ignore request.
				return;
			}
			
			var assetResponse:ByteArray = prop.assetData(socket.endian);
			socket.writeInt(OutgoingMessageTypes.ASSET_REGI);
			socket.writeInt(assetResponse.length);
			socket.writeInt(0);
			
			socket.writeBytes(assetResponse);
		} 

		public function get currentUser():PalaceUser {
			return currentRoom.getUserById(id);
		}
		
		public function updateUserProps():void {
			if (!connected) {
				return;
			}
			var user:PalaceUser = currentUser;
			socket.writeInt(OutgoingMessageTypes.USER_PROP);
			// size -- 8 bytes per prop, 4 bytes for number of props 
			socket.writeInt(user.props.length * 8 + 4);
			socket.writeInt(id);
			socket.writeInt(user.props.length);
			for each (var prop:PalaceProp in user.props) {
				socket.writeInt(prop.asset.id);
				//socket.writeUnsignedInt(prop.asset.crc);
				socket.writeUnsignedInt(0);
			}
			socket.flush();
		}
		
		
		
		// ***************************************************************
		// Begin private functions to messages from the server
		// ***************************************************************
				
		private function onConnect(event:Event):void {
			//PalaceSoundPlayer.getInstance().playConnectionPing();
			connected = true;
			state = STATE_HANDSHAKING;
			trace("Connected");
		}
		
		private function onClose(event:Event):void {
			trace("Disconnected");
			onSocketData();
			connected = false;
			disconnect();
			dispatchEvent(new PalaceEvent(PalaceEvent.DISCONNECTED));
			//Alert.show("Connection to server lost.");
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
								
							case IncomingMessageTypes.SERVER_DOWN:
								handleServerDown(size, p);
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
								
							case IncomingMessageTypes.XTALK:
								handleReceiveXTalk(size, p);
								break;
								
							case IncomingMessageTypes.XWHISPER:
								handleReceiveXWhisper(size, p);
								break;
							
							case IncomingMessageTypes.TALK:
								handleReceiveTalk(size, p);
								break;
								
							case IncomingMessageTypes.WHISPER:
								handleReceiveWhisper(size, p);
								break;
							
							case IncomingMessageTypes.ASSET_INCOMING:
								handleReceiveAsset(size, p);
								break;
								
							case IncomingMessageTypes.ASSET_QUERY:
								handleAssetQuery(size, p);
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
								
							case IncomingMessageTypes.PROP_MOVE:
								handlePropMove(size, p);
								break;
								
							case IncomingMessageTypes.PROP_DELETE:
								handlePropDelete(size, p);
								break;
								
							case IncomingMessageTypes.PROP_NEW:
								handlePropNew(size, p);
								break;
							
							case IncomingMessageTypes.DOOR_LOCK:
								handleDoorLock(size, p);
								break;
							
							case IncomingMessageTypes.DOOR_UNLOCK:
								handleDoorUnlock(size, p);
								break;
								
							case IncomingMessageTypes.PICT_MOVE:
								handlePictMove(size, p);
								break;
								
							case IncomingMessageTypes.SPOT_STATE:
								handleSpotState(size, p);
								break;
								
							case IncomingMessageTypes.SPOT_MOVE:
								handleSpotMove(size, p);
								break;
							case IncomingMessageTypes.DRAW_CMD:
								handleDrawCommand(size, p);
								break;
	//						case IncomingMessage.CONNECTION_DIED:
	//							handleConnectionDied(size, p);
	//							break;
	//							
	//						case IncomingMessage.INCOMING_FILE:
	//							handleIncomingFile(size, p);
	//							break;
							
							case IncomingMessageTypes.AUTHENTICATE:
								handleAuthenticate(size, p);
								break;
							
							case IncomingMessageTypes.BLOWTHRU:
								trace("Blowthru message.");
								// fall through to default...
							default:
								trace("Unhandled MessageID: " + messageID.toString() + " (" + messageID.toString(16) + ") - " +
									  "Size: " + size + " - referenceId: " + p);
								var dataToDump:Array = [];
								for (var i:int = 0; i < size; i++) {
									dataToDump[i] = socket.readUnsignedByte();
								}
								outputHexView(dataToDump);
								//_throwAwayData(size, p);
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
			if (connecting) {
				var e:PalaceEvent = new PalaceEvent(PalaceEvent.CONNECT_FAILED);
				e.text = "Unable to connect to " + host + ":" + port + ".\n(" + event.text + ")"
				dispatchEvent(e);
			}
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
					Alert.show("Got MSG_TROPSER.  Don't know how to proceed.","Logon Error");
					break;
				case IncomingMessageTypes.LITTLE_ENDIAN_SERVER: // MSG_DIYIT
					trace("Server is Little Endian");
					socket.endian = Endian.LITTLE_ENDIAN;
					size = socket.readInt();
					p = socket.readInt();
					logOn(size, p);
					break;
				case IncomingMessageTypes.BIG_ENDIAN_SERVER: // MSG_TIYID
					trace("Server is Big Endian");
					socket.endian = Endian.BIG_ENDIAN;
					size = socket.readInt();
					p = socket.readInt();
					logOn(size, p);
					break;
				default:
					trace("Unexpected MessageID while logging on: " + messageID.toString());
					break;
			}
		}
		
		// Server Op Handlers
		private function logOn(size:int, referenceId:int):void {
			var i:int;
			
			trace("Logging on.  a: " + size + " - b: " + referenceId);
			// a is validation
			currentRoom.selfUserId = id = referenceId;


			// LOGON
			socket.writeInt(OutgoingMessageTypes.LOGON);
			socket.writeInt(128); // struct AuxRegistrationRec is 128 bytes
			socket.writeInt(0); // RefNum unused in LOGON message

			// regCode crc
			socket.writeInt(regCRC);  // Guest regCode crc
			
			// regCode counter
			socket.writeInt(regCounter);  // Guest regCode counter

			// Username has to be Windows-1252 and up to 31 characters
			if (userName.length > 31) {
				userName = userName.slice(0,31);
			}
			socket.writeByte(userName.length);
			socket.writeMultiByte(userName, 'Windows-1252');
			i = 31 - (userName.length);
			for(; i > 0; i--) { 
				socket.writeByte(0);
			}

			for (i=0; i < 32; i ++) {
				socket.writeByte(0);
			}			
	
			// auxFlags
			socket.writeInt(AUXFLAGS_AUTHENTICATE | AUXFLAGS_WIN32);

			// puidCtr
			socket.writeInt(puidCounter);
	
        	// puidCRC
			socket.writeInt(puidCRC);
	
        	// demoElapsed - no longer used
			socket.writeInt(0);
	
        	// totalElapsed - no longer used
			socket.writeInt(0);
	
        	// demoLimit - no longer used
			socket.writeInt(0);
        
			// desired room id
			socket.writeShort(initialRoom);

			// Protocol spec lists these as reserved, and says there shouldn't
			// be anything put in them... but the server records these 6 bytes
			// in the log file.  So I'll exploit that.
			socket.writeMultiByte("OPNPAL", "iso-8859-1");
	
			// ulRequestedProtocolVersion -- ignored on server
	        socket.writeInt(0);

			// ulUploadCaps
    	    socket.writeInt(
    	    	ULCAPS_ASSETS_PALACE  // This is a lie... for now
    	    );

        	// ulDownloadCaps
        	// We have to lie about our capabilities so that servers don't
        	// reject OpenPalace as a Hacked client.
	        socket.writeInt(
	        	DLCAPS_ASSETS_PALACE |
	        	DLCAPS_FILES_PALACE |  // This is a lie...
	        	DLCAPS_FILES_HTTPSRVR
	        );

        	// ul2DEngineCaps -- Unused
        	socket.writeInt(0);

        	// ul2dGraphicsCaps -- Unused
        	socket.writeInt(0);

			// ul3DEngineCaps -- Unused
        	socket.writeInt(0);
        	
			socket.flush();
			
			state = STATE_READY;
			connecting = false;
			dispatchEvent(new PalaceEvent(PalaceEvent.CONNECT_COMPLETE));
		}
		
		
		// not fully implemented
		// This is only sent when the server is running in "guests-are-members" mode.
		private function alternateLogon(size:int, referenceId:int):void {
			// This is pointless... it's basically echoing back the logon packet
			// that we sent to the server.
			// the only reason we support this is so that certain silly servers
			// can change our puid and ask us to reconnect "for security
			// reasons"
			
			 var crc:uint = socket.readUnsignedInt();
			 var counter:uint = socket.readUnsignedInt();
			 var userNameLength:int = socket.readUnsignedByte();
			 
			 var userName:String = socket.readMultiByte(userNameLength, 'Windows-1252');
			 for (var i:int = 0; i<31-userNameLength; i++) {
			 	socket.readByte(); // padding on the end of the username
			 }
			 for (i=0; i<32; i++) {
			 	socket.readByte(); // wiz password field
			 }
			 var auxFlags:uint = socket.readUnsignedInt();
			 var puidCtr:uint = socket.readUnsignedInt();
			 var puidCRC:uint = socket.readUnsignedInt();
			 var demoElapsed:uint = socket.readUnsignedInt();
			 var totalElapsed:uint = socket.readUnsignedInt();
			 var demoLimit:uint = socket.readUnsignedInt();
			 var desiredRoom:int = socket.readShort();
			 var reserved:String = socket.readMultiByte(6,'iso-8859-1');
			 var ulRequestedProtocolVersion:uint = socket.readUnsignedInt();
			 var ulUploadCaps:uint = socket.readUnsignedInt();
			 var ulDownloadCaps:uint = socket.readUnsignedInt();
			 var ul2DEngineCaps:uint = socket.readUnsignedInt();
			 var ul2DGraphicsCaps:uint = socket.readUnsignedInt();
			 var ul3DEngineCaps:uint = socket.readUnsignedInt();
			 
			 if (puidCtr != this.puidCounter || puidCRC != this.puidCRC) {
				trace("PUID Changed by server");
			 	this.puidCRC = puidCRC;
			 	this.puidCounter = puidCtr;
			 	puidChanged = true;
			 }
		}
		
		private function handleReceiveServerVersion(size:int, referenceId:int):void {
			version = referenceId;
			trace("Server version: " + referenceId);
		}
		
		private function handleReceiveServerInfo(size:int, referenceId:int):void {
			serverInfo = new PalaceServerInfo();
			serverInfo.permissions = socket.readInt();
			var size:int = Math.abs(socket.readByte());
			serverName = serverInfo.name = socket.readMultiByte(size, 'Windows-1252');

			// Weird -- this message is supposed to include options,
			// and upload/download capabilities, but doesn't.
//			serverInfo.options = socket.readUnsignedInt();
//			serverInfo.uploadCapabilities = socket.readUnsignedInt();
//			serverInfo.downloadCapabilities = socket.readUnsignedInt();
			trace("Server name: " + serverName);
		}
		
		private function handleAuthenticate(size:int, referenceId:int):void {
			trace("Authentication requested.");
			dispatchEvent(new PalaceEvent(PalaceEvent.AUTHENTICATION_REQUESTED));
		}
		
		// not fully implemented
		private function handleReceiveUserStatus(size:int, referenceId:int):void {
			if (currentUser) {
				currentUser.flags = socket.readShort();
			}
			else {
				temporaryUserFlags = socket.readShort();
			}
			var array:Array = [];
			var bytesRemaining:int = size - 2;
			for (var i:int = 0; i < bytesRemaining; i ++) {
				array.push(socket.readUnsignedByte());
			}
			trace("Interesting... there is more to the user status message than just the documented flags:");
			outputHexView(array)
		}
		
		//class c2
		private function handleReceiveUserLog(size:int, referenceId:int):void {
			population = socket.readInt();
			recentLogonUserIds.addItem(referenceId);
			var timer:Timer = new Timer(15000, 1);
			timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {
				var index:int = recentLogonUserIds.getItemIndex(referenceId);
				if (index != -1) {
					recentLogonUserIds.removeItemAt(index);
				}
			});
			timer.start();
			trace("User ID: " + referenceId + " just logged on.  Population: " + population);
		}
		
		private function handleReceiveMediaServer(size:int, referenceId:int):void {
			mediaServer = socket.readMultiByte(size, 'Windows-1252');
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
			
			var bufferLength:int = 57 - outputLineHex.length;
			var bufferString:String = "";
			for (var i:int = 0; i < bufferLength; i ++) {
				bufferString += " ";
			}
			
			output = output.concat(outputLineHex, bufferString, outputLineAscii, "\n");
			trace(output);
		}

		
		// not fully implemented
		private function handleReceiveRoomDescription(size:int, referenceId:int):void {
			var messageBytes:ByteArray = new ByteArray();
			messageBytes.endian = socket.endian;
			socket.readBytes(messageBytes, 0, size);
			
			var roomDescription:RoomDescription = new RoomDescription();
			roomDescription.read(messageBytes, referenceId);
			
			
			messageBytes.position = 0;
			
			var roomFlags:int = messageBytes.readInt();
			var face:int = messageBytes.readInt();
			var roomID:int = messageBytes.readShort();
			currentRoom.id = roomID;
			var roomNameOffset:int = messageBytes.readShort();
			var imageNameOffset:int = messageBytes.readShort();
			var artistNameOffset:int = messageBytes.readShort();
			var passwordOffset:int = messageBytes.readShort();
			var hotSpotCount:int = messageBytes.readShort();
			var hotSpotOffset:int = messageBytes.readShort();
			var imageCount:int = messageBytes.readShort();
			var imageOffset:int = messageBytes.readShort();
			var drawCommandsCount:int = messageBytes.readShort();
			var firstDrawCommand:int = messageBytes.readShort();
			var peopleCount:int = messageBytes.readShort();
			var loosePropCount:int = messageBytes.readShort();
			var firstLooseProp:int = messageBytes.readShort();
			messageBytes.readShort();
			var roomDataLength:int = messageBytes.readShort();
			var rb:Array = new Array(roomDataLength);

			trace("Reading in room description: " + roomDataLength + " bytes to read.");
			for (var i:int = 0; i < roomDataLength; i++) {
				rb[i] = messageBytes.readUnsignedByte();
			}
			
			//outputHexView(roomBytes);
			
			var padding:int = size - roomDataLength - 40;
			for (i=0; i < padding; i++) {
				messageBytes.readByte();
			}
			
			var byte:int;
			
			// Room Name
			var roomNameLength:int = rb[roomNameOffset];
			var roomName:String = "";
			var ba:ByteArray = new ByteArray();
			for (i=0; i < roomNameLength; i++) {
				byte = rb[i+roomNameOffset+1];
				ba.writeByte(byte);
			}
			ba.position = 0;
			roomName = ba.readMultiByte(roomNameLength, 'Windows-1252');
			
			// Image Name
			var imageNameLength:int = rb[imageNameOffset];
			var imageName:String = "";
			for (i=0; i < imageNameLength; i++) {
				byte = rb[i+imageNameOffset+1];
				imageName += String.fromCharCode(byte);
			}
			if (PalaceConfig.URIEncodeImageNames) {
				imageName = URI.escapeChars(imageName);
			}

			// Images
			var images:Object = {};
			currentRoom.hotspotBitmapCache = {};
			for (i=0; i < imageCount; i++) {
				var imageOverlay:PalaceImageOverlay = new PalaceImageOverlay();
				var imageBA:ByteArray = new ByteArray();
				for (var j:int=imageOffset; j < imageOffset+12; j++) {
					imageBA.writeByte(rb[j]);
				}
				imageBA.endian = socket.endian;
				imageBA.position = 0;
				imageOverlay.refCon = imageBA.readInt(); // appears unused
				imageOverlay.id = imageBA.readShort();
				var picNameOffset:int = imageBA.readShort(); // pstring offset
				imageOverlay.transparencyIndex = imageBA.readShort();
				trace("Transparency Index: " + imageOverlay.transparencyIndex);
				imageBA.readShort(); // Reserved.  Padding.. field alignment
				var picNameLength:int = rb[picNameOffset];
				var picName:String = "";
				for (j=0; j < picNameLength; j++) {
					var imageNameByte:int = rb[picNameOffset+j+1]; 
					picName += String.fromCharCode(imageNameByte);
				}
				if (PalaceConfig.URIEncodeImageNames) {
					picName = URI.escapeChars(picName);
				}
				imageOverlay.filename = picName;
				images[imageOverlay.id] = imageOverlay; 
				trace("picture id: " + imageOverlay.id + " - Name: " + imageOverlay.filename);
				imageOffset += 12;
			}
			currentRoom.images = images;

			// Hotspots
			currentRoom.hotSpots.removeAll();
			currentRoom.hotSpotsById = {};
			for (i=0; i < hotSpotCount; i++) {
				var hs:PalaceHotspot = new PalaceHotspot();
				hs.readData(socket.endian, rb, hotSpotOffset);
				hotSpotOffset += hs.size;
				currentRoom.hotSpots.addItem(hs);
				currentRoom.hotSpotsById[hs.id] = hs;
			}
			
			// Loose Props
			currentRoom.looseProps.removeAll();
			var tempPropArray:Array = []; 
			var propOffset:int = firstLooseProp;
			currentRoom.clearLooseProps();
			for (i=0; i < loosePropCount; i++) {
				var looseProp:PalaceLooseProp = new PalaceLooseProp();
				looseProp.loadData(socket.endian, rb, propOffset);
				propOffset = looseProp.nextOffset;
				currentRoom.addLooseProp(looseProp.id, looseProp.crc, looseProp.x, looseProp.y, true);
			}
			
			// Draw Commands
			currentRoom.drawFrontCommands.removeAll();
			currentRoom.drawBackCommands.removeAll();
			var drawCommandOffset:int = firstDrawCommand;
			for (i=0; i < drawCommandsCount; i++) {
				var drawRecord:PalaceDrawRecord = new PalaceDrawRecord();
				drawRecord.readData(socket.endian, rb, drawCommandOffset);
				drawCommandOffset = drawRecord.nextOffset;
				if (drawRecord.layer == PalaceDrawRecord.LAYER_FRONT) {
//					trace("Draw front layer command at offset: " + drawCommandOffset);
					currentRoom.drawFrontCommands.addItem(drawRecord);
					currentRoom.drawLayerHistory.push(PalaceDrawRecord.LAYER_FRONT);
				}
				else{
//					trace("Draw back layer command at offset: " + drawCommandOffset);
					currentRoom.drawBackCommands.addItem(drawRecord);
					currentRoom.drawLayerHistory.push(PalaceDrawRecord.LAYER_BACK);
				}
				
			}
			
			currentRoom.backgroundFile = imageName;
			trace("Background Image: " + currentRoom.backgroundFile);
			
			currentRoom.name = roomName;
			trace("Room name: " + currentRoom.name);
			
			debugData = new DebugData(currentRoom);
			
			currentRoom.dimRoom(100);
			
			var roomChangeEvent:PalaceEvent = new PalaceEvent(PalaceEvent.ROOM_CHANGED);
			dispatchEvent(roomChangeEvent);
		}
		
		private function handleDrawCommand(size:int, referenceId:int):void {	
			
			var pBytes:Array = [];
			for (var i:int = 0; i < size; i++) {
				pBytes[i] = socket.readUnsignedByte();
			}

			var drawRecord:PalaceDrawRecord = new PalaceDrawRecord();
			drawRecord.readData(socket.endian, pBytes, 0);
			
			
			if (drawRecord.command == PalaceDrawRecord.CMD_DELETE) {
				//undo
				if (currentRoom.drawFrontCommands.length == 0 &&
				    currentRoom.drawBackCommands.length == 0) {
					return;
				}
				if (currentRoom.drawLayerHistory.pop() == PalaceDrawRecord.LAYER_FRONT) {
					currentRoom.drawFrontCommands.removeItemAt(currentRoom.drawFrontCommands.length-1);
				}
				else {
					currentRoom.drawBackCommands.removeItemAt(currentRoom.drawBackCommands.length-1);
				}
				return;
			}
			else if (drawRecord.command == PalaceDrawRecord.CMD_DETONATE) {
				//delete all
				currentRoom.drawFrontCommands.removeAll();
				currentRoom.drawBackCommands.removeAll();
				currentRoom.drawLayerHistory = new Vector.<uint>();
				return;
			}
			
			var drawCommandOffset:int = drawRecord.nextOffset;
			
			if (drawRecord.layer == PalaceDrawRecord.LAYER_FRONT) {
				currentRoom.drawFrontCommands.addItem(drawRecord);
				currentRoom.drawLayerHistory.push(PalaceDrawRecord.LAYER_FRONT);
			}
			else {
				currentRoom.drawBackCommands.addItem(drawRecord);
				currentRoom.drawLayerHistory.push(PalaceDrawRecord.LAYER_BACK);
			}
		}
		
		// List of users in current room
		private function handleReceiveUserList(size:int, referenceId:int):void {
			// referenceId is count
			currentRoom.removeAllUsers();
			
			for(var i:int = 0; i < referenceId; i++){
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
				var userName:String = socket.readMultiByte(userNameLength, 'Windows-1252'); // Length = 32
				socket.readMultiByte(31-userNameLength, 'Windows-1252');

				var user:PalaceUser = new PalaceUser();
				user.isSelf = Boolean(userId == id);
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
		
		private function handleReceiveRoomList(size:int, referenceId:int):void {
			var numAdded:int = 0;
			var roomCount:int = referenceId;
			roomList.removeAll();
			for (var i:int = 0; i < roomCount; i++) {
				var room:PalaceRoom = new PalaceRoom();
				room.id = socket.readInt();
				room.flags = socket.readShort();
				room.userCount = socket.readShort();
				var length:int = socket.readByte();
				var paddedLength:int = (length + (4 - (length & 3))) - 1;
				room.name = socket.readMultiByte(paddedLength, 'Windows-1252');
				roomList.addItem(room);
				roomById[room.id] = room;
			}
			trace("There are " + roomCount + " rooms in this palace.");
		}
		
		private function handleReceiveFullUserList(size:int, referenceId:int):void {
			userList.removeAll();
			var userCount:int = referenceId;
			for (var i:int = 0; i < userCount; i++) {
				var user:PalaceUser = new PalaceUser();
				user.id = socket.readInt();
				user.isSelf = Boolean(user.id == id);
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
// Can't support UTF-8 usernames yet				
//				if (utf8) {
//					user.name = socket.readUTFBytes(userNamePaddedLength);
//				}
//				else {
					user.name = socket.readMultiByte(userNamePaddedLength, 'Windows-1252');
//				}
				//trace("User List - got user: " + user.name);
				userList.addItem(user);
			}
			trace("There are " + userList.length + " users in this palace.");
		}
		
		private function handleReceiveRoomDescend(size:int, referenceId:int):void {
			// We're done receiving room description & user list
		}
		
		private function handleUserNew(size:int, referenceId:int):void {
			var userId:int = socket.readInt();
			if (recentLogonUserIds.getItemIndex(userId) != -1) {
				// Recently logged on user.
				var index:int = recentLogonUserIds.getItemIndex(userId);
				if (index != -1) {
					recentLogonUserIds.removeItemAt(index);
				}
				PalaceSoundPlayer.getInstance().playConnectionPing();
			}
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
// Can't support UTF-8 usernames yet.
//			if (utf8) {
//				userName = socket.readUTFBytes(userNameLength); // Length = 32
//			}
//			else {
				userName = socket.readMultiByte(userNameLength, 'Windows-1252'); // Length = 32
//			}
			socket.readMultiByte(31-userNameLength, 'Windows-1252');
			//userName = userName.substring(1);

			var user:PalaceUser = new PalaceUser();
			user.isSelf = Boolean(userId == id);
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
			
			if (user.id == id) {
				// Self entered
				// Signon handlers
				setTimeout(function():void {
					if (needToRunSignonHandlers) {
						
						// download the room/user lists when you first log on.
						requestRoomList();
						requestUserList();
						
						palaceController.triggerHotspotEvents(IptEventHandler.TYPE_SIGNON);
						needToRunSignonHandlers = false;
					}
					
					// Enter handlers
					palaceController.triggerHotspotEvents(IptEventHandler.TYPE_ENTER);
				}, 20);
			}
		}

		private function handlePing(size:int, referenceId:int):void {
			if (referenceId != id) {
				trace("ID didn't match during ping, bailing");
				return;
			}
			
			socket.writeInt(OutgoingMessageTypes.PING_BACK);
			socket.writeInt(0);
			socket.writeInt(0);
			socket.flush();
			
			trace("Pinged.");
		}
		
		// Unencrypted TALK message
		private function handleReceiveTalk(size:int, referenceId:int):void {
			var messageBytes:ByteArray = new ByteArray();
			var message:String;
			if (utf8) {
				message = socket.readUTFBytes(size-1);
			}
			else {
				message = socket.readMultiByte(size-1, 'Windows-1252');
			}
			socket.readByte();
			if (referenceId == 0) {
				currentRoom.roomMessage(message);
				trace("Got Room Message: " + message);
			}
			else {
				whochat = referenceId;
				if (message.length > 0) {
					chatstr = message;
					palaceController.triggerHotspotEvents(IptEventHandler.TYPE_INCHAT);
					currentRoom.chat(referenceId, chatstr, message);
				}
				trace("Got talk from userID " + referenceId + ": " + message);
			}
		}
		
		private function handleReceiveWhisper(size:int, referenceId:int):void {
			var messageBytes:ByteArray = new ByteArray();
			var message:String;
			if (utf8) {
				message = socket.readUTFBytes(size-1);
			}
			else {
				message = socket.readMultiByte(size-1, 'Windows-1252');
			}
			socket.readByte();
			if (referenceId == 0) {
				currentRoom.roomWhisper(message);
				trace("Got ESP: " + message);
			}
			else {
				whochat = referenceId;
				if (message.length > 0) {
					chatstr = message;
					palaceController.triggerHotspotEvents(IptEventHandler.TYPE_INCHAT);
					currentRoom.whisper(referenceId, chatstr, message);
				}
				trace("Got whisper from userID " + referenceId + ": " + message);
			}
		}
		
		private function handleReceiveXTalk(size:int, referenceId:int):void {
			var length:int = socket.readShort();
			trace("XTALK.  Size: " + size + " Length: " + length);
			var messageBytes:ByteArray = new ByteArray();
			socket.readBytes(messageBytes, 0, length-3); // Length field lies
			socket.readByte(); // Last byte is unnecessary?
			var message:String = PalaceEncryption.getInstance().decrypt(messageBytes, utf8);
			chatstr = message;
			whochat = referenceId;
			palaceController.triggerHotspotEvents(IptEventHandler.TYPE_INCHAT);
			currentRoom.chat(referenceId, chatstr, message);
			trace("Got xtalk from userID " + referenceId + ": " + chatstr);
		}
		
		private function handleReceiveXWhisper(size:int, referenceId:int):void {
			var length:int = socket.readShort();
			trace("XWHISPER.  Size: " + size + " Length: " + length);
			var messageBytes:ByteArray = new ByteArray();
			socket.readBytes(messageBytes, 0, length-3); // Length field lies.
			socket.readByte(); // Last byte is unnecessary?
			var message:String = PalaceEncryption.getInstance().decrypt(messageBytes, utf8);
			chatstr = message;
			whochat = referenceId;
			palaceController.triggerHotspotEvents(IptEventHandler.TYPE_INCHAT);
			
			currentRoom.whisper(referenceId, chatstr, message);
			trace("Got xwhisper from userID " + referenceId + ": " + chatstr);
		}
		
		private function handleMovement(size:int, referenceId:int):void {
			// a is four, b is userID
			var y:int = socket.readShort();
			var x:int = socket.readShort();
			var user:PalaceUser = currentRoom.getUserById(referenceId);
			user.x = x;
			user.y = y;
			trace("User " + referenceId + " moved to " + x + "," + y);
		}
		
		private function handleUserColor(size:int, referenceId:int):void {
			var user:PalaceUser = currentRoom.getUserById(referenceId);
			user.color = socket.readShort();
			trace("User " + referenceId + " changed color to " + user.color); 
		}
		
		private function handleUserFace(size:int, referenceId:int):void {
			var user:PalaceUser = currentRoom.getUserById(referenceId);
			user.face = socket.readShort();
			trace("User " + referenceId + " changed face to " + user.face);
		}
		
		private function handleUserRename(size:int, referenceId:int):void {
			var user:PalaceUser = currentRoom.getUserById(referenceId);
			var userNameLength:int = socket.readByte();
			var userName:String;
// Can't support UTF-8 usernames yet
//			if (utf8) {
//				userName = socket.readUTFBytes(userNameLength);
//			}
//			else {
				userName = socket.readMultiByte(userNameLength, 'Windows-1252');
//			}
			trace("User " + user.name + " changed their name to " + userName);
			user.name = userName;
		}
		
		private function handleUserExitRoom(size:int, referenceId:int):void {
			currentRoom.removeUserById(referenceId);
			trace("User " + referenceId + " left the room");
		}
		
		private function handleUserLeaving(size:int, referenceId:int):void {
			population = socket.readInt();
			if (currentRoom.getUserById(referenceId) != null) {
				currentRoom.removeUserById(referenceId);
				PalaceSoundPlayer.getInstance().playConnectionPing();
			}
			trace("User " + referenceId + " logged off");
		}
		
		private function handleAssetQuery(size:int, referenceId:int):void {
			var type:int = socket.readInt();
			var assetId:int = socket.readInt();
			var assetCrc:uint = socket.readUnsignedInt();
			trace("Got asset request for type: " + type + ", assetId: " + assetId + ", assetCrc: " + assetCrc);
			var prop:PalaceProp = PalacePropStore.getInstance().getProp(null, assetId, assetCrc);

			if (prop.ready) {
				sendPropToServer(prop);
			}
			else {
				prop.addEventListener(PropEvent.PROP_LOADED, handlePropReadyToSend);
			}
		}
		
		private function handlePropReadyToSend(event:PropEvent):void {
			sendPropToServer(event.prop);
		}
		
		private function handleReceiveAsset(size:int, referenceId:int):void {
			var assetType:int = socket.readInt();
			var assetId:int = socket.readInt();
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
				assetName = socket.readMultiByte(nameLength, 'Windows-1252');
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
		
		private function handlePropMove(size:int, referenceId:int):void {
			var propIndex:int = socket.readInt();
			var y:int = socket.readShort();
			var x:int = socket.readShort();
			currentRoom.moveLooseProp(propIndex, x, y);
		}
		
		private function handlePropDelete(size:int, referenceId:int):void {
			var propIndex:int = socket.readInt();
			currentRoom.removeLooseProp(propIndex);
		}
		
		private function handlePropNew(size:int, referenceId:int):void {
			var id:int = socket.readInt();
			var crc:uint = socket.readUnsignedInt();
			var y:int = socket.readShort();
			var x:int = socket.readShort();
			currentRoom.addLooseProp(id, crc, x, y);
		}
		
		private function handleDoorLock(size:int, referenceId:int):void {
			var roomId:int = socket.readShort();
			var spotId:int = socket.readShort();
			trace("Spot id " + spotId + " in room id " + roomId + " has been locked");
			if (roomId == currentRoom.id) {
				var hs:PalaceHotspot = currentRoom.hotSpotsById[spotId];
				hs.changeState(1);
				palaceController.triggerHotspotEvent(hs, IptEventHandler.TYPE_LOCK);
			}
		}
		
		private function handleDoorUnlock(size:int, referenceId:int):void {
			var roomId:int = socket.readShort();
			var spotId:int = socket.readShort();
			trace("Spot id " + spotId + " in room id " + roomId + " has been unlocked");
			if (roomId == currentRoom.id) {
				var hs:PalaceHotspot = currentRoom.hotSpotsById[spotId];
				hs.changeState(0);
				palaceController.triggerHotspotEvent(hs, IptEventHandler.TYPE_UNLOCK);
			}
		}
		
		private function handleSpotState(size:int, referenceId:int):void {
			var roomId:int = socket.readShort();
			var spotId:int = socket.readShort();
			var spotState:int = socket.readUnsignedShort();
			trace("Spot State Changed: Spot id " + spotId + " in room id " + roomId + " is now in state " + spotState);
			if (roomId == currentRoom.id) {
				var hs:PalaceHotspot = currentRoom.hotSpotsById[spotId];
				if (hs != null) {
					hs.changeState(spotState);
				}
				else {
					trace("Unable to access spot id " + spotId); 
				}
			}
		}
		
		
		private function handlePictMove(size:int, referenceId:int):void {
			var roomId:int = socket.readShort();
			var spotId:int = socket.readShort();
			var y:int = socket.readShort();
			var x:int = socket.readShort();
			trace("Picture in HotSpot " + spotId + " in room " + roomId + " moved offset to " + x + "," + y);
			if (roomId != currentRoom.id) { return; }
			var hotSpot:PalaceHotspot = currentRoom.hotSpotsById[spotId];
			if (hotSpot != null) {
				hotSpot.movePicTo(x, y);
			}
		}
		
		private function handleSpotMove(size:int, referenceId:int):void {
			var roomId:int = socket.readShort();
			var spotId:int = socket.readShort();
			var y:int = socket.readShort();
			var x:int = socket.readShort();
			trace("Hotspot " + spotId + " in room " + roomId + " moved to " + x + "," + y);
			if (roomId != currentRoom.id) { return; }
			var hotSpot:PalaceHotspot = currentRoom.hotSpotsById[spotId];
			if (hotSpot != null) {
				hotSpot.moveTo(x, y);
			}
		}

		
		private function handleServerDown(size:int, referenceId:int):void {
			var reason:String = "The connection to the server has been lost.";

			switch (referenceId) {
	            case 4:
	            case 7:
	            	reason = "You have been killed.";
	            	break;
	            case 13:
	                reason = "You have been kicked off this site.";
	                break;
	            case 11:
	            	reason = "Your death penalty is still active.";
	            	break;
	            case 12:
	                reason = "You are not currently allowed on this site.";
	                break;
	            case 6:
	                reason = "Your connection was terminated due to inactivity.";
	                break;
	            case 3:
	                reason = "Your connection was terminated due to flooding";
	                break;
	            case 8:
	                reason = "This Palace is currently full - try again later.";
	                break;
	            case 14:
	                reason = "Guests are not currently allowed on this site.";
	                break;
	            case 5:
	                reason = "This Palace was shut down by its operator.  Try again later.";
	                break;
	            case 9:
	                reason = "You have an invalid serial number.";
	                break;
	            case 10:
	                reason = "There is another user using your serial number.";
	                break;
	            case 15:
	                reason = "Your Free Demo has expired.";
	                break;
	            case 16:
                    reason = socket.readMultiByte(size, 'Windows-1252');
	                break;
	            case 2:
	            	reason = "There has been a communications error.";
	            	break;
	            default:
	                break;
			}
			if (!puidChanged) {
				// Don't show the disconnection error if the server dropped us
				// just to change our puid and ask us to reconnect.
				Alert.show(reason, "Connection Dropped");
			}
			trace("Connection Dropped: " + reason + " - Code: " + referenceId);
		}
		
		private function _throwAwayData(a:int, b:int):void {
			for (var i:int = 0; i < a && socket.bytesAvailable > 0; i++) {
				socket.readByte();
			}
			trace("Throwing away data.");
		}

	}
}