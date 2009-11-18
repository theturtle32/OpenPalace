package org.openpalace.iptscrae
{
	public interface IIptManager
	{
		function execute(script:String):void;
		function executeWithContext(script:String, context:IptExecutionContext):void;
		function handleAlarm(alarm:IptAlarm):void;
	}
}