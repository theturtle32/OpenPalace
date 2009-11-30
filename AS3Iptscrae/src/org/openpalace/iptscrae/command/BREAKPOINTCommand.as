package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	
	public class BREAKPOINTCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			context.manager.pause();
		}			
	}
}