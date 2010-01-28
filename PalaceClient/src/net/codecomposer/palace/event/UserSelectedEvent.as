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
	
	public class UserSelectedEvent extends Event
	{
		public var userID:int = -1;
		public function UserSelectedEvent(bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super("userSelected", bubbles, cancelable);
		}
	}
}