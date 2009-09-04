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
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import net.codecomposer.palace.event.PropEvent;

	[Bindable]
	public class PalaceUser extends EventDispatcher
	{
		// wizard
		public static const SUPERUSER:uint = 0x0001;
		
		// Total wizard
		public static const GOD:uint = 0x0002;
		
		// Server should drop user at first opportunity
		public static const KILL:uint = 0x0004;
		
		// user is a guest (no registration code)
		public static const GUEST:uint = 0x0008;
		
		// Redundant with KILL.  Shouldn't be used
		public static const BANISHED:uint = 0x0010;
		
		// historical artifact.  Shouldn't be used
		public static const PENALIZED:uint = 0x0020;
		
		// Comm error, drop at first opportunity
		public static const COMM_ERROR:uint = 0x0040;
		
		// Not allowed to speak
		public static const GAG:uint = 0x0080;
		
		// Stuck in corner and not allowed to move
		public static const PIN:uint = 0x0100;
		
		// Doesn't appear on user list
		public static const HIDE:uint = 0x0200;
		
		// Not accepting whisper from outside room
		public static const REJECT_ESP:uint = 0x0400;
		
		// Not accepting whisper from inside room
		public static const REJECT_PRIVATE:uint = 0x0800;
		
		// Not allowed to wear props
		public static const PROPGAG:uint = 0x1000;
		
		
		public var isSelf:Boolean = false;
		public var id:int;
		public var name:String = "Uninitialized User";
		public var x:int;
		public var y:int;
		public var roomID:int;
		public var roomName:String;
		public var propCount:int;
		public var face:int = 1;
		public var color:int = 2;
		public var flags:int = 0;
		public var propIds:Array = [];
		public var propCrcs: Array = [];
		public var props:ArrayCollection = new ArrayCollection();
		
		public var showFace:Boolean = true;
		
		private var propStore:PalacePropStore = PalacePropStore.getInstance();
		
		private static function filterBadProps(object:Object):Boolean {
			var prop:PalaceProp = PalaceProp(object);
			return !prop.badProp;
		}
		
		public function PalaceUser()
		{
			props.filterFunction = filterBadProps;
			props.refresh();
		}
		
		public function toggleProp(prop:PalaceProp):void {
			var wearingProp:Boolean = (props.source.indexOf(prop) != -1);
			if (wearingProp) {
				removeProp(prop);
			}
			else {
				wearProp(prop);
			}
		}
		
		public function wearProp(prop:PalaceProp):void {
			if (props.length < 9) {
				props.addItem(prop);
			}
			syncPropIdsToProps();
			checkFaceProps();
		}
		
		public function removeProp(prop:PalaceProp):void {
			var propIndex:int = props.source.indexOf(prop);
			if (propIndex != -1) {
				props.removeItemAt(propIndex);
			}
			syncPropIdsToProps();
			checkFaceProps();
		}
		
		public function naked():void {
			props.removeAll();
			syncPropIdsToProps();
			checkFaceProps();
		}
		
		public function syncPropIdsToProps():void {
			propCount = props.length;
			propIds = [];
			propCrcs = [];
			for each (var prop:PalaceProp in props) {
				propIds.push(prop.asset.id);
				propCrcs.push(prop.asset.crc);
			}
		}
		
		public function loadProps():void {
			var i:int = 0;
			var prop:PalaceProp;
			for (i=0; i < props.length; i++) {
				prop = PalaceProp(props.getItemAt(i));
				prop.removeEventListener(PropEvent.PROP_LOADED, handlePropLoaded);
			}
			props.removeAll();
			for (i = 0; i < propCount; i ++) {
				prop = propStore.getProp(null, propIds[i], propCrcs[i]);
				if (!prop.ready) {
					prop.addEventListener(PropEvent.PROP_LOADED, handlePropLoaded);
				}
				props.addItem(prop);
			}
			checkFaceProps();
		}
		
		private function handlePropLoaded(event:PropEvent):void {
			checkFaceProps();
		}
		
		private function checkFaceProps():void {
			var showFace:Boolean = true;
			for (var i:int = 0; i < props.length; i ++) {
				var prop:PalaceProp = PalaceProp(props.getItemAt(i));
				if (prop.head) {
					showFace = false;
				}
			}
			this.showFace = showFace;
		}

	}
}