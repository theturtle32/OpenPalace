package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;

	public class BREAKCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			context.breakRequested = true;
		}
	}
}