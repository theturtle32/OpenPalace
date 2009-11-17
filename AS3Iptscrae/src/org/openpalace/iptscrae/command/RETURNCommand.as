package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	
	public class RETURNCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			context.returnRequested = true;
		}
	}
}