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

package net.codecomposer.palace.message
{
	public final class OutgoingMessageTypes
	{
		// ----------------------------------------------------------------------
		// To Server
		// ----------------------------------------------------------------------
		public static const BYE:int = 0x62796520;
		public static const PING_BACK:int = 0x706f6e67;
		public static const SAY:int = 0x78746c6b;
		public static const WHISPER:int = 0x78776973;
		public static const MOVE:int = 1967943523;
		public static const REQUEST_ROOM_LIST:int = 0x724c7374;
		public static const GOTO_ROOM:int = 0x6e617652;
		public static const REQUEST_USER_LIST:int = 0x754c7374;
		public static const REQUEST_ASSET:int = 0x71417374;
		public static const USER_PROP:int = 1970500176;
		public static const CHANGE_NAME:int = 0x7573724e;
	}
}