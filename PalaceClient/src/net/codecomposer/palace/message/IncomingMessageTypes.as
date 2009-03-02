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
	public final class IncomingMessageTypes
	{
		// ----------------------------------------------------------------------
		// From Server
		// ----------------------------------------------------------------------
		
		// Server Types
		public static const UNKNOWN_SERVER:int = 1886610802;
		public static const LITTLE_ENDIAN_SERVER:int = 1920559476;
		public static const BIG_ENDIAN_SERVER:int = 1953069426;
		
		// Login
		public static const ALTERNATE_LOGON_REPLY:int = 1919250482;
		
		public static const SERVER_VERSION:int = 1986359923;
		public static const SERVER_INFO:int = 1936289382;
		public static const USER_STATUS:int = 1968403553;
		public static const USER_LOGGED_ON_AND_MAX:int = 1819240224;
		public static const GOT_HTTP_SERVER_LOCATION:int = 1213486160;
		
		// the following four are whenever you change rooms as well as login
		public static const GOT_ROOM_DESCRIPTION:int = 1919905645;
		public static const GOT_ROOM_DESCRIPTION_ALT:int = 1934782317;
		public static const GOT_USER_LIST:int = 1919971955;
		public static const GOT_ROOM_LIST:int = 1917612916;
		public static const ROOM_DESCEND:int = 1701733490; // ???
		public static const USER_NEW:int = 1852863091;
		
		public static const PINGED:int = 1885957735;
		
		public static const RECEIVE_CHAT:int = 2020895851;
		public static const RECEIVE_WHISPER:int = 2021091699;
		public static const ALT_RECEIVE_CHAT:int = 1952541803; // Whisper/chat?
		public static const ALT_RECEIVE_WHISPER:int = 2003331443; // Whisper/chat/
		public static const MOVEMENT:int = 1967943523;
		public static const USER_COLOR:int = 1970500163;
		public static const USER_FACE:int = 1970500166;
		public static const USER_DESCRIPTION:int = 1970500164;
		public static const USER_PROP:int = 1970500176;
		public static const USER_RENAME:int = 1970500174;
		public static const USER_LEAVING:int = 1652122912; // ?
		public static const CONNECTION_DIED:int = 1685026670;
		public static const INCOMING_FILE:int = 1933994348;
		public static const ASSET_INCOMING:int = 1933669236;
		public static const USER_EXIT_ROOM:int = 1701868147;
		public static const GOT_REPLY_OF_ALL_ROOMS:int = 1917612916;
		public static const GOT_REPLY_OF_ALL_USERS:int = 1967944564;
		
		// Loose Props
		public static const PROP_MOVE:int = 1833988720;
		public static const PROP_DELETE:int = 1682993776;
		public static const PROP_NEW:int = 1850765936;
		
		
	}
}