package net.codecomposer.palace.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import net.codecomposer.palace.event.ChatEvent;
	import net.codecomposer.palace.event.PalaceRoomEvent;
	
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
		public var hotspots:ArrayCollection = new ArrayCollection();
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
			chatLog = chatLog.concat("<b>", user.name, ":</b> ", message, "\n");
			dispatchEvent(new Event('chatLogUpdated'));
			var event:ChatEvent = new ChatEvent(user, message);
			dispatchEvent(event);
		}
		
		public function whisper(userId:int, message:String):void {
			var user:PalaceUser = getUserById(userId);
			chatLog = chatLog.concat("<i><b>", user.name, " (whisper):</b> ", message, "</i>\n");
			dispatchEvent(new Event('chatLogUpdated'));
		}
		
		public function roomMessage(message:String):void {
			chatLog = chatLog.concat("<b>*** " + message, "</b>\n");
			dispatchEvent(new Event('chatLogUpdated'));
		}
		
		public function roomWhisper(message:String):void {
			chatLog = chatLog.concat("<b><i>*** " + message, "</i></b>\n");
			dispatchEvent(new Event('chatLogUpdated'));
		}
	}
}