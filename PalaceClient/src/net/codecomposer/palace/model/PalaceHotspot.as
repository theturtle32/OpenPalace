package net.codecomposer.palace.model
{
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public class PalaceHotspot
	{
		
		public var type:int = 0;
		public var dest:int = 0;
		public var id:int = 0;
		public var flags:int = 0;
		public var state:int = 0;
		public var numStates:int = 0;
		public var polygon:Array = []; // Array of points
		public var name:String = null;
		public var stateRecs:Array = []; // Array of HStateRec objects
		public var eventHandlerRecs:Array = []; // Array of HEventHandlerRec objects
		public var ory:int = 0;
		public var orx:int = 0;
		public var scriptEventMask:int = 0;
		public var numScripts:int = 0;
		public var gSPBuf:Array = [];
		public var gSPIdx:int = 0;
		public var ungetFlag:Boolean = false;
		public var gToken:String = "";
		
		public function PalaceHotspot()
		{
		}
		
		public function fromBytes(bs:Array, offset:int):void {
			var ba:ByteArray = new ByteArray();
			//imageBA.endian = Endian.BIG_ENDIAN;
			for (var j:int=offset-1; j < offset+size-1; j++) {
				ba.writeByte(bs[j]);
			}
			ba.position = 0;
			
			scriptEventMask = ba.readInt();
			flags = ba.readInt();
			ba.readInt();
			ba.readInt();
			ory = ba.readShort();
			orx = ba.readShort();
			id = ba.readShort();
			dest = ba.readShort();
			var ptCnt:int = ba.readShort();
			var ptsOffset:int = ba.readShort();
			type = ba.readShort();
			ba.readShort();
			numScripts = ba.readShort();
			ba.readShort();
			state = ba.readShort();
			numStates = ba.readShort();
			var stateRecOffset:int = ba.readShort();
			var nameOffset:int = ba.readShort();
			var scriptTextOffset:int = ba.readShort();
			ba.readShort();
			if (nameOffset > 0) {
				name = "";
				var nameLength:int = bs[nameOffset];
				for (j=0; j < nameLength; j++) {
					var nameByte:int = bs[nameOffset+j+1]; 
					name += String.fromCharCode(nameByte);
				}
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
			//imageBA.endian = Endian.BIG_ENDIAN;
			var endPos:int = ptsOffset+(ptCnt*4)-1;
			for (j=ptsOffset-1; j < endPos; j++) {
				ba.writeByte(bs[j]);
			}
			ba.position = 0;
			var startX:int = 0;
			var startY:int = 0;
			for (var i:int = 0; i < ptCnt; i++) {
				var y:int = ba.readShort();
				var x:int = ba.readShort();
				if (i == 0) {
					startX = x;
					startY = y;
				}
				polygon.push(new Point(x + orx, y + ory));
			}
			
			polygon.push(new Point(startX + orx, startY + ory));
			
			trace("Got new hotspot: " + this.id + " name: " + this.name);
		}
		
		public function get size():int {
			return 48;
		}

	}
}