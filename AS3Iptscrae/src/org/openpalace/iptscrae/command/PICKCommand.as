package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.IptCommand;

	public class PICKCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var pickDepth:IntegerToken = context.stack.popType(IntegerToken);
			var token:IptToken = context.stack.pick(pickDepth.data);
			context.stack.push(token);
		}
	}
}