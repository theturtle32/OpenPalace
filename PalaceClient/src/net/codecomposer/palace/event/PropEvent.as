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
	import net.codecomposer.palace.model.PalaceProp;

	public class PropEvent extends Event
	{
		public var prop:PalaceProp;
		
		public static const PROP_LOADED:String = "propLoaded";
		public static const PROP_DECODED:String = "propDecoded";
		public static const LOOSE_PROP_LOADED:String = "loosePropLoaded";
		
		public function PropEvent(type:String, prop:PalaceProp=null)
		{
			if (prop) {
				this.prop = prop;
			}
			super(type, false, false);
		}
		
	}
}