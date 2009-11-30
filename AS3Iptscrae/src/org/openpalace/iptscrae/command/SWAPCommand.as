package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.IptCommand;

	public class SWAPCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var token1:IptToken = context.stack.pop();
			var token2:IptToken = context.stack.pop();
			context.stack.push(token1);
			context.stack.push(token2);
		}
	}
}