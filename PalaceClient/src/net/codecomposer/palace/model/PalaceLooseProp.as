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
	
	[Bindable]
	public class PalaceLooseProp
	{
		public var nextOffset:int;
		public var id:uint;
		public var crc:uint;
		public var flags:uint;
		public var x:int;
		public var y:int;
		public var prop:PalaceProp;
		
		private var propStore:PalacePropStore = PalacePropStore.getInstance();
		
		public static const dataSize:int = 24;
		
		public function loadData(endian:String, bs:Array, offset:int):void {
			var ba:ByteArray = new ByteArray();
			for (var j:int=offset; j < offset+dataSize+1; j++) {
				ba.writeByte(bs[j]);
			}
			ba.position = 0;
			ba.endian = endian;

			nextOffset = ba.readShort();
			ba.readShort();
			id = ba.readUnsignedInt();
			crc = ba.readUnsignedInt();
			flags = ba.readUnsignedInt();
			ba.readInt();
			y = ba.readShort();
			x = ba.readShort();
			
			loadProp();
		}
		
		public function loadProp():void {
			prop = propStore.getProp(id, crc);
		}

	}
}