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
	import flash.utils.ByteArray;
	
	import net.codecomposer.palace.view.HotSpotImage;

	[Bindable]
	public class PalaceHotspotState
	{
		
		public var pictureId:int;
		public var x:int;
		public var y:int;
		public var hotspotImage:HotSpotImage;
		
		public static const size:int = 8;
		
		public static const UNLOCKED:int = 0;
		public static const LOCKED:int = 1;
		
		public function PalaceHotspotState()
		{
		}

		public function readData(endian:String, roomBytes:Array, offset:int):void {
			var ba:ByteArray = new ByteArray();
			for (var j:int=offset; j < offset+size+1; j++) {
				ba.writeByte(roomBytes[j]);
			}
			ba.position = 0;
			ba.endian = endian;
			
			pictureId = ba.readShort();
			ba.readShort(); // Filler for alignment
			y = ba.readShort();
			x = ba.readShort();
		}

	}
}