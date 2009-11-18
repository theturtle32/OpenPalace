package org.openpalace.iptscrae.command.operator
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.command.IptCommand;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.IptToken;
	
	public class LogicalOrOperator extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var arg2:IptToken = context.stack.popType(IptToken);
			var arg1:IptToken = context.stack.popType(IptToken);
			context.stack.push(new IntegerToken( (arg1.toBoolean() || arg2.toBoolean()) ? 1 : 0 ));
		}
	}
}