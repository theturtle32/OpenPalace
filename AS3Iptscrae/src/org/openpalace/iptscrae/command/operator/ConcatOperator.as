package org.openpalace.iptscrae.command.operator
{
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.command.IptCommand;
	import org.openpalace.iptscrae.token.IptToken;
	import org.openpalace.iptscrae.token.StringToken;

	public class ConcatOperator extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var a2:IptToken = context.stack.popType(StringToken);
			var a1:IptToken = context.stack.popType(StringToken);
			var result:IptToken;
			if (a1 is StringToken && a2 is StringToken) {
				result = new StringToken(
					StringToken(a1).data + StringToken(a2).data
				);
			}
			else {
				throw new IptError("Operator (+): Argument type mismatch.");
			}
			context.stack.push(result);
		}
	}
}