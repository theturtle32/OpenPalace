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
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public class PalaceHotspot
	{
		
		public var type:uint = 0;
		public var dest:uint = 0;
		public var id:uint = 0;
		public var flags:uint = 0;
		public var state:uint = 0;
		public var numStates:uint = 0;
		public var polygon:Array = []; // Array of points
		public var name:String = null;
		public var originY:uint = 0;
		public var originX:uint = 0;
		public var scriptEventMask:uint = 0;
		public var numScripts:uint = 0;
		
		public function PalaceHotspot()
		{
		}

		public function readData(endian:String, bs:Array, offset:int):void {
			// FIXME:  This seems broken.  The name is not read reliably
			// and the coordinates for the polygon are not at all correct
			// most of the time, but are correct sometimes.  No idea.
			
			var ba:ByteArray = new ByteArray();
			for (var j:int=offset-1; j < offset+size; j++) {
				ba.writeByte(bs[j]);
			}
			ba.position = 0;
			//ba.endian = endian;
			
			scriptEventMask = ba.readUnsignedInt();
			flags = ba.readUnsignedInt();
			ba.readInt();
			ba.readInt();
			originY = ba.readUnsignedShort();
			originX = ba.readUnsignedShort();
			id = ba.readUnsignedShort();
			dest = ba.readUnsignedShort();
			var ptCnt:uint = ba.readUnsignedShort();
			var ptsOffset:uint = ba.readUnsignedShort();
			type = ba.readUnsignedShort();
			ba.readShort();
			numScripts = ba.readUnsignedShort();
			ba.readShort();
			state = ba.readUnsignedShort();
			numStates = ba.readUnsignedShort();
			var stateRecOffset:int = ba.readUnsignedShort();
			var nameOffset:int = ba.readUnsignedShort();
			var scriptTextOffset:int = ba.readUnsignedShort();
			ba.readShort();
			if (nameOffset > 0) {
				var nameByteArray:ByteArray = new ByteArray();
				var nameLength:int = bs[nameOffset];
				for (var a:int = nameOffset+1; a < nameOffset+nameLength+1; a++) {
					nameByteArray.writeByte(bs[a]);
				}
				nameByteArray.position = 0;
				name = nameByteArray.readMultiByte(nameLength, 'iso-8859-1');
			}

			ba = new ByteArray();
			var endPos:int = ptsOffset+(ptCnt*4);
			for (j=ptsOffset-1; j < endPos; j++) {
				ba.writeByte(bs[j]);
			}
			ba.position = 0;
			
			//ba.endian = endian;
			var startX:int = 0;
			var startY:int = 0;
			for (var i:int = 0; i < ptCnt; i++) {
				var y:int = ba.readShort();
				var x:int = ba.readShort();
				trace("--------------------------------- X: " + x + " (" + x.toString(16) + ")    Y: " + y + "(" + y.toString(16) +")");
				if (i == 0) {
					startX = x;
					startY = y;
				}
				polygon.push(new Point(x + originX, y + originY));
			}
			
			polygon.push(new Point(startX + originX, startY + originY));
			
			trace("Got new hotspot: " + this.id + " - DestID: " + dest + " - name: " + this.name + " - PointCount: " + ptCnt);
		}
		
		public function get size():int {
			return 48;
		}

	}
}