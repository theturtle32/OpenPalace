package org.openpalace.iptscrae.command.operator
{
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptVariable;
	import org.openpalace.iptscrae.command.IptCommand;
	import org.openpalace.iptscrae.token.IntegerToken;

	public class PlusAssignOperator extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var variable:IptVariable = context.stack.popType(IptVariable);
			if (!(variable.value is IntegerToken)) {
				throw new IptError("PlusAssignOperator: Variable " + variable.name + " does not contain a number.");
			}
			var originalValue:IntegerToken = IntegerToken(variable.value);
			var value:IntegerToken = context.stack.popType(IntegerToken);
			variable.value = new IntegerToken(originalValue.data + value.data);
		}
	}
}