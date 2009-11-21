package org.openpalace.iptscrae.command.operator
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.IptToken;
	
	public class LogicalNotOperator extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var token:IptToken = context.stack.pop().dereference();
			context.stack.push(new IntegerToken( token.toBoolean() ? 0 : 1 ));
		}
	}
}