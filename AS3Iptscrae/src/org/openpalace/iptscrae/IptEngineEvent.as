package org.openpalace.iptscrae
{
	import flash.events.Event;
	
	public class IptEngineEvent extends Event
	{
		public static const TRACE_MESSAGE:String = "traceMessage";
		
		public var message:String;
		
		public function IptEngineEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}