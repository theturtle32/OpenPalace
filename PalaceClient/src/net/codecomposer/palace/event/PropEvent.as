package net.codecomposer.palace.event
{
	import flash.events.Event;
	
	import net.codecomposer.palace.model.PalaceProp;

	public class PropEvent extends Event
	{
		public var prop:PalaceProp;
		
		public static const PROP_LOADED:String = "propLoaded";
		
		public function PropEvent(type:String, prop:PalaceProp)
		{
			this.prop = prop;
			super(type, false, false);
		}
		
	}
}