package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.IptCommand;

	public class TRACESTACKCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			while (context.stack.depth > 0) {
				context.manager.traceMessage(context.stack.pop().toString());
			}
		}
	}
}