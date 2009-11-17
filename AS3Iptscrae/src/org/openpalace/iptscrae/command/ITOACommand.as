package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class ITOACommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var integerInput:IntegerToken = context.stack.popType(IntegerToken);
			context.stack.push(new StringToken(IntegerToken(integerInput).data.toString()));
		}
	}
}