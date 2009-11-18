package org.openpalace.iptscrae.command.operator
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.command.IptCommand;
	import org.openpalace.iptscrae.token.IptToken;
	import org.openpalace.iptscrae.token.StringToken;

	public class ConcatOperator extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var arg2:StringToken = context.stack.popType(StringToken);
			var arg1:StringToken = context.stack.popType(StringToken);
			context.stack.push(new StringToken(arg1.data + arg2.data));
		}
	}
}