package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptTokenList;
	import org.openpalace.iptscrae.IptVariable;
	import org.openpalace.iptscrae.token.ArrayMarkToken;
	import org.openpalace.iptscrae.token.ArrayToken;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.IptToken;
	import org.openpalace.iptscrae.token.StringToken;

	public class VARTYPECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			if (context.stack.depth == 0) {
				context.stack.push(new IntegerToken(0));
				return;
			}
			var token:IptToken = context.stack.pick(0).dereference();
			if (token is IntegerToken) {
				context.stack.push(new IntegerToken(1));
			}
			else if (token is IptVariable) {
				context.stack.push(new IntegerToken(2));
			}
			else if (token is IptTokenList) {
				context.stack.push(new IntegerToken(3));
			}
			else if (token is StringToken) {
				context.stack.push(new IntegerToken(4));
			}
			else if (token is ArrayMarkToken) {
				context.stack.push(new IntegerToken(5));
			}
			else if (token is ArrayToken) {
				context.stack.push(new IntegerToken(6));
			}
			else {
				context.stack.push(new IntegerToken(0));
			}
		}
	}
}