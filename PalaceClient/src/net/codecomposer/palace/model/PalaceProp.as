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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.setTimeout;
	
	import mx.core.FlexBitmap;
	import mx.graphics.codec.PNGEncoder;
	
	import net.codecomposer.palace.event.PropEvent;
	
	[Event(name="propLoaded",type="net.codecomposer.palace.event.PropEvent")]
	[Event(name="propDecoded",type="net.codecomposer.palace.event.PropEvent")]
	
	
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
		
		public var webServiceFormat:String;
		
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
		
		private static const dither20bit:Number = 255/63;
		private static const ditherS20Bit:Number = 255/31;

		private static const ASSET_CRC_MAGIC:uint = 0xd9216290;
		
		private static const rect:Rectangle = new Rectangle(0,0,44,44);
		
		private static const mask:uint = 0xFFC1; // Original palace prop flags.
		
		private static var formatMask:uint = PROP_FORMAT_20BIT |
							 				 PROP_FORMAT_S20BIT |
							  	 			 PROP_FORMAT_32BIT;
		
		private static var itemsToRender:int = 0;
		
		private var loader:Loader;
		
		public function PalaceProp(guid:String, assetId:uint, assetCrc:uint)
		{
			asset = new PalaceAsset();
			asset.id = assetId;
			asset.crc = assetCrc;
			asset.guid = guid;
			//BindingUtils.bindProperty(this, "source", this, "bitmap")
		}
		
		public static function fromObject(source:Object):PalaceProp {
			var prop:PalaceProp = new PalaceProp(source.asset.guid, source.asset.id, source.asset.crc);
			prop.animate = source.animate;
			prop.width = source.width;
			prop.height = source.height;
			prop.horizontalOffset = source.horizontalOffset;
			prop.verticalOffset = source.verticalOffset;
			prop.scriptOffset = source.scriptOffset;
			prop.flags = source.flags;
			prop.ready = false;
			prop.badProp = source.badProp;
			prop.head = source.head;
			prop.ghost = source.ghost;
			prop.rare = source.rare;
			prop.animate = source.animate;
			prop.palindrome = source.palindrome;
			prop.bounce = source.bounce;
			prop.propFormat = source.propFormat;
			prop.webServiceFormat = source.webServiceFormat;
			prop.asset.blockCount = source.asset.blockCount;
			prop.asset.blockNumber = source.asset.blockNumber;
			prop.asset.blockOffset = source.asset.blockOffset;
			prop.asset.blockSize = source.asset.blockSize;
			prop.asset.crc = source.asset.crc;
			prop.asset.data = source.asset.data;
			prop.asset.flags = source.asset.flags;
			prop.asset.id = source.asset.id;
			prop.asset.name = source.asset.name;
			prop.asset.type = source.asset.type;
			return prop;
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
		
		public function get pngData():ByteArray {
			if (_bitmap != null) {
				var encoder:PNGEncoder = new PNGEncoder();
				return encoder.encode(_bitmap);
			}
			else {
				return null;
			}
		}
		
		public function decodeProp():void {			
			// Try not to block the UI while props are rendering.
			setTimeout(renderBitmap, 200+20*(++itemsToRender));
		}
		
		public function loadBitmapFromURL(url:String = null):void {
			if (url == null) {
				url = asset.imageDataURL;
			}
			loader = new Loader();
			var request:URLRequest = new URLRequest(url);
			
			var context:LoaderContext = new LoaderContext(true);
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleBitmapLoadedFromURLComplete);
			loader.load(request, context);
		}
		
		private function handleBitmapLoadedFromURLComplete(event:Event):void {
			if (loader.content && loader.content is Bitmap) {
				bitmap = Bitmap(loader.content).bitmapData;
				ready = true;
				dispatchEvent(new PropEvent(PropEvent.PROP_LOADED, this));
			}
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
				webServiceFormat = PalacePropFormat.FORMAT_16_BIT;
            	decode16BitProp();
            }
            else if (Boolean(propFormat & PROP_FORMAT_S20BIT)) {
            	trace("s20bit prop");
				webServiceFormat = PalacePropFormat.FORMAT_S20_BIT;
            	decodeS20BitProp();
            }
            else if (Boolean(propFormat & PROP_FORMAT_32BIT)) {
            	trace("32bit prop");
				webServiceFormat = PalacePropFormat.FORMAT_32_BIT;
	       		decode32BitProp();
            }
            else if (Boolean(propFormat & PROP_FORMAT_20BIT)) {
            	trace("20bit prop");
				webServiceFormat = PalacePropFormat.FORMAT_20_BIT;
	       		decode20BitProp();
            }
            else {
            	trace("8bit prop");
				webServiceFormat = PalacePropFormat.FORMAT_8_BIT;
            	decode8BitProp();
            }
			
			if (!badProp) {
				ready = true;
				dispatchEvent(new PropEvent(PropEvent.PROP_DECODED, this));
			}
			
			// We need to keep the asset data around now, to be able
			// to upload it to other servers.
			//asset.data = null;
			
			dispatchEvent(new PropEvent(PropEvent.PROP_LOADED, this));
		}
		
		private function computeCRC(data:ByteArray):uint {
			var originalPosition:uint = data.position;
			data.position = 0;
			var crc:uint = ASSET_CRC_MAGIC;
			var len:int = data.bytesAvailable;
			while (len--) {
				var currentByte:uint = data.readUnsignedByte();
				crc = ((crc << 1) | ((crc & 0x80000000) ? 1 : 0)) ^ (currentByte);
			}
			data.position = originalPosition;
			return crc;
		}
		
		public function assetData(endian:String = Endian.LITTLE_ENDIAN):ByteArray {
			var ba:ByteArray = new ByteArray();
			ba.endian = endian;
			
			var flags:uint = 0;
			if (animate)
				flags = flags | ANIMATE_FLAG;
			if (bounce)
				flags = flags | BOUNCE_FLAG;
			if (head)
				flags = flags | HEAD_FLAG;
			if (palindrome)
				flags = flags | PALINDROME_FLAG;
			if (rare)
				flags = flags | RARE_FLAG;
			if (ghost)
				flags = flags | GHOST_FLAG;
			
			// Set s20bit format
			flags = flags | PROP_FORMAT_S20BIT;
			
			var imageData:ByteArray = encodeS20BitProp();
			imageData.position = 0;
			var assetCRC:uint = computeCRC(imageData);
			
			var size:uint = imageData.length + 12; // 12 bytes for metadata
			
			// AssetType
			ba.writeInt(PalaceAsset.ASSET_TYPE_PROP);
			
			// AssetSpec
			ba.writeInt(asset.id);
			ba.writeUnsignedInt(assetCRC);
			
			// BlockSize
			ba.writeInt(size);
			
			// BlockOffset
			ba.writeInt(0); // always zero
			
			// BlockNbr
			ba.writeShort(0); // always zero
			
			// NbrBlocks
			ba.writeShort(1);
			
		// AssetDescriptor
			// flags
			ba.writeUnsignedInt(0); // this is unused.. not really the prop flags
			// size
			ba.writeUnsignedInt(size);
			// name
			ba.writeByte(asset.name.length);
			var paddedName:String = asset.name;
			for (var ct:int = 0; ct < 31 - asset.name.length; ct ++) {
				paddedName += " ";
			}
			trace("PaddedName: \"" + paddedName + "\" length: " + paddedName.length);
			ba.writeMultiByte(paddedName, 'Windows-1252');
		
			// Data -- first 12 bytes are info about prop
			ba.writeShort(44);
			ba.writeShort(44);
			if (width > 44 || height > 44) {
				ba.writeShort(0);
				ba.writeShort(0);
			}
			else {
				ba.writeShort(horizontalOffset);
				ba.writeShort(verticalOffset);
			}
			ba.writeShort(0); // script offset??!
			ba.writeShort(flags);
			
			// Image Data
			ba.writeBytes(imageData);
			
			return ba;
		}
		
		private function decode32BitProp():void {
			// Implementation thanks to Phalanx team
			// Translated from VB6 implementation
			var data:ByteArray = new ByteArray();
			for (var i:int = 12; i < asset.data.length; i ++) {
				data.writeByte(asset.data[i]);
			}
			data.position = 0;
			//trace("Computed CRC: " + computeCRC(data) + " - Given CRC: " + asset.crc);
			
			data.uncompress();
			
			var bd:BitmapData = new BitmapData(width, height);
			var ba:Vector.<uint> = new Vector.<uint>(width*height, true);
			var C:uint;
			var x:int = 0;
			var y:int = 0;
			var ofst:int = 0;
			var X:int = 0;
			var A:uint = 0;
			var R:uint = 0;
			var G:uint = 0;
			var B:uint = 0;
			
			var pos:uint = 0;
			
			for (X = 0; X <= 1935; X++) {
				ofst = X * 4;
				R = data[ofst];
				G = data[ofst+1];
				B = data[ofst+2];
				A = data[ofst+3];

				ba[pos++] = (A<<24 | R<<16 | G<<8 | B);

			}
			bd.setVector(rect, ba);
			bitmap = bd;
		}
		
		private function decode20BitProp():void {
			// Implementation thanks to Phalanx team
			// Translated from VB6 implementation
			
			var data:ByteArray = new ByteArray();
			for (var i:int = 12; i < asset.data.length; i ++) {
				data.writeByte(asset.data[i]);
			}
			data.position = 0;
			//trace("Computed CRC: " + computeCRC(data) + " - Given CRC: " + asset.crc);
			data.uncompress();
			
			var bd:BitmapData = new BitmapData(width, height);
			var ba:Vector.<uint> = new Vector.<uint>(width*height, true);
			var C:uint;
			var x:int = 0;
			var y:int = 0;
			var ofst:int = 0;
			var X:int = 0;
			var A:uint = 0;
			var R:uint = 0;
			var G:uint = 0;
			var B:uint = 0;
			
			var pos:uint = 0;
			
			for (X = 0; X <= 967; X++) {
				ofst = X * 5;
				R = uint((uint(data[ofst] >> 2) & 63) * dither20bit);
				C = (data[ofst] << 8) | data[ofst+1];
				G = uint(((C >> 4) & 63) * dither20bit);
				C = (data[ofst+1] << 8) | data[ofst+2];
				B = uint(((C >> 6) & 63) * dither20bit);
				A = (((C >> 4) & 3) * 85);

				ba[pos++] = (A<<24 | R<<16 | G<<8 | B);

				C = (data[ofst+2] << 8) | data[ofst+3];
				R = uint(((C >> 6) & 63) * dither20bit);
				G = uint((C & 63) * dither20bit);
				C = data[ofst+4];
				B = uint(((C >> 2) & 63) * dither20bit);
				A = ((C & 3) * 85);
				
				ba[pos++] = (A<<24 | R<<16 | G<<8 | B);
			}
			bd.setVector(rect, ba);
			bitmap = bd;
		}
		
		
		private function encodeS20BitProp():ByteArray {
			// Implementation ported from REALBasic code provided by
			// Jameson Heesen (Pa\/\/n), of PalaceChat
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.BIG_ENDIAN;
			var bm:FlexBitmap = FlexBitmap(bitmap);
			if (bm && bm is FlexBitmap) {
				var bitmapData:BitmapData = bm.bitmapData;
				var propBit16:Number = 31 / 255;
				var data:Vector.<uint>;
				if (bm.width != 44 || bm.height != 44) {
					trace("Encoding proxy prop");
					var pixelCount:uint = 44 * 44;
					data = new Vector.<uint>(pixelCount);
					for (var i:int = 0; i < pixelCount; i++) {
						data[i] = 0x00FFFFFF;
					}
				}
				else {
					data = bitmapData.getVector(new Rectangle(0,0,44,44));
				}
				var pixelIndex:uint = 0;
				var intComp:uint = 0;
				var a:uint, r:uint, g:uint, b:uint;
				for (var y:int = 0; y < 44; y++) {
					for (var x:int = 0; x < 44; x++) {
						var color:uint;
						color = data[pixelIndex];
						a = ((color & 0xFF000000) >> 24) & 0xFF;
						r = ((color & 0x00FF0000) >> 16) & 0xFF;
						g = ((color & 0x0000FF00) >> 8) & 0xFF;
						b =  (color & 0x000000FF);
						intComp =            uint(Math.round(Number(r) * propBit16)) << 19;
						intComp = intComp | (uint(Math.round(Number(g) * propBit16)) << 14);
						intComp = intComp | (uint(Math.round(Number(b) * propBit16)) << 9);
						intComp = intComp | (uint(Math.round(Number(a) * propBit16)) << 4);
						
						ba.writeByte((intComp & 0xFF0000) >> 16);
						ba.writeByte((intComp &   0xFF00) >> 8);
						// ba.writeByte(intComp & 0xF0);
						
						pixelIndex ++;
						x++;
						
						intComp = (intComp & 0xF0) << 16;
							
						color = data[pixelIndex];
						a = ((color & 0xFF000000) >> 24) & 0xFF;
						r = ((color & 0x00FF0000) >> 16) & 0xFF;
						g = ((color & 0x0000FF00) >> 8) & 0xFF;
						b =  (color & 0x000000FF);
						
						intComp = intComp | (uint(Math.round(Number(r) * propBit16)) << 15);
						intComp = intComp | (uint(Math.round(Number(g) * propBit16)) << 10);
						intComp = intComp | (uint(Math.round(Number(b) * propBit16)) << 5);
						intComp = intComp |  uint(Math.round(Number(a) * propBit16));
						
						ba.writeByte((intComp & 0xFF0000) >> 16);
						ba.writeByte((intComp & 0x00FF00) >> 8);
						ba.writeByte( intComp & 0x0000FF);
						
						pixelIndex ++;
					}
				}
			}
			ba.compress();
			ba.position = 0;
			return ba;
		}
		
		private function decodeS20BitProp():void {
			// Implementation thanks to Phalanx team
			// Translated from C++ implementation
			
			var data:ByteArray = new ByteArray();
			for (var i:int = 12; i < asset.data.length; i ++) {
				data.writeByte(asset.data[i]);
			}
			data.position = 0;
			//trace("Computed CRC: " + computeCRC(data) + " - Given CRC: " + asset.crc);
			data.uncompress();
			
			var bd:BitmapData = new BitmapData(width, height);
			var C:uint;
			var x:int = 0;
			var y:int = 0;
			var ofst:int = 0;
			var X:int = 0;
			
			var color:uint;
			
			var ba:Vector.<uint> = new Vector.<uint>(width*height, true);
			
			var A:uint, R:uint, G:uint, B:uint; 
			
			var pos:uint = 0;
			
			for (X = 0; X < 968; X++) {
				ofst = X * 5;
				
				R = uint(((data[ofst] >> 3) & 31) * ditherS20Bit) & 0xFF; // << 3; //red
				C = (data[ofst] << 8) | data[ofst+1];
				G = uint((C >> 6 & 31) * ditherS20Bit) & 0xFF; //<< 3; //green
				B = uint((C >> 1 & 31) * ditherS20Bit) & 0xFF; //<< 3; //blue
				C = (data[ofst+1] << 8) | data[ofst+2];
				A = uint((C >> 4 & 31) * ditherS20Bit) & 0xFF; //<< 3; //alpha
				
				ba[pos++] = (A<<24 | R<<16 | G<<8 | B);

				x++;
				
				C = (data[ofst+2] << 8) | data[ofst+3];
				R = uint((C >> 7 & 31) * ditherS20Bit) & 0xFF; // << 3; //red
				G = uint((C >> 2 & 31) * ditherS20Bit) & 0xFF; // << 3; //green
				C = (data[ofst+3] << 8) | data[ofst+4];
				B = uint((C >> 5 & 31) * ditherS20Bit) & 0xFF; // << 3; //blue
				A = uint((C & 31) * ditherS20Bit) & 0xFF; // << 3; //alpha				
				
				ba[pos++] = (A<<24 | R<<16 | G<<8 | B);
								
				if (x > 43) {
					x = 0;
					y++;
				}
			}
			bd.setVector(rect, ba);
			bitmap = bd;
		}
		
		private function decode16BitProp():void {
			// Implementation thanks to Phalanx team
			// Translated from C++ implementation
			
			var ba:Vector.<uint> = new Vector.<uint>(width*height, true);
			var bd:BitmapData = new BitmapData(width, height, true);
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
			var data:ByteArray = new ByteArray();
			for (var i:int = 12; i < asset.data.length; i ++) {
				data.writeByte(asset.data[i]);
			}
			data.position = 0;
			//trace("Computed CRC: " + computeCRC(data) + " - Given CRC: " + asset.crc);
			data.uncompress();
			
			var pos:uint = 0;
			
			for (X=0; X < 1936; X++) {
				ofst = X * 2;
				C = data[ofst] * 256 | data[ofst + 1];
				R = uint((uint(data[ofst] / 8) & 31) * 255 / 31) & 0xFF;
				G = uint((uint(C / 64) & 31) * 255 / 31) & 0xFF;
				B = uint((uint(C / 2) & 31) * 255 / 31) & 0xFF;
				A = (C & 1) * 255 & 0xFF;
				
				ba[pos++] = (A<<24 | R<<16 | G<<8 | B);
				
				x ++;
				
				if (x > 43) {
					x = 0;
					y++;
				}
				
			}
			
			bd.setVector(rect, ba);
			bitmap = bd;
		}

		private function decode8BitProp():void {
            var counter:int = 0; 
            var ba:ByteArray = new ByteArray();
            var pixData:Vector.<uint> = new Vector.<uint>(width * (height + 1), true);
            var n:int = 12;
//			for (n = 12; n < asset.data.length; n++) {
//				ba.writeByte(asset.data[n]);
//			}
//			ba.position = 0;
//			trace("Computed CRC: " + computeCRC(ba) + " - Given CRC: " + asset.crc);
//			
//			n = 12;
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
            
			var bitmapBytes:Vector.<uint> = new Vector.<uint>(width*height, true);
			var pos:uint = 0;
			var z:int = pixData.length;
			for (y = 44; y < z; y ++) {
				bitmapBytes[pos++] = pixData[y];
			}

            var bitmapData:BitmapData = new BitmapData(width, height, true);
			bitmapData.setVector(rect, bitmapBytes);
			
			bitmap = bitmapData;
		}
	}
}