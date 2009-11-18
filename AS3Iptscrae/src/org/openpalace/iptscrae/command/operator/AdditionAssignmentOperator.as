package org.openpalace.iptscrae.command.operator
{
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptUtil;
	import org.openpalace.iptscrae.IptVariable;
	import org.openpalace.iptscrae.command.IptCommand;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.IptToken;
	import org.openpalace.iptscrae.token.StringToken;

	public class AdditionAssignmentOperator extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var variable:IptVariable = context.stack.popType(IptVariable);
			var argument:IptToken = context.stack.popType(IptToken);
			var originalValue:IptToken = variable.value;
			if (argument is IntegerToken && originalValue is IntegerToken) {
				variable.value = new IntegerToken(
						IntegerToken(variable.value).data +
						IntegerToken(argument).data
					);
			}
			else if (argument is StringToken && originalValue is StringToken) {
				variable.value = new StringToken(
						StringToken(variable.value).data +
						StringToken(argument).data
					);
			}
			else {
				throw new IptError("Variable type mismatch or incompatible data type.  " +
								   "Variable '" + variable.name + "' contains type " + IptUtil.className(originalValue) + ", " +
								   "and the supplied argument is type " + IptUtil.className(argument) + ".");
			}
		}
	}
}