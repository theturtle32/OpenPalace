package org.openpalace.iptscrae.command.operator
{
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptUtil;
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class LessThanOrEqualToOperator extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var arg2:IptToken = context.stack.popType(IptToken);
			var arg1:IptToken = context.stack.popType(IptToken);
			if (arg1 is IntegerToken && arg2 is IntegerToken) {
				context.stack.push(
					new IntegerToken(
						(IntegerToken(arg1).data <= IntegerToken(arg2).data) ? 1 : 0
					)
				);
			}
			else if (arg1 is StringToken && arg2 is StringToken) {
				context.stack.push(
					new IntegerToken(
						(StringToken(arg1).data.toUpperCase() <= StringToken(arg2).data.toUpperCase()) ? 1 : 0
					)
				);
			}
			else {
				throw new IptError("Type mismatch or incompatible data type.  " +
					"argument 1 is type " + IptUtil.className(arg1) + ", " +
					"and argument 2 is type " + IptUtil.className(arg2) + ".");
			}
		}
	}
}