package org.openpalace.iptscrae
{
	

	public interface IIptManager
	{
		function execute(script:String):void;
		function executeWithContext(script:String, context:IptExecutionContext):void;
		function get currentRunnableItem():Runnable;
		function step():void;
		function addAlarm(alarm:IptAlarm):void;
		function removeAlarm(alarm:IptAlarm):void;
		function clearAlarms():void;
	}
}