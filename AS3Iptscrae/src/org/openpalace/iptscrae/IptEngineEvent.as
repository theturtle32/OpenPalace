package org.openpalace.iptscrae
{
	import flash.events.Event;
	
	public class IptEngineEvent extends Event
	{
		public static const TRACE_MESSAGE:String = "trace";
		public static const PAUSE:String = "pause";
		public static const RESUME:String = "resume";
		public static const ABORT:String = "abort";
		public static const START:String = "start";
		public static const FINISH:String = "finish";
		
		public var message:String;
		
		public function IptEngineEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}