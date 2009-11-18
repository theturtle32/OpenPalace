package org.openpalace.iptscrae
{
	import org.openpalace.iptscrae.command.IptCommand;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class UPPERCASECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var string:StringToken = context.stack.popType(StringToken);
			context.stack.push(new StringToken(string.data.toUpperCase()));
		}
	}
}