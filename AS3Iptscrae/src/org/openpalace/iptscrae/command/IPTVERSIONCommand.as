package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;

	public class IPTVERSIONCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			context.stack.push(new IntegerToken(1));
		}
	}
}