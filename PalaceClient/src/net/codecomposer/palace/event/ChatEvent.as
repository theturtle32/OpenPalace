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
		public var user:PalaceUser;
		public var whisper:Boolean;
		public var logOnly:Boolean = false;
		
		public static const CHAT:String = "chat";
		public static const WHISPER:String = "whisper";
		public static const ROOM_MESSAGE:String = "roomMessage";
		
		public function ChatEvent(type:String, chatText:String, user:PalaceUser = null)
		{
			if (chatText.charAt(0) == ';') {
				logOnly = true;
			}
			this.chatText = chatText;
			this.user = user;
			this.whisper = Boolean(type == WHISPER);
			super(type, false, true);
		}
		
	}
}