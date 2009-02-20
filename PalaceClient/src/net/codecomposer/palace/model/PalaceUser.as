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
			if (propCount == 0) {
				showFace = true;
			}
			this.showFace = showFace;
		}

	}
}