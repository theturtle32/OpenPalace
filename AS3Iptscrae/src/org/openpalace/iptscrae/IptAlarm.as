package org.openpalace.iptscrae
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class IptAlarm
	{
		private var timer:Timer;
		public var tokenList:IptTokenList;
		public var manager:IptManager;
		private var _delay:uint = 0;
		public var completed:Boolean = false;
		
		public function set delayTicks(ticks:int):void {
			_delay = ticksToMS(ticks);
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
		
		public function IptAlarm(script:IptTokenList, manager:IptManager, delayTicks:uint)
		{
			timer = new Timer(ticksToMS(delayTicks), 1);
			timer.addEventListener(TimerEvent.TIMER, handleTimer);
			this.tokenList = script;
			this.manager = manager;
			this.delayTicks = delayTicks;
		}
		
		private function handleTimer(event:TimerEvent):void {
			completed = true;
			manager.handleAlarm(this);
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