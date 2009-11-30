package org.openpalace.iptscrae.command.operator
{
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptUtil;
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class InequalityOperator extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var a2:IptToken = context.stack.pop().dereference();
			var a1:IptToken = context.stack.pop().dereference();
			var result:IntegerToken;
			if (a1 is IntegerToken && a2 is IntegerToken) {
				result = new IntegerToken(
					(IntegerToken(a1).data !=
						IntegerToken(a2).data) ? 1 : 0
				);
				
			}
			else if (a1 is StringToken && a2 is StringToken) {
				result = new IntegerToken(
					(StringToken(a1).data !=
						StringToken(a2).data) ? 1 : 0
				);
			}
			else {
				result = new IntegerToken(1);
			}
			context.stack.push(result);
		}
	}
}