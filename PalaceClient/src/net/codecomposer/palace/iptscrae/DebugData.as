package net.codecomposer.palace.iptscrae
{
	import mx.collections.ArrayCollection;
	
	import net.codecomposer.palace.model.PalaceCurrentRoom;
	import net.codecomposer.palace.model.PalaceHotspot;

	public class DebugData
	{
		[Bindable]
		public var hotspots:ArrayCollection = new ArrayCollection();
		
		public function DebugData(room:PalaceCurrentRoom)
		{
			for each (var hotspot:PalaceHotspot in room.hotSpots) {
				if (hotspot.eventHandlers.length > 0) {
					var copy:PalaceHotspot = new PalaceHotspot();
					copy.id = hotspot.id;
					copy.name = hotspot.name;
					copy.eventHandlers = hotspot.eventHandlers;
					hotspots.addItem(copy);
				}
			}
			trace('debug data updated');
		}
		
		public function eventHandlers(hotspot:PalaceHotspot):ArrayCollection {
			var handlerAC:ArrayCollection = new ArrayCollection();
			for each (var eventHandler:IptEventHandler in hotspot.eventHandlers) {
				handlerAC.addItem(eventHandler);
			}
			return handlerAC;
		}
	}
}