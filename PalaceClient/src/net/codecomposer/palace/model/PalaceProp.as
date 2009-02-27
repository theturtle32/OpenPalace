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
	import flash.utils.Endian;
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
            
            if ((flags & mask) == 0xff80) {
            	//WTF?!
            	trace("WTF?! Unsupported and unknown prop -- specifically avoiding it.");
	       		badProp = true;
        		ready = false;
        		asset.data = null
        		return;
            } 
            
           	head = Boolean(flags & HEAD_FLAG);
           	ghost = Boolean(flags & GHOST_FLAG);
           	rare = Boolean(flags & RARE_FLAG);
           	animate = Boolean(flags & ANIMATE_FLAG);
           	palindrome = Boolean(flags & PALINDROME_FLAG);
           	bounce = Boolean(flags & BOUNCE_FLAG);
            
            if (Boolean(propFormat & PROP_FORMAT_S20BIT)) {
            	trace("s20bit prop");
            	decodeS20BitProp();
            }
            else if (Boolean(propFormat & PROP_FORMAT_32BIT)) {
            	trace("32bit prop");
	       		badProp = true;
        		ready = false;
        		asset.data = null
        		return;
            }
            else if (Boolean(propFormat & PROP_FORMAT_20BIT)) {
            	trace("20bit prop");
	       		badProp = true;
        		ready = false;
        		asset.data = null
        		return;
            }
            else {
            	trace("8bit prop");
            	decode8BitProp();
            }
			
			
			ready = true;
			asset.data = null;
			dispatchEvent(new PropEvent(PropEvent.PROP_LOADED, this));
		}
		
		
		// Constant for decoding s20bit props
		private static const l:Number = 8.2258064516129;
		
		private function decodeS20BitProp():void {
			// Implementation thanks to Phalanx team
			
			var unzipByteArray:ByteArray = new ByteArray();
			for (var i:int = 12; i < asset.data.length; i ++) {
				unzipByteArray.writeByte(asset.data[i]);
			}
			unzipByteArray.position = 0;
			unzipByteArray.endian = Endian.LITTLE_ENDIAN;
			unzipByteArray.uncompress();
			unzipByteArray.position = 0;
			var data:Array = [];
			while (unzipByteArray.bytesAvailable) {
				data.push(unzipByteArray.readUnsignedByte());
			}
			
			trace("Decoding 20 bit prop... have " + asset.data.length + " bytes to work with, need " + 5*968);
			
			var bd:BitmapData = new BitmapData(width, height);
			var A:int = 0;
			var R:int = 0;
			var G:int = 0;
			var B:int = 0;
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
				
				//          Alpha                  Red               Green           Blue
				//color = (colors[3] << 24) | (colors[2] << 16) | (colors[1] << 8) | colors[0];
				//bd.setPixel32(x, y, color);
				
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
				
				//          Alpha                  Red               Green           Blue
//				color = (colors[7] << 24) | (colors[6] << 16) | (colors[5] << 8) | colors[4];
//				bd.setPixel32(x, y, color);

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
			var bd:BitmapData = new BitmapData(44,44);
			var A:uint = 0;
			var R:uint = 0;
			var G:uint = 0;
			var B:uint = 0;
			var C:uint;
			var x:int = 0;
			var y:int = 0;
			var ofst:int = 0;
			var X:int = 0;
			
			for (X=0; X < 1935; X++) {
				ofst = X * 2;
				C = asset.data[ofst] & 0xFF * 256 | asset.data[ofst + 1];
				R = uint((uint(asset.data[ofst] / 8) & 31) * 255 / 31);
				G = uint((uint(C / 64) & 31) * 255 / 31);
				B = uint((uint(C / 2) & 31) * 255 / 31);
				A = (C & 1) * 255;
				
				ba.writeByte(A);
				ba.writeByte(R);
				ba.writeByte(G);
				ba.writeByte(B);
			}
			
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
                            pixData[index++] = clutARGB[asset.data[n++] & 0xff];
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


		// Color Lookup Table for the Palace "M&M" Palette
		private static var clutARGB:Array = [
	        -1, 0xffccffff, 0xff99ffff, 0xff66ffff, 0xff33ffff, 0xff00ffff, -8193, 0xffccdfff, 0xff99dfff, 0xff66dfff, 
	        0xff33dfff, 0xff00dfff, -16385, 0xffccbfff, 0xff99bfff, 0xff66bfff, 0xff33bfff, 0xff00bfff, -24577, 0xffcc9fff, 
	        0xff999fff, 0xff669fff, 0xff339fff, 0xff009fff, -32769, 0xffcc7fff, 0xff997fff, 0xff667fff, 0xff337fff, 0xff007fff, 
	        -40961, 0xffcc5fff, 0xff995fff, 0xff665fff, 0xff335fff, 0xff005fff, -49153, 0xffcc3fff, 0xff993fff, 0xff663fff, 
	        0xff333fff, 0xff003fff, -57345, 0xffcc1fff, 0xff991fff, 0xff661fff, 0xff331fff, 0xff001fff, -65281, 0xffcc00ff, 
	        0xff9900ff, 0xff6600ff, 0xff3300ff, 0xff0000ff, 0xffeeeeee, 0xffdddddd, 0xffcccccc, 0xffbbbbbb, -86, 0xffccffaa, 
	        0xff99ffaa, 0xff66ffaa, 0xff33ffaa, 0xff00ffaa, -8278, 0xffccdfaa, 0xff99dfaa, 0xff66dfaa, 0xff33dfaa, 0xff00dfaa, 
	        -16470, 0xffccbfaa, 0xff99bfaa, 0xff66bfaa, 0xff33bfaa, 0xff00bfaa, 0xffaaaaaa, -24662, 0xffcc9faa, 0xff999faa, 
	        0xff669faa, 0xff339faa, 0xff009faa, -32854, 0xffcc7faa, 0xff997faa, 0xff667faa, 0xff337faa, 0xff007faa, -41046, 
	        0xffcc5faa, 0xff995faa, 0xff665faa, 0xff335faa, 0xff005faa, -49238, 0xffcc3faa, 0xff993faa, 0xff663faa, 0xff333faa, 
	        0xff003faa, -57430, 0xffcc1faa, 0xff991faa, 0xff661faa, 0xff331faa, 0xff001faa, -65366, 0xffcc00aa, 0xff9900aa, 
	        0xff6600aa, 0xff3300aa, 0xff0000aa, 0xff999999, 0xff888888, 0xff777777, 0xff666666, -171, 0xffccff55, 0xff99ff55, 
	        0xff66ff55, 0xff33ff55, 0xff00ff55, -8363, 0xffccdf55, 0xff99df55, 0xff66df55, 0xff33df55, 0xff00df55, -16555, 
	        0xffccbf55, 0xff99bf55, 0xff66bf55, 0xff33bf55, 0xff00bf55, -24747, 0xffcc9f55, 0xff999f55, 0xff669f55, 0xff339f55, 
	        0xff009f55, -32939, 0xffcc7f55, 0xff997f55, 0xff667f55, 0xff337f55, 0xff007f55, -41131, 0xffcc5f55, 0xff995f55, 
	        0xff665f55, 0xff335f55, 0xff005f55, 0xff555555, -49323, 0xffcc3f55, 0xff993f55, 0xff663f55, 0xff333f55, 0xff003f55, 
	        -57515, 0xffcc1f55, 0xff991f55, 0xff661f55, 0xff331f55, 0xff001f55, -65451, 0xffcc0055, 0xff990055, 0xff660055, 
	        0xff330055, 0xff000055, 0xff444444, 0xff333333, 0xff222222, 0xff111111, -256, 0xffccff00, 0xff99ff00, 0xff66ff00, 
	        0xff33ff00, 0xff00ff00, -8448, 0xffccdf00, 0xff99df00, 0xff66df00, 0xff33df00, 0xff00df00, -16640, 0xffccbf00, 
	        0xff99bf00, 0xff66bf00, 0xff33bf00, 0xff00bf00, -24832, 0xffcc9f00, 0xff999f00, 0xff669f00, 0xff339f00, 0xff009f00, 
	        -33024, 0xffcc7f00, 0xff997f00, 0xff667f00, 0xff337f00, 0xff007f00, -41216, 0xffcc5f00, 0xff995f00, 0xff665f00, 
	        0xff335f00, 0xff005f00, -49408, 0xffcc3f00, 0xff993f00, 0xff663f00, 0xff333f00, 0xff003f00, -57600, 0xffcc1f00, 
	        0xff991f00, 0xff661f00, 0xff331f00, 0xff001f00, 0xffff0000, 0xffcc0000, 0xff990000, 0xff660000, 0xff330000, 0xff000000, 
	        0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 
	        0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 
	        0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000
		];
	}
}