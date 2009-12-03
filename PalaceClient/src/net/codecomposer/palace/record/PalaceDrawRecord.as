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

package net.codecomposer.palace.record
{
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import net.codecomposer.palace.util.DrawColorUtil;

	[Bindable]
	public class PalaceDrawRecord extends EventDispatcher
	{
		
		public static const CMD_PATH:uint = 0;
		public static const CMD_SHAPE:uint = 1;
		public static const CMD_TEXT:uint = 2;
		public static const CMD_DETONATE:uint = 3;
		public static const CMD_DELETE:uint = 4;
		public static const CMD_ELLIPSE:uint = 5;
		
		public static const LAYER_BACK:uint  = 0x00;
		public static const LAYER_FRONT:uint = 0x80;
		
		public static const USE_FILL:uint = 0x01;
		public static const IS_ELLIPSE:uint = 0x40;
		
		
		public var command:uint;
		public var flags:uint = 0;
		public var nextOffset:int;
		public var penSize:int;
		public var numPoints:int;
		public var penColor:uint;
		public var penAlpha:Number;
		public var lineColor:uint;
		public var lineAlpha:Number;
		public var fillColor:uint;
		public var fillAlpha:Number;
		
		public var polygon:Vector.<Point> = new Vector.<Point>();
		
		[Bindable(event="fillChanged")]
		public function set useFill(newValue:Boolean):void {
			var startFlags:uint = flags;
			if (newValue) {
				flags |= USE_FILL;
			}
			else {
				flags &= ~USE_FILL;
			}
			if (startFlags != flags) {
				dispatchEvent(new Event('fillChanged'));
			}
		}
		public function get useFill():Boolean {
			return Boolean(flags & USE_FILL);
		}

		[Bindable(event="ellipseChanged")]
		public function set isEllipse(newValue:Boolean):void {
			var startFlags:uint = flags;
			if (newValue) {
				flags |= IS_ELLIPSE;
			}
			else {
				flags &= ~IS_ELLIPSE;
			}
			if (startFlags != flags) {
				dispatchEvent(new Event('ellipseChanged'));
			}
		}
		public function get isEllipse():Boolean { 
			return Boolean(flags & IS_ELLIPSE);
		}
		
		[Bindable(event="layerChanged")]
		public function set layer(newValue:uint):void {
			var startFlags:uint = flags;
			if (newValue == LAYER_FRONT) {
				flags |= LAYER_FRONT;
			}
			else if (newValue == LAYER_BACK) {
				flags &= ~LAYER_FRONT;
			}
			if (startFlags != flags) {
				dispatchEvent(new Event('layerChanged'));
			}
		}
		public function get layer():uint {
			return flags & LAYER_FRONT;
		}
		
		public function generatePacket(endian:String = Endian.LITTLE_ENDIAN):ByteArray {
			var ba:ByteArray = new ByteArray();
			ba.endian = endian;
			
			ba.writeShort(0); // unused -- nextOffset
			ba.writeShort(0); // unused
			
			var data:ByteArray = new ByteArray();
			data.endian = endian;
			
			if (command != CMD_DETONATE && command != CMD_DELETE) {
				data.writeShort(penSize);
				data.writeShort(polygon.length);
				data.writeByte(((lineColor & 0x00FF0000) >> 16) & 0xFF); // red
				data.writeByte(((lineColor & 0x00FF0000) >> 16) & 0xFF); // red
				data.writeByte(((lineColor & 0x0000FF00) >> 8) & 0xFF);  // green
				data.writeByte(((lineColor & 0x0000FF00) >> 8) & 0xFF);  // green
				data.writeByte(  lineColor & 0x000000FF);                // blue
				data.writeByte(  lineColor & 0x000000FF);                // blue
				for each (var point:Point in polygon) {
					data.writeShort(point.y);
					data.writeShort(point.x);
				}
				
				// lineColor with alpha
				data.writeByte(Math.ceil(lineAlpha * 0xFF))
				data.writeByte(((lineColor & 0x00FF0000) >> 16) & 0xFF); // red
				data.writeByte(((lineColor & 0x0000FF00) >> 8) & 0xFF);  // green
				data.writeByte(  lineColor & 0x000000FF);                // blue
				
				// fillColor with alpha 
				data.writeByte(Math.ceil(fillAlpha * 0xFF))
				data.writeByte(((fillColor & 0x00FF0000) >> 16) & 0xFF); // red
				data.writeByte(((fillColor & 0x0000FF00) >> 8) & 0xFF);  // green
				data.writeByte(  fillColor & 0x000000FF);                // blue
			}
			
			data.position = 0
			
			// Command and flags are combined into one field.
			ba.writeShort(command | (flags << 8));
			ba.writeShort(data.length); // commandLength
			ba.writeShort(0); // start position
			ba.writeBytes(data);
			return ba;
		}
				
		public function readData(endian:String, roomBytes:Array, offset:int):void {
			var j:int;
			var commandLength:uint;
			var commandStart:uint;
			var commandEndPosition:uint;
			var red:uint;
			var green:uint;
			var blue:uint;
			var alphaInt:uint;
			var alpha:Number;
			
			var ba:ByteArray = new ByteArray(); 
			
			for (j=offset; j < offset + 10; j++) {
				ba.writeByte(roomBytes[j]);
			}
			ba.position = 0;
			ba.endian = endian;
			
			
			nextOffset = ba.readShort();
			ba.readShort(); // reserved, unused
			command = ba.readUnsignedShort();
			commandLength = ba.readUnsignedShort();
			commandStart = ba.readShort();
			
			flags = command >> 8;
			command = command & 0xFF;

			// If this is a standalone draw record inside an independent
			// draw command, commandStart will always be 0, but the header
			// is 10 bytes, so the first command starts at the 11th.
			if (commandStart == 0) {
				commandStart = 10;
			}

			commandEndPosition = commandStart + commandLength;
			
			if (command == CMD_DETONATE || command == CMD_DELETE) {
				return;
			}
			
			ba = new ByteArray();
			for (j=commandStart; j < commandEndPosition; j++) {
				ba.writeByte(roomBytes[j]);
			}
			ba.position = 0;
			ba.endian = endian;
			
			penSize = ba.readShort();
			numPoints = ba.readShort();
			
			// they doubled the values, i don't know why.
			red = ba.readUnsignedByte();
			ba.readUnsignedByte();
			green = ba.readUnsignedByte();
			ba.readUnsignedByte();
			blue = ba.readUnsignedByte();
			ba.readUnsignedByte();
			alphaInt = 0xFF;
			alpha = Number(alphaInt)/0xFF;
			
			penColor = DrawColorUtil.ARGBtoUint(alphaInt, red, green, blue);
			penAlpha = alpha;
			fillColor = penColor;
			fillAlpha = penAlpha;
			lineColor = penColor;
			lineAlpha = penAlpha;
			
		
			for (j=0; j <= numPoints; j++) {
				var y:int = ba.readShort();
				var x:int = ba.readShort();
				polygon.push(new Point(x, y));
			}
			
			if (ba.bytesAvailable) {
				try {
					alphaInt = ba.readUnsignedByte();
					red = ba.readUnsignedByte();
					green = ba.readUnsignedByte();
					blue = ba.readUnsignedByte();
					alpha = Number(alphaInt)/0xFF;
					lineColor = DrawColorUtil.ARGBtoUint(alphaInt, red, green, blue);
					lineAlpha = alpha;
					
					alphaInt = ba.readUnsignedByte();
					red = ba.readUnsignedByte();
					green = ba.readUnsignedByte();
					blue = ba.readUnsignedByte();
					alpha = Number(alphaInt)/0xFF;
					fillColor = DrawColorUtil.ARGBtoUint(alphaInt, red, green, blue);
					fillAlpha = alpha;
				}
				catch (e:Error) {
					// If there was an error reading these colors, we will
					// just fall back to the old behavior of using the
					// penColor for everything, and a penSize of 0.
					fillColor = lineColor = penColor;
					fillAlpha = lineAlpha = penAlpha;
					penSize = 0;
				}
			}
			else {
				fillColor = lineColor = penColor;
				fillAlpha = lineAlpha = penAlpha;
				if (isEllipse || useFill) {
					// No more bytes available, must be PalaceChat 3 style
					// packets.
					penSize = 0;
				}
			}
		}
	}
}