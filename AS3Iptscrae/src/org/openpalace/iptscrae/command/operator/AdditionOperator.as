package org.openpalace.iptscrae.command.operator
{
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.command.IptCommand;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.IptToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class AdditionOperator extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var a2:IptToken = context.stack.pop().dereference();
			var a1:IptToken = context.stack.pop().dereference();
			var result:IptToken;
			if (a1 is IntegerToken && a2 is IntegerToken) {				
				result = new IntegerToken(
					IntegerToken(a1).data + IntegerToken(a2).data
				);
			}
			else if (a1 is StringToken && a2 is StringToken) {
				result = new StringToken(
					StringToken(a1).data + StringToken(a2).data
				);
			}
			else {
				throw new IptError("Argument type mismatch.");
			}
			context.stack.push(result);
		}
	}
}