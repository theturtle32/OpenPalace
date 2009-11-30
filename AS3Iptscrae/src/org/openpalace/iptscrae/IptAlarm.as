package org.openpalace.iptscrae
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class IptAlarm extends EventDispatcher
	{
		private var timer:Timer;
		public var tokenList:IptTokenList;
		public var context:IptExecutionContext;
		private var _delay:uint = 0;
		public var completed:Boolean = false;
		
		public function set delayTicks(ticks:int):void {
			_delay = ticksToMS(ticks);
			if (_delay < 10) {
				_delay = 10;
			}
			timer.delay = _delay;
		}
		public function get delayTicks():int {
			return msToTicks(_delay);
		}
		
		private function ticksToMS(ticks:uint):uint {
			return ticks / 60 * 1000;
		}
		
		private function msToTicks(ms:uint):uint {
			return ms / 1000 * 60;
		}
		
		public function IptAlarm(script:IptTokenList, manager:IptManager, delayTicks:uint, context:IptExecutionContext = null)
		{
			timer = new Timer(ticksToMS(delayTicks), 1);
			timer.addEventListener(TimerEvent.TIMER, handleTimer);
			if (context == null) {
				context = new manager.executionContextClass(manager); 
			}
			this.context = context;
			this.tokenList = script;
			this.delayTicks = delayTicks;
		}
		
		private function handleTimer(event:TimerEvent):void {
			dispatchEvent(new IptEngineEvent(IptEngineEvent.ALARM));
			completed = true;
		}
		
		public function start():void {
			timer.reset();
			timer.start();
		}
		
		public function stop():void {
			timer.stop();
		}
	}
}