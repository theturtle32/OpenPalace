package net.codecomposer.palace.model
{
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;
	
	import net.codecomposer.palace.rpc.PalaceClient;
	
	public class PropBag
	{
		
		private var palace:PalaceClient = PalaceClient.getInstance();
		
		[Bindable]
		public var props:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var savedAvatars:ArrayCollection = new ArrayCollection();
		
		private var propStore:PalacePropStore = PalacePropStore.getInstance();
		
		private var so:SharedObject; 
		
		public function PropBag() {
			try {
				so = SharedObject.getLocal("OpenPalace");
			}
			catch (error:Error) {
				trace("Unable to allocate local storage: " + error.toString());
			}
			if (so != null) {
				loadPropBag();
			}
		}
		
		public function loadPropBag():void {
			trace("Loading Prop Bag");
			if (so.data.propIds) {
				for each (var propDef:Array in so.data.propIds) {
					var id:int = propDef[0];
					var crc:int = propDef[1];
					trace("Got prop: " + id + " CRC: " + crc);
					props.addItem(propStore.getProp(null, id, crc));
				}
			}
			else {
				so.data.propIds = [];
			}
			
			if (so.data.avatars) {
				for each (var avatar:Array in so.data.avatars) {
					trace("Have an avatar.");
				}
			}
			else {
				so.data.avatars = [];
			}
		}
		
		public function loadPropImages():void {
			for each (var prop:PalaceProp in props) {
				if (!prop.ready) {
					propStore.loadImage(prop);
				}
			}
		}
		
		public function saveCurrentAvatar():void {
			if (!palace.connected) {
				return;
			}
			var currentUser:PalaceUser = palace.currentUser;
			var avatar:Array = [];
			for each (var prop:PalaceProp in currentUser.props) {
				if (props.source.indexOf(prop) == -1) {
					addProp(prop);
				}
				avatar.push(prop.asset.id);
			}
			savedAvatars.addItem(avatar);
			savePropBag();
		}
				
		public function savePropBag():void {
			trace("Saving Prop Bag");
			var propIds:Array = [];
			var avatarsToSave:Array = [];
			for each (var prop:PalaceProp in props) {
				propIds.push([prop.asset.id, prop.asset.crc]);
			}
			for each (var avatar:Array in savedAvatars) {
				avatarsToSave.push(avatar);
			} 
			so.data.propIds = propIds;
			so.data.avatars = avatarsToSave;
			so.flush();
		}
		
		public function deleteAllProps():void {
			props.removeAll();
			savePropBag();
		}
		
		public function addProp(prop:PalaceProp):void {
			props.addItem(prop);
			savePropBag();
		}
		
		public function deleteProp(prop:PalaceProp):void {
			var propIndex:int = props.source.indexOf(prop);
			if (propIndex != -1) {
				props.removeItemAt(propIndex);
			}
			savePropBag();
		}
		
		public function toggleProp(prop:PalaceProp):void {
			if (palace.connected) {
				palace.currentUser.toggleProp(prop);
				palace.currentUser.syncPropIdsToProps();
				palace.updateUserProps();
			}
		}
		
		public function naked():void {
			if (palace.connected) {
				palace.currentUser.naked();
				palace.updateUserProps();
			}
		}

	}
}