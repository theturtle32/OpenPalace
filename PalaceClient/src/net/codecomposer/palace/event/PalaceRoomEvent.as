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
	
	import net.codecomposer.palace.model.PalaceLooseProp;
	import net.codecomposer.palace.model.PalaceUser;

	public class PalaceRoomEvent extends Event
	{
		public var user:PalaceUser;
		public var propIndex:int;
		public var looseProp:PalaceLooseProp;
		public var addToFront:Boolean;
		
		public static const USER_ENTERED:String = "userEntered";
		public static const USER_LEFT:String = "userLeft";
		public static const ROOM_CLEARED:String = "roomCleared";
		public static const LOOSE_PROP_ADDED:String = "loosePropAdded";
		public static const LOOSE_PROP_REMOVED:String = "loosePropRemoved";
		public static const LOOSE_PROP_MOVED:String = "loosePropMoved";
		public static const LOOSE_PROPS_CLEARED:String = "loosePropsCleared";
		public static const USER_MOVED:String = "userMoved";
		
		public function PalaceRoomEvent(type:String, user:PalaceUser = null)
		{
			this.user = user;
			super(type, false, false);
		}
		
	}
}