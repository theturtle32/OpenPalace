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
		public var stateRecs:Array = []; // Array of HStateRec objects
		public var eventHandlerRecs:Array = []; // Array of HEventHandlerRec objects
		public var ory:uint = 0;
		public var orx:uint = 0;
		public var scriptEventMask:uint = 0;
		public var numScripts:uint = 0;
		public var gSPBuf:Array = [];
		public var gSPIdx:uint = 0;
		public var ungetFlag:Boolean = false;
		public var gToken:String = "";
		public var scriptText:String = "";
		
		public function PalaceHotspot()
		{
		}

		public function fromBytes(endian:String, bs:Array, offset:int):void {

			
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
			ory = ba.readUnsignedShort();
			orx = ba.readUnsignedShort();
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
			
			// Not yet implemented
//	        if(nbrStates > 0)
//	        {
//	            stateRecs = new HStateRec[nbrStates];
//	            for(int i = 0; i < nbrStates; i++)
//	            {
//	                HStateRec hs = new HStateRec();
//	                hs.fromBytes(bigEndian, bs, stateRecOfst);
//	                stateRecOfst += HStateRec.size();
//	                stateRecs[i] = hs;
//	            }
//	
//	        }
//	        loadScripts(bs, scriptTextOffset);

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
				polygon.push(new Point(x + orx, y + ory));
			}
			
			polygon.push(new Point(startX + orx, startY + ory));
			
			trace("Got new hotspot: " + this.id + " - DestID: " + dest + " - name: " + this.name + " - PointCount: " + ptCnt);
		}
		
		public function get size():int {
			return 48;
		}

	}
}