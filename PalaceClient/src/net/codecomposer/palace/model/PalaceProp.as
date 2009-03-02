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
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mx.core.FlexBitmap;
	
	import net.codecomposer.palace.event.PropEvent;
	
	[Event(name="propLoaded",type="net.codecomposer.palace.event.PropEvent")]
	
	[Bindable]
	public class PalaceProp extends EventDispatcher
	{
		
		public var asset:PalaceAsset = null;
		public var width:int;
		public var height:int;
		public var horizontalOffset:int;
		public var verticalOffset:int;
		public var scriptOffset:int;
		public var flags:uint;
		public var bounds:Rectangle;
		private var _bitmap:BitmapData;		
		public var ready:Boolean = false;
		public var badProp:Boolean = false;
		
		public var head:Boolean = false;
		public var ghost:Boolean = false;
		public var rare:Boolean = false;
		public var animate:Boolean = false;
		public var palindrome:Boolean = false;
		public var bounce:Boolean = false;
		public var propFormat:uint = 0x00;
		
		public static const HEAD_FLAG:uint = 0x02;
		public static const GHOST_FLAG:uint = 0x04;
		public static const RARE_FLAG:uint = 0x08;
		public static const ANIMATE_FLAG:uint = 0x10;
		public static const PALINDROME_FLAG:uint = 0x20; //Bounce?
		public static const BOUNCE_FLAG:uint = 0x20;

		public static const PROP_FORMAT_S20BIT:uint = 0x200;
		public static const PROP_FORMAT_20BIT:uint  = 0x40;
		public static const PROP_FORMAT_32BIT:uint  = 0x100;
		public static const PROP_FORMAT_8BIT:uint   = 0x00;

		private static const rect:Rectangle = new Rectangle(0,0,44,44);
		
		private static const mask:uint = 0xFFC1; // Original palace prop flags.
		
		private static var formatMask:uint = PROP_FORMAT_20BIT |
							 				 PROP_FORMAT_S20BIT |
							  	 			 PROP_FORMAT_32BIT;
		
		private static var itemsToRender:int = 0;
		
		public function PalaceProp(assetId:uint, assetCrc:uint)
		{
			asset = new PalaceAsset();
			asset.id = assetId;
			asset.crc = assetCrc;
			//BindingUtils.bindProperty(this, "source", this, "bitmap")
		}
		
		public function set bitmap(newBitmap:Object):void {
			_bitmap = BitmapData(newBitmap);
		}
		
		public function get bitmap():Object {
			if (_bitmap) {
				return new FlexBitmap(_bitmap);
			}
			else {
				return null;
			}
		}
		
		public function decodeProp():void {			
			// Try not to block the UI while props are rendering.
			setTimeout(renderBitmap, 200+40*(++itemsToRender));
		}
		
		private function renderBitmap():void {
			--itemsToRender;

            if (asset.data[1] == 0) {
                width = asset.data[0] | asset.data[1] << 8;
                height = asset.data[2] | asset.data[3] << 8;
                horizontalOffset = asset.data[4] | asset.data[5] << 8;
                verticalOffset = asset.data[6] | asset.data[7] << 8;
                scriptOffset = asset.data[8] | asset.data[9] << 8;
                flags = asset.data[10] | asset.data[11] << 8;
            }
            else {
                width = asset.data[1] | asset.data[0] << 8;
                height = asset.data[3] | asset.data[2] << 8;
                horizontalOffset = asset.data[5] | asset.data[4] << 8;
                verticalOffset = asset.data[7] | asset.data[6] << 8;
                scriptOffset = asset.data[9] | asset.data[8] << 8;
                flags = asset.data[11] | asset.data[10] << 8;
            }
            
            propFormat = flags & formatMask;
            
            trace("Non-Standard flags: " + uint(flags & mask).toString(16));
            
           	head = Boolean(flags & HEAD_FLAG);
           	ghost = Boolean(flags & GHOST_FLAG);
           	rare = Boolean(flags & RARE_FLAG);
           	animate = Boolean(flags & ANIMATE_FLAG);
           	palindrome = Boolean(flags & PALINDROME_FLAG);
           	bounce = Boolean(flags & BOUNCE_FLAG);

            if ((flags & mask) == 0xff80) {
            	//WTF?!  Bizarre flags...
            	trace("16bit prop");
            	decode16BitProp();
            }
            else if (Boolean(propFormat & PROP_FORMAT_S20BIT)) {
            	trace("s20bit prop");
            	decodeS20BitProp();
            }
            else if (Boolean(propFormat & PROP_FORMAT_32BIT)) {
            	trace("32bit prop");
	       		decode32BitProp();
            }
            else if (Boolean(propFormat & PROP_FORMAT_20BIT)) {
            	trace("20bit prop");
	       		decode20BitProp();
            }
            else {
            	trace("8bit prop");
            	decode8BitProp();
            }
			
			
			ready = true;
			asset.data = null;
			dispatchEvent(new PropEvent(PropEvent.PROP_LOADED, this));
		}
		
		
		private function decode32BitProp():void {
			// Implementation thanks to Phalanx team
			// Translated from VB6 implementation
			
			var unzipByteArray:ByteArray = new ByteArray();
			for (var i:int = 12; i < asset.data.length; i ++) {
				unzipByteArray.writeByte(asset.data[i]);
			}
			unzipByteArray.uncompress();
			unzipByteArray.position = 0;
			var data:Array = [];
			while (unzipByteArray.bytesAvailable) {
				data.push(unzipByteArray.readUnsignedByte());
			}
			
			var bd:BitmapData = new BitmapData(width, height);
			var ba:ByteArray = new ByteArray();
			var C:uint;
			var x:int = 0;
			var y:int = 0;
			var ofst:int = 0;
			var X:int = 0;
			var A:uint = 0;
			var R:uint = 0;
			var G:uint = 0;
			var B:uint = 0;
			
			var Col:int = 32; // Bit depth??
			
			for (X = 0; X <= 1935; X++) {
				ofst = X * 4;
				R = data[ofst];
				G = data[ofst+1];
				B = data[ofst+2];
				A = data[ofst+3];
				if (Col == 32) {
					R = uint(R * A / 255) & 0xFF;
					G = uint(G * A / 255) & 0xFF;
					B = uint(B * A / 255) & 0xFF;
				}
				else {
					if (A < 128) {
						R = B = A = 0;
						G = 254;
					}
					else {
						A = 255;
					}
				}
				ba.writeByte(A);
				ba.writeByte(R);
				ba.writeByte(G);
				ba.writeByte(B);
			}
			ba.position = 0;
			bd.setPixels(rect, ba);
			bitmap = bd;
		}
		
		
		private static const dither20bit:Number = 255/63;
		
		private function decode20BitProp():void {
			// Implementation thanks to Phalanx team
			// Translated from VB6 implementation
			
			var unzipByteArray:ByteArray = new ByteArray();
			for (var i:int = 12; i < asset.data.length; i ++) {
				unzipByteArray.writeByte(asset.data[i]);
			}
			unzipByteArray.uncompress();
			unzipByteArray.position = 0;
			var data:Array = [];
			while (unzipByteArray.bytesAvailable) {
				data.push(unzipByteArray.readUnsignedByte());
			}
			
			var bd:BitmapData = new BitmapData(width, height);
			var ba:ByteArray = new ByteArray();
			var C:uint;
			var x:int = 0;
			var y:int = 0;
			var ofst:int = 0;
			var X:int = 0;
			var A:uint = 0;
			var R:uint = 0;
			var G:uint = 0;
			var B:uint = 0;
			
			var Col:int = 32; // Bit depth??
			
			for (X = 0; X <= 967; X++) {
				ofst = X * 5;
				R = uint((uint(data[ofst] >> 2) & 63) * dither20bit);
				C = (data[ofst] << 8) | data[ofst+1];
				G = uint(((C >> 4) & 63) * dither20bit);
				C = (data[ofst+1] << 8) | data[ofst+2];
				B = uint(((C >> 6) & 63) * dither20bit);
				A = (((C >> 4) & 3) * 85);
				
				if (Col == 32) {
					R = uint((R * A) / 255) & 0xFF;
					G = uint((G * A) / 255) & 0xFF;
					B = uint((B * A) / 255) & 0xFF;
				}
				else {
					if (A < 128) {
						R = B = A = 0;
						G = 254;
					}
					else {
						A = 255;
					}
				}

				ba.writeByte(A);
				ba.writeByte(R);
				ba.writeByte(G);
				ba.writeByte(B);

//				x ++;
//				if (x > 44) {
//					y ++;
//				}
//				
//				var color:uint = A << 24 | R << 16 | G << 8 | B;
//				bd.setPixel32(x,y,color);

				C = (data[ofst+2] << 8) | data[ofst+3];
				R = uint(((C >> 6) & 63) * dither20bit);
				G = uint((C & 63) * dither20bit);
				C = data[ofst+4];
				B = uint(((C >> 2) & 63) * dither20bit);
				A = ((C & 3) * 85);
				if (Col == 32) {
					R = uint((R * A) / 255) & 0xFF;
					G = uint((G * A) / 255) & 0xFF;
					B = uint((B * A) / 255) & 0xFF;
				}
				else {
					if (A < 128) {
						R = B = A = 0;
						G = 254;
					}
					else {
						A = 255;
					}
				}
				
				ba.writeByte(A);
				ba.writeByte(R);
				ba.writeByte(G);
				ba.writeByte(B);
			}
			ba.position = 0; 
			bd.setPixels(rect, ba);
			bitmap = bd;
		}
		
		
		// Constant for decoding s20bit props
		private static const l:Number = 8.2258064516129;
		
		private function decodeS20BitProp():void {
			// Implementation thanks to Phalanx team
			
			var unzipByteArray:ByteArray = new ByteArray();
			for (var i:int = 12; i < asset.data.length; i ++) {
				unzipByteArray.writeByte(asset.data[i]);
			}
			unzipByteArray.uncompress();
			unzipByteArray.position = 0;
			var data:Array = [];
			while (unzipByteArray.bytesAvailable) {
				data.push(unzipByteArray.readUnsignedByte());
			}
			
			var bd:BitmapData = new BitmapData(width, height);
			var colors:Array = new Array(9); // array of bytes
			var C:uint;
			var x:int = 0;
			var y:int = 0;
			var ofst:int = 0;
			var X:int = 0;
			
			var Col:int = 32; // Bit depth??
			
			var color:uint;
			
			var ba:ByteArray = new ByteArray();
			
			for (X = 0; X < 968; X++) {
				ofst = X * 5;
				
				colors[2] = uint(((data[ofst] >> 3) & 31) * l) & 0xFF; // << 3; //red
				C = (data[ofst] << 8) | data[ofst+1];
				colors[1] = uint((C >> 6 & 31) * l) & 0xFF; //<< 3; //green
				colors[0] = uint((C >> 1 & 31) * l) & 0xFF; //<< 3; //blue
				C = (data[ofst+1] << 8) | data[ofst+2];
				colors[3] = uint((C >> 4 & 31) * l) & 0xFF; //<< 3; //alpha
				
				if (Col == 32) {
					colors[0] = uint(colors[0] * colors[3] / 255) & 0xFF; // >> 8;
					colors[1] = uint(colors[1] * colors[3] / 255) & 0xFF; // >> 8;
					colors[2] = uint(colors[2] * colors[3] / 255) & 0xFF; // >> 8;
				}
				else {
					if (colors[3] < 128) {
						colors[3] = 0;
						colors[1] = 254;
						colors[2] = 0;
						colors[0] = 0;
					}
					else {
						colors[3] = 255;
					}
				}
				
				ba.writeByte(colors[3]);
				ba.writeByte(colors[2]);
				ba.writeByte(colors[1]);
				ba.writeByte(colors[0]);
				
				x++;
				
				C = (data[ofst+2] << 8) | data[ofst+3];
				colors[6] = uint((C >> 7 & 31) * l) & 0xFF; // << 3; //red
				colors[5] = uint((C >> 2 & 31) * l) & 0xFF; // << 3; //green
				C = (data[ofst+3] << 8) | data[ofst+4];
				colors[4] = uint((C >> 5 & 31) * l) & 0xFF; // << 3; //blue
				colors[7] = uint((C & 31) * l) & 0xFF; // << 3; //alpha
				
				if (Col == 32) { // if ((a<128) && (Col < 32)) return; //{
					colors[4] = uint(colors[4] * colors[7] / 255) & 0xFF; // >> 8;
					colors[5] = uint(colors[5] * colors[7] / 255) & 0xFF; // >> 8;
					colors[6] = uint(colors[6] * colors[7] / 255) & 0xFF; // >> 8;
				}
				else {
					if (colors[7] < 128) {
						colors[6] = 0;
						colors[5] = 254;
						colors[4] = 0;
						colors[7] = 0;
					}
					else {
						colors[7] = 255;
					}
				}				
				
				ba.writeByte(colors[7]);
				ba.writeByte(colors[6]);
				ba.writeByte(colors[5]);
				ba.writeByte(colors[4]);
				
				if (x > 43) {
					x = 0;
					y++;
				}
			}
			ba.position = 0;
			bd.setPixels(rect, ba);
			bitmap = bd;
		}
		
		private function decode16BitProp():void {
			var ba:ByteArray = new ByteArray();
			var bd:BitmapData = new BitmapData(44,44, true);
			var A:uint = 0;
			var R:uint = 0;
			var G:uint = 0;
			var B:uint = 0;
			var C:uint;
			var x:int = 0;
			var y:int = 0;
			var ofst:int = 0;
			var X:int = 0;
			
			// gunzip the props...
			var unzipByteArray:ByteArray = new ByteArray();
			for (var i:int = 12; i < asset.data.length; i ++) {
				unzipByteArray.writeByte(asset.data[i]);
			}
			unzipByteArray.uncompress();
			unzipByteArray.position = 0;
			var data:Array = [];
			while (unzipByteArray.bytesAvailable) {
				data.push(unzipByteArray.readUnsignedByte());
			}
			
			for (X=0; X < 1936; X++) {
				ofst = X * 2;
				C = data[ofst] * 256 | data[ofst + 1];
				R = uint((uint(data[ofst] / 8) & 31) * 255 / 31) & 0xFF;
				G = uint((uint(C / 64) & 31) * 255 / 31) & 0xFF;
				B = uint((uint(C / 2) & 31) * 255 / 31) & 0xFF;
				A = (C & 1) * 255 & 0xFF;
				
				ba.writeByte(A);
				ba.writeByte(R);
				ba.writeByte(G);
				ba.writeByte(B);
				
				x ++;
				
				if (x > 43) {
					x = 0;
					y++;
				}
				
			}
			
			ba.position = 0;
			bd.setPixels(rect, ba);
			bitmap = bd;
		}

		private function decode8BitProp():void {
            var counter:int = 0; 
            
            var pixData:Array = new Array(width * (height + 1));
            var n:int = 12;
            var index:int = width;
            for (var y:int = height - 1; y >= 0; y--)
            {
                for(var x:int = width; x > 0;)
                {
                    var cb:int = asset.data[n] & 0xff;
                    n++;
                    var mc:int = cb >> 4;
                    var pc:int = cb & 0xF;
                    x -= mc + pc;
                    if (x < 0) {
                    	badProp = true;
                    	ready = false;
                    	asset.data = null
                    	return;
                    }
                	if (counter++ > 6000) {
                		// script runaway protection
                		trace("There was an error while decoding props.  Max loop count exceeded.");
                		badProp = true;
                		ready = false;
                		asset.data = null
                		return;
                	};
                    index += mc;
                    while (pc-- > 0) {
                        if(asset.data.length > n) {
                            pixData[index++] = PalacePalette.clutARGB[asset.data[n++] & 0xff];
                        }
                    }
                }

            }
            
			// Using setPixels() now instead of setPixel() -- WAY faster.
            
			var bitmapBytes:ByteArray = new ByteArray();
			var z:int = pixData.length;
			for (y = 44; y < z; y ++) {
				bitmapBytes.writeUnsignedInt(pixData[y]);
			}
			bitmapBytes.position = 0;			

            var bitmapData:BitmapData = new BitmapData(width, height, true);
			bitmapData.setPixels(rect, bitmapBytes);
			
			bitmap = bitmapData;
		}
	}
}