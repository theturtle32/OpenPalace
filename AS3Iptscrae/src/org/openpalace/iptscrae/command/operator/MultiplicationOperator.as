package org.openpalace.iptscrae.command.operator
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.command.IptCommand;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class MultiplicationOperator extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var multiplier:IntegerToken = context.stack.popType(IntegerToken);
			var multiplicand:IntegerToken = context.stack.popType(IntegerToken);
			context.stack.push(new IntegerToken(multiplicand.data * multiplier.data));
		}
	}
}