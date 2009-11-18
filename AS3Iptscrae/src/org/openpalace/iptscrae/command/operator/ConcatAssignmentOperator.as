package org.openpalace.iptscrae.command.operator
{
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptVariable;
	import org.openpalace.iptscrae.command.IptCommand;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class ConcatAssignmentOperator extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var variable:IptVariable = context.stack.popType(IptVariable);
			if (!(variable.value is StringToken)) {
				throw new IptError("Variable '" + variable.name + "' does not contain a string.");
			}
			var originalValue:StringToken = StringToken(variable.value);
			var arg:StringToken = context.stack.popType(StringToken);
			variable.value = new StringToken(originalValue.data + arg.data);
		}
	}
}