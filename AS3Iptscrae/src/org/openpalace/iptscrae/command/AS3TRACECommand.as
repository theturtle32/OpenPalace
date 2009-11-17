package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.StringToken;

	public class AS3TRACECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var token:StringToken = context.stack.popType(StringToken);
			trace(token.data);
		}
	}
}