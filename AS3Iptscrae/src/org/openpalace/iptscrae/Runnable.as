package org.openpalace.iptscrae
{
	public interface Runnable
	{
		function execute(context:IptExecutionContext):void;
		function step():void;
		function end():void;
		function get running():Boolean;
		function toString():String;
	}
}