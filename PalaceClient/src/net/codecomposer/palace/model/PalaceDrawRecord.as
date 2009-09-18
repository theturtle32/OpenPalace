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
	
	import net.codecomposer.palace.util.DrawColorUtil;
	
	[Bindable]
	public class PalaceDrawRecord
	{
		
		public static const CMD_PATH:int = 0;
		public static const CMD_SHAPE:int = 1;
		public static const CMD_TEXT:int = 2;
		public static const CMD_DETONATE:int = 3;
		public static const CMD_DELETE:int = 4;
		public static const CMD_ELLIPSE:int = 5;
		
		public var command:int;
		public var nextOffset:int;
		public var pensize:int;
		public var nbrpts:int;
		public var pencolor:uint;
		public var polygon:Array = []; // Array of points
		public var useFill:Boolean;
		
		public function readData(endian:String, roomBytes:Array, offset:int):void {
			var j:int;
			
			var ba:ByteArray = new ByteArray(); 
			
			for (j=offset; j < offset + 10; j++) {
				ba.writeByte(roomBytes[j]);
			}
			ba.position = 0;
			ba.endian = endian;
			
			
			nextOffset = ba.readShort();
//			trace("LLRec nextOfst: " + nextOffset);
			ba.readShort();
//			trace("LLRec reserved: " + ba.readShort());
			command = ba.readShort();
//			trace(" Draw Command: " + command);
			var commandLength:uint = ba.readUnsignedShort();
			var commandStart:uint = ba.readShort();
						
			if (commandStart == 0) { // hmm little hack for handling the draw packet, probably a better way.
				commandStart = 10;
			}
			
			if ((command & 4) == 4 || (command & 3) == 3) { //undo and delete... now go away!
				return;
			}
			
			
			ba = new ByteArray();
			var commandEndPosition:int = commandStart + commandLength;
			for (j=commandStart; j < commandEndPosition; j++) {
				ba.writeByte(roomBytes[j]);
			}
			ba.position = 0;
			ba.endian = endian;
			
			if ((command & 256) == 256) {
				useFill=true;
			}
			else{
				useFill=false;
			}
			
			pensize = ba.readShort();
//			trace(" Pensize: " + pensize);
			nbrpts = ba.readShort();
//			trace(" Number of y,x points: " + nbrpts);
			
			// they doubled the values, i don't know why.
			var redC:int = ba.readUnsignedByte();
			ba.readUnsignedByte();
			var greenC:int = ba.readUnsignedByte();
			ba.readUnsignedByte();
			var blueC:int = ba.readUnsignedByte();
			ba.readUnsignedByte();
			
			pencolor = DrawColorUtil.ARGBtoUint(0,redC,greenC,blueC);
		
			while (ba.bytesAvailable > 0) {
				var y:int = ba.readShort();
				var x:int = ba.readShort();
				polygon.push(new Point(x, y));
			}
		}
	}
}