package net.codecomposer.palace.rpc.webservice
{
	import flash.events.Event;

	public class OPWSEvent extends Event
	{
		public static const RESULT_EVENT:String = 'result';
		public static const FAULT_EVENT:String = 'fault';
		
		public var result:Object;
		
		public function OPWSEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}