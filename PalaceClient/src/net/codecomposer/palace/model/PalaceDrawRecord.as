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
		
		public function readData(endian:String, roomBytes:Array, offset:int):void {
			var j:int;
			
			var ba:ByteArray = new ByteArray(); 
			for (j=offset; j < offset + 10; j++) {
				ba.writeByte(roomBytes[j]);
			}
			ba.position = 0;
			ba.endian = endian;
			
			trace("Draw Command: ");
			var next:int = ba.readShort();
			trace("LLRec nextOfst: " + next);
			trace("LLRec reserved: " + ba.readShort());
			command = ba.readShort();
			trace("Command: " + command);
			var commandLength:uint = ba.readUnsignedShort();
			trace("CommandLength: " + commandLength);
			trace("DataOffset: " + ba.readShort());
						
			nextOffset = offset + 10 + commandLength;
			trace("ComputedNextOffset: " + nextOffset);
			
			nextOffset = next;
			
			ba = new ByteArray();
			var commandEndPosition:int = offset + 10 + commandLength;
			for (j=offset + 10; j < commandEndPosition; j++) {
				ba.writeByte(roomBytes[j]);
				
			}
			ba.position = 0;
			ba.endian = endian;
			
			var cmdbytes:Array = [];
			while (ba.bytesAvailable > 0) {
				cmdbytes.push(ba.readUnsignedByte());
			}
			
			
			
			trace(" Draw command: " + command);
			outputHexView(cmdbytes);
		}
		
		private function outputHexView(bytes:Array):void {
			var output:String = "";
			var outputLineHex:String = "";
			var outputLineAscii:String = "";
			for (var byteNum:int = 0; byteNum < bytes.length; byteNum++) {
				var hexNum:String = uint(bytes[byteNum]).toString(16).toUpperCase();
				if (hexNum.length == 1) {
					hexNum = "0" + hexNum;
				}

				if (byteNum % 16 == 0) {
					output = output.concat(outputLineHex, "      ", outputLineAscii, "\n");
					outputLineHex = "";
					outputLineAscii = "";
				}
				else if (byteNum % 4 == 0) {
					outputLineHex = outputLineHex.concat("  ");
					outputLineAscii = outputLineAscii.concat(" ");
				}
				else {
					outputLineHex = outputLineHex.concat(" ");
				}
				outputLineHex = outputLineHex.concat(hexNum);
				outputLineAscii = outputLineAscii.concat(
					(bytes[byteNum] >= 32 && bytes[byteNum] <= 126) ? String.fromCharCode(bytes[byteNum]) : " "
				);
			}
			output = output.concat(outputLineHex, "      ", outputLineAscii, "\n");
			trace(output);
		}
	}
}