package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;

	public class POPCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			context.stack.pop();
		}
	}
}