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
	import mx.collections.ArrayCollection;
	
	import net.codecomposer.palace.event.PropEvent;
	
	[Bindable]
	public class PalaceUser
	{
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
			var wearingProp:Boolean = false;
			for each (var currentProp:PalaceProp in props) {
				if (currentProp.asset.id == prop.asset.id) {
					wearingProp = true;
				}
			}
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
			checkFaceProps();
		}
		
		public function removeProp(prop:PalaceProp):void {
			var propIndex:int;
			var wearingProp:Boolean = false;
			for (var i:int = 0; i < props.length; i++) {
				var currentProp:PalaceProp = PalaceProp(props.getItemAt(i));
				if (currentProp.asset.id == prop.asset.id) {
					wearingProp = true;
					propIndex = i;
				}
			}
			
			if (wearingProp) {
				props.removeItemAt(propIndex);
			}
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
				prop = propStore.getProp(propIds[i], propCrcs[i]);
				if (!prop.ready) {
					prop.addEventListener(PropEvent.PROP_LOADED, handlePropLoaded);
				}
				props.addItem(prop);
			}
			checkFaceProps();
		}
		
		private function handlePropLoaded(event:PropEvent):void {
			trace("Prop loaded...");
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
			if (props.length == 0) {
				showFace = true;
			}
			this.showFace = showFace;
		}

	}
}