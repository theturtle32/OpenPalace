package net.codecomposer.palace.model
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
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
		
		private static const mask:uint = 0xFFC1; // Original palace prop flags.
		
		private static var unsupportedFormatMask:uint = PROP_FORMAT_20BIT |
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
			setTimeout(renderBitmap, 300+150*(++itemsToRender));
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
            
            propFormat = flags & unsupportedFormatMask;
            
            trace("Non-Standard flags: " + uint(flags & mask).toString(16));
        	var propUnsupported:Boolean = Boolean(flags & unsupportedFormatMask);
        	if (propUnsupported) {
        		trace("Unsupported prop format - bailing.");
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
            var bitmapData:BitmapData = new BitmapData(width, height, true);
            index = 44;
            for (y = 0; y < height; y++) {
				for (x = 0; x < width; x++) {
					bitmapData.setPixel32(x, y, pixData[index++]);
				}
			}
			bitmap = bitmapData;
			ready = true;
			asset.data = null;
			dispatchEvent(new PropEvent(PropEvent.PROP_LOADED, this));
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