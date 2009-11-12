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

package net.codecomposer.palace.event
{
	import flash.events.Event;
	
	import net.codecomposer.palace.model.PalaceUser;

	public class ChatEvent extends Event
	{
		public var chatText:String;
		public var logText:String;
		public var user:PalaceUser;
		public var soundName:String;
		public var whisper:Boolean;
		public var logOnly:Boolean = false;
		
		public static const CHAT:String = "chat";
		public static const WHISPER:String = "whisper";
		public static const ROOM_MESSAGE:String = "roomMessage";
		
		public function ChatEvent(type:String, chatText:String, user:PalaceUser = null)
		{
			logText = chatText;
			
			var match:Array;
			if (chatText.charAt(0) == ';') {
				logOnly = true;
			}
			
			match = chatText.match(/^\s*(@\d+,\d+){0,1}\s*\)([^\s]+)\s*(.*)$/);
			if (match && match.length > 1) {
				soundName = match[2];
				chatText = "";
				if (match[1]) {
					chatText += match[1];
				}
				if (match[3]) {
					chatText += match[3];
				}
			}
			
			this.chatText = chatText;
			this.user = user;
			this.whisper = Boolean(type == WHISPER);
			super(type, false, true);
		}
		
	}
}