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
	import flash.system.Capabilities;
	
	[Bindable]
	public class PalaceServerInfo
	{
		public var name:String;
		public var _permissions:int = 0;
		public var _options:uint = 0;
		public var _uploadCapabilities:uint = 0;
		public var _downloadCapabilities:uint = 0;

		// Permissions
		public static const ALLOW_GUESTS:int         = 0x0001; //guests may use this server
		public static const ALLOW_CYBORGS:int        = 0x0002; //clients can use cyborg.ipt scripts
		public static const ALLOW_PAINTING:int       = 0x0004; //clients may issue draw commands
		public static const ALLOW_CUSTOM_PROPS:int   = 0x0008; //clients may select custom props
		public static const ALLOW_WIZARDS:int        = 0x0010; //wizards can use this server
		public static const WIZARDS_MAY_KILL:int     = 0x0020; //wizards can kick off users
		public static const WIZARDS_MAY_AUTHOR:int   = 0x0040; //wizards can create rooms
		public static const PLAYERS_MAY_KILL:int     = 0x0080; //normal users can kick each other off
		public static const CYBORGS_MAY_KILL:int     = 0x0100; //scripts can kick off users
		public static const DEATH_PENALTY:int        = 0x0200;
		public static const PURGE_INACTIVE_PROPS:int = 0x0400; //server discards unused props
		public static const KILL_FLOODERS:int        = 0x0800; //users dropped if they do too much too fast
		public static const NO_SPOOFING:int          = 0x1000; //command to speak as another is disabled
		public static const MEMBER_CREATED_ROOMS:int = 0x2000; //users can create rooms

		public var allowGuests:Boolean = false;
		public var allowCyborgs:Boolean = false;
		public var allowPainting:Boolean = false;
		public var allowCustomProps:Boolean = false;
		public var allowWizards:Boolean = false;
		public var wizardsMayKill:Boolean = false;
		public var wizardsMayAuthor:Boolean = false;
		public var playersMayKill:Boolean = false;
		public var cyborgsMayKill:Boolean = false;
		public var deathPenalty:Boolean = false;
		public var purgeInactiveProps:Boolean = false;
		public var killFlooders:Boolean = false;
		public var noSpoofing:Boolean = false;
		public var memberCreatedRooms:Boolean = false;
		
		
        //  Options
        public static const SAVE_SESSION_KEYS:uint  = 0x00000001; // server logs regcodes of users (obsolete)
        public static const PASSWORD_SECURITY:uint  = 0x00000002; // you need a password to use this server
        public static const CHAT_LOG:uint           = 0x00000004; // server logs all chat
        public static const NO_WHISPER:uint         = 0x00000008; // whisper command disabled
        public static const ALLOW_DEMO_MEMBERS:uint = 0x00000010; // Obsolete
        public static const AUTHENTICATE:uint       = 0x00000020; // unknown
        public static const POUND_PROTECT:uint      = 0x00000040; // server employs heuristics to evade hackers
        public static const SORT_OPTIONS:uint       = 0x00000080; // unknown
        public static const AUTH_TRACK_LOGOFF:uint  = 0x00000100; // server logs logoffs
        public static const JAVA_SECURE:uint        = 0x00000200; // server supports Java client's auth. scheme

		public var saveSessionKeys:Boolean = false;
		public var passwordSecurity:Boolean = false;
		public var chatLog:Boolean = false;
		public var noWhisper:Boolean = false;
		public var allowDemoMembers:Boolean = false;
		public var authenticate:Boolean = false;
		public var poundProtect:Boolean = false;
		public var sortOptions:Boolean = false;
		public var authTrackLogoff:Boolean = false;
		public var javaSecure:Boolean = false;
		
		
		// Upload Capabilities
		public static const ULCAPS_ASSETS_PALACE:uint = 0x00000001;
		public static const ULCAPS_ASSETS_FTP:uint    = 0x00000002;
		public static const ULCAPS_ASSETS_HTTP:uint   = 0x00000004;
		public static const ULCAPS_ASSETS_OTHER:uint  = 0x00000008;
		public static const ULCAPS_FILES_PALACE:uint  = 0x00000010;
		public static const ULCAPS_FILES_FTP:uint     = 0x00000020;
		public static const ULCAPS_FILES_HTTP:uint    = 0x00000040;
		public static const ULCAPS_FILES_OTHER:uint   = 0x00000080;
		public static const ULCAPS_EXTEND_PKT:uint    = 0x00000100;


		// Download Capabilities
		public static const DLCAPS_ASSETS_PALACE:uint    = 0x00000001;
		public static const DLCAPS_ASSETS_FTP:uint       = 0x00000002;
		public static const DLCAPS_ASSETS_HTTP:uint      = 0x00000004;
		public static const DLCAPS_ASSETS_OTHER:uint     = 0x00000008;
		public static const DLCAPS_FILES_PALACE:uint     = 0x00000010;
		public static const DLCAPS_FILES_FTP:uint        = 0x00000020;
		public static const DLCAPS_FILES_HTTP:uint       = 0x00000040;
		public static const DLCAPS_FILES_OTHER:uint      = 0x00000080;
		public static const DLCAPS_FILES_HTTPSERVER:uint = 0x00000100;
		public static const DLCAPS_EXTEND_PKT:uint       = 0x00000200;


		public function set permissions(input:int):void {
			_permissions = input;
			allowGuests        = Boolean(input & ALLOW_GUESTS);
			allowCyborgs       = Boolean(input & ALLOW_CYBORGS);
			allowPainting      = Boolean(input & ALLOW_PAINTING);
			allowCustomProps   = Boolean(input & ALLOW_CUSTOM_PROPS);
			allowWizards       = Boolean(input & ALLOW_WIZARDS);
			wizardsMayKill     = Boolean(input & WIZARDS_MAY_KILL);
			wizardsMayAuthor   = Boolean(input & WIZARDS_MAY_AUTHOR);
			playersMayKill     = Boolean(input & PLAYERS_MAY_KILL);
			cyborgsMayKill     = Boolean(input & CYBORGS_MAY_KILL);
			deathPenalty       = Boolean(input & DEATH_PENALTY);
			purgeInactiveProps = Boolean(input & PURGE_INACTIVE_PROPS);
			killFlooders       = Boolean(input & KILL_FLOODERS);
			noSpoofing         = Boolean(input & NO_SPOOFING);
			memberCreatedRooms = Boolean(input & MEMBER_CREATED_ROOMS);
		}
		
		public function get permissions():int {
			return _permissions;
		}
		
		public function set options(input:uint):void {
			_options = input;
			saveSessionKeys    = Boolean(input & SAVE_SESSION_KEYS);
			passwordSecurity   = Boolean(input & PASSWORD_SECURITY);
			chatLog            = Boolean(input & CHAT_LOG);
			noWhisper          = Boolean(input & NO_WHISPER);
			allowDemoMembers   = Boolean(input & ALLOW_DEMO_MEMBERS);
			authenticate       = Boolean(input & AUTHENTICATE);
			poundProtect       = Boolean(input & POUND_PROTECT);
			sortOptions        = Boolean(input & SORT_OPTIONS);
			authTrackLogoff    = Boolean(input & AUTH_TRACK_LOGOFF);
			javaSecure         = Boolean(input & JAVA_SECURE);
		}
		
		public function get options():uint {
			return _options;
		}
		
		public function set uploadCapabilities(input:uint):void {
			_uploadCapabilities = input;
		}
		
		public function get uploadCapabilities():uint {
			return _uploadCapabilities;
		}
		
		public function set downloadCapabilities(input:uint):void {
			_downloadCapabilities = input;
		}
		
		public function get downloadCapabilities():uint {
			return _downloadCapabilities;
		}
	}
}