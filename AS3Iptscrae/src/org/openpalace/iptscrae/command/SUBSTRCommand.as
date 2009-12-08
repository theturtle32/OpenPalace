package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;

	public class SUBSTRCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var fragment:StringToken = context.stack.popType(StringToken);
			var whole:StringToken = context.stack.popType(StringToken);
			context.stack.push(new IntegerToken(whole.data.toLowerCase().indexOf(fragment.data.toLowerCase()) != -1 ? 1 : 0));
		}
	}
}