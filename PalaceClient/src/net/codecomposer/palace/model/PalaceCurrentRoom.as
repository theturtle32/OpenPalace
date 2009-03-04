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
	
	import mx.collections.ArrayCollection;
	
	import net.codecomposer.palace.event.ChatEvent;
	import net.codecomposer.palace.event.PalaceRoomEvent;
	import net.codecomposer.palace.util.PalaceUtil;
	
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
		public var hotSpots:ArrayCollection = new ArrayCollection();
		public var looseProps:ArrayCollection = new ArrayCollection();
		public var drawCommands:ArrayCollection = new ArrayCollection();
		public var selectedUser:PalaceUser;
		public var selfUserId:int = -1;
		
		public var chatLog:String = "";
		
		
		public function PalaceCurrentRoom()
		{
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
		
		public function chat(userId:int, message:String):void {
			var user:PalaceUser = getUserById(userId);
			recordChat("<b>", PalaceUtil.htmlEscape(user.name), ":</b> ", PalaceUtil.htmlEscape(message), "\n");
			dispatchEvent(new Event('chatLogUpdated'));
			var event:ChatEvent = new ChatEvent(user, message);
			dispatchEvent(event);
		}
		
		public function whisper(userId:int, message:String):void {
			var user:PalaceUser = getUserById(userId);
			recordChat("<i><b>", PalaceUtil.htmlEscape(user.name), " (whisper):</b> ", PalaceUtil.htmlEscape(message), "</i>\n");
			dispatchEvent(new Event('chatLogUpdated'));
		}
		
		public function roomMessage(message:String):void {
			recordChat("<b>*** " + PalaceUtil.htmlEscape(message), "</b>\n");
			dispatchEvent(new Event('chatLogUpdated'));
		}
		
		public function roomWhisper(message:String):void {
			recordChat("<b><i>*** " + PalaceUtil.htmlEscape(message), "</i></b>\n");
			dispatchEvent(new Event('chatLogUpdated'));
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