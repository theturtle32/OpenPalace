package org.openpalace.iptscrae.command.operator
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class DivisionOperator extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var divisor:IntegerToken = context.stack.popType(IntegerToken);
			var dividend:IntegerToken = context.stack.popType(IntegerToken);
			context.stack.push(new IntegerToken(int(dividend.data / divisor.data)));
		}
	}
}