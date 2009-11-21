package net.codecomposer.palace.script
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import net.codecomposer.palace.iptscrae.PalaceController;

	public class IptAlarm
	{
		private var timer:Timer;
		public var script:String;
		public var spotId:int;
		private var _delay:uint = 0;
		public var completed:Boolean = false;
		public var palaceController:PalaceController;

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
		
		public function IptAlarm(script:String, spotId:int, delayTicks:uint, palaceController:PalaceController)
		{
			timer = new Timer(ticksToMS(delayTicks), 1);
			timer.addEventListener(TimerEvent.TIMER, handleTimer);
			this.script = script;
			this.spotId = spotId;
			this.delayTicks = delayTicks;
			this.palaceController = palaceController;
		}
		
		private function handleTimer(event:TimerEvent):void {
			completed = true;
			//palaceController.handleAlarm(this);
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