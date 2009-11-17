package org.openpalace.iptscrae.command.operator
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptVariable;
	import org.openpalace.iptscrae.command.IptCommand;
	import org.openpalace.iptscrae.token.IptToken;

	public class AssignOperator extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var variable:IptVariable = context.stack.popType(IptVariable);
			var value:IptToken = context.stack.pop().dereference();
			variable.value = value;
		}
	}
}