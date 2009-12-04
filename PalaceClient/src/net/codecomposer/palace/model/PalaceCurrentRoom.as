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

package net.codecomposer.palace.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	import net.codecomposer.palace.event.ChatEvent;
	import net.codecomposer.palace.event.PalaceRoomEvent;
	import net.codecomposer.palace.util.PalaceUtil;
	import net.codecomposer.palace.view.PalaceRoomView;

	[Event(name="chatLogUpdated")]
	[Event(name="chat",type="net.codecomposer.palace.event.ChatEvent")]
	[Event(name="userEntered",type="net.codecomposer.palace.event.PalaceRoomEvent")]
	[Event(name="userLeft",type="net.codecomposer.palace.event.PalaceRoomEvent")]
	[Event(name="roomCleared",type="net.codecomposer.palace.event.PalaceRoomEvent")]
	
	[Bindable]
	public class PalaceCurrentRoom extends EventDispatcher
	{
		public var id:int;
		public var name:String = "Not Connected";
		public var backgroundFile:String;
		public var users:ArrayCollection = new ArrayCollection();
		public var usersHash:Object = {};
		public var roomFlags:int;
		public var images:Object = {};
		public var hotspotBitmapCache:Object = {};
		public var hotSpots:ArrayCollection = new ArrayCollection();
		public var hotSpotsById:Object = {};
		public var looseProps:ArrayCollection = new ArrayCollection();
		public var drawFrontCommands:ArrayCollection = new ArrayCollection();
		public var drawBackCommands:ArrayCollection = new ArrayCollection();
		public var drawLayerHistory:Vector.<uint> = new Vector.<uint>();
		public var selectedUser:PalaceUser;
		public var selfUserId:int = -1;
		public var roomView:PalaceRoomView;
		public var dimLevel:Number = 1;
		
		public var chatLog:String = "";
		
		public var lastMessage:String;
		public var lastMessageCount:int = 0;
		public var lastMessageReceived:Number = 0;
		public var lastMessageTimer:Timer = new Timer(250, 1);
		
		
		public function PalaceCurrentRoom()
		{
			lastMessageTimer.addEventListener(TimerEvent.TIMER, handleLastMessageTimer);
		}
		
		private function handleLastMessageTimer(event:TimerEvent):void {
			logMessage("(Last message received " + lastMessageCount.toString() + ((lastMessageCount == 1) ? " time.)" : " times.)"));
			lastMessage = "";
			lastMessageCount = 0;
			lastMessageReceived = 0;
		}
		
		private function shouldDisplayMessage(message:String):Boolean {
			var retValue:Boolean = true;
			trace("last message: " + lastMessage + " message: " + message + " lastMessageReceived: " + lastMessageReceived + " Now: " + (new Date()).valueOf());
			if (lastMessage == message && lastMessageReceived > (new Date()).valueOf() - 250) {
				lastMessageTimer.stop();
				lastMessageTimer.reset();
				lastMessageTimer.start();
				lastMessageCount ++;
				retValue = false;
			}
			else {
				lastMessageCount = 1;
			}
			lastMessage = message;
			lastMessageReceived = (new Date()).valueOf();
			return retValue;
		}
		
		public function getHotspotById(spotId:int):PalaceHotspot {
			return PalaceHotspot(hotSpotsById[spotId]);
		}
		
		public function dimRoom(level:int):void {
			level = Math.max(0, level);
			level = Math.min(100, level);
			dimLevel = level / 100;
		}
		
		public function addLooseProp(id:int, crc:uint, x:int, y:int, addToFront:Boolean = false):void {
			var prop:PalaceLooseProp = new PalaceLooseProp();
			prop.x = x;
			prop.y = y;
			prop.id = id;
			prop.crc = crc;
			prop.loadProp();
			if (addToFront) {
				looseProps.addItem(prop);
			}
			else {
				looseProps.addItemAt(prop, 0);
			}
			var event:PalaceRoomEvent = new PalaceRoomEvent(PalaceRoomEvent.LOOSE_PROP_ADDED);
			event.looseProp = prop;
			event.addToFront = addToFront;
			dispatchEvent(event);
		}
		
		public function removeLooseProp(index:int):void {
			if (index == -1) {
				clearLooseProps();
			}
			else {
				looseProps.removeItemAt(index);
				var event:PalaceRoomEvent = new PalaceRoomEvent(PalaceRoomEvent.LOOSE_PROP_REMOVED);
				event.propIndex = index;
				dispatchEvent(event);
			}
		}
		
		public function moveLooseProp(index:int, x:int, y:int):void {
			trace("Moving prop index " + index);
			var prop:PalaceLooseProp = PalaceLooseProp(looseProps.getItemAt(index));
			prop.x = x;
			prop.y = y;
			var event:PalaceRoomEvent = new PalaceRoomEvent(PalaceRoomEvent.LOOSE_PROP_MOVED);
			event.looseProp = prop;
			dispatchEvent(event);
		}
		
		public function clearLooseProps():void {
			looseProps.removeAll();
			var event:PalaceRoomEvent = new PalaceRoomEvent(PalaceRoomEvent.LOOSE_PROPS_CLEARED);
			dispatchEvent(event);
		}
		
		public function getLoosePropByIndex(index:int):PalaceLooseProp {
			return PalaceLooseProp(looseProps.getItemAt(index));
		}

		public function addUser(user:PalaceUser):void {
			usersHash[user.id] = user;
			users.addItem(user);
			var event:PalaceRoomEvent = new PalaceRoomEvent(PalaceRoomEvent.USER_ENTERED, user);
			dispatchEvent(event);
		}
		
		public function getUserById(id:int):PalaceUser {
			return PalaceUser(usersHash[id]);
		}
		
		public function getUserByName(name:String):PalaceUser {
			for each (var user:PalaceUser in users) {
				if (user.name == name) {
					return user;
				}
			}
			return null;
		}
		
		public function getUserByIndex(userIndex:int):PalaceUser {
			return PalaceUser(users.getItemAt(userIndex));
		}
		
		public function getSelfUser():PalaceUser {
			return getUserById(selfUserId);
		}
		
		public function removeUser(user:PalaceUser):void {
			removeUserById(user.id);
		}
		
		public function removeUserById(id:int):void {
			var user:PalaceUser = getUserById(id);
			var index:int = users.getItemIndex(user);
			if (index != -1) {
				users.removeItemAt(users.getItemIndex(user));
			}
			var event:PalaceRoomEvent = new PalaceRoomEvent(PalaceRoomEvent.USER_LEFT, user);
			dispatchEvent(event);
		}
		
		public function removeAllUsers():void {
			usersHash = {};
			users.removeAll();
			var event:PalaceRoomEvent = new PalaceRoomEvent(PalaceRoomEvent.ROOM_CLEARED);
			dispatchEvent(event);
		}
		
		public function chat(userId:int, message:String, logMessage:String = null):void {
			var user:PalaceUser = getUserById(userId);
			
			if (logMessage == null) {
				logMessage = message;
			}
			if (logMessage.length > 0) {
				recordChat("<b>", PalaceUtil.htmlEscape(user.name), ":</b> ", PalaceUtil.htmlEscape(logMessage), "\n");
				dispatchEvent(new Event('chatLogUpdated'));
			}
			if (shouldDisplayMessage(message) && message.length > 0) {
				var event:ChatEvent = new ChatEvent(ChatEvent.CHAT, message, user);
				dispatchEvent(event);
			}
		}
		
		public function whisper(userId:int, message:String, logMessage:String = null):void {
			var user:PalaceUser = getUserById(userId);
			if (logMessage == null) {
				logMessage = message;
			}
			if (logMessage.length > 0) {
				recordChat("<em><b>", PalaceUtil.htmlEscape(user.name), " (whisper):</b> ", PalaceUtil.htmlEscape(logMessage), "</em>\n");
				dispatchEvent(new Event('chatLogUpdated'));
			}
			if (shouldDisplayMessage(message) && message.length > 0) {
				var event:ChatEvent = new ChatEvent(ChatEvent.WHISPER, message, user);
				dispatchEvent(event);
			}
		}
		
		public function localMessage(message:String):void {
			roomMessage(message);
		}
		
		public function roomMessage(message:String):void {
			recordChat("<b>*** " + PalaceUtil.htmlEscape(message), "</b>\n");
			dispatchEvent(new Event('chatLogUpdated'));
			if (shouldDisplayMessage(message) && message.length > 0) {
				var event:ChatEvent = new ChatEvent(ChatEvent.ROOM_MESSAGE, message);
				dispatchEvent(event);
			}
		}
		
		public function statusMessage(message:String):void {
			recordChat("<i>" + message + "</i>\n");
			dispatchEvent(new Event('chatLogUpdated'));
		}
		
		public function logMessage(message:String):void {
			recordChat("<i>" + message + "</i>\n");
			dispatchEvent(new Event('chatLogUpdated'));
		}
		
		public function logScript(message:String):void {
			recordChat("<font face=\"Courier New\">" + PalaceUtil.htmlEscape(message) + "</font>\n")
			dispatchEvent(new Event('chatLogUpdated'));
		}
		
		public function roomWhisper(message:String):void {
			recordChat("<b><i>*** " + PalaceUtil.htmlEscape(message), "</i></b>\n");
			dispatchEvent(new Event('chatLogUpdated'));
			if (shouldDisplayMessage(message) && message.length > 0) {
				var event:ChatEvent = new ChatEvent(ChatEvent.ROOM_MESSAGE, message);
				dispatchEvent(event);
			}
		}
		
		private function recordChat(... args):void {
			var temp:String = "";
			if (chatLog.length > 2) {
				temp = chatLog.substr(0, chatLog.length-1);
			}
			for (var i:int = 0; i < args.length; i ++) {
				temp += args[i];
			}
			chatLog = temp + "\n";
		}
	}
}