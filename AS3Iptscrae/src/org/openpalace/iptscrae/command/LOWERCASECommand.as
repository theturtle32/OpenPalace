package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.StringToken;
	import org.openpalace.iptscrae.IptCommand;

	public class LOWERCASECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var string:StringToken = context.stack.popType(StringToken);
			context.stack.push(new StringToken(string.data.toLowerCase()));
		}
	}
}