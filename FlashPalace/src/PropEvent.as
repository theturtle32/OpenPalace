package
{
	import flash.events.Event;
	import flash.net.FileReference;
	
	public class PropEvent extends Event
	{
		public static const NEW_PROP:String = "newProp";
		public static const SAVE_PROP:String = "saveProp";
		
		public var fileReference:FileReference;
		public var newPropDefinition:NewPropDefinition;
		
		public function PropEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}