package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.StringToken;
	import org.openpalace.iptscrae.IptCommand;

	public class TRACECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var token:StringToken = context.stack.popType(StringToken);
			context.manager.traceMessage(token.data);
			trace(token.data);
		}
	}
}