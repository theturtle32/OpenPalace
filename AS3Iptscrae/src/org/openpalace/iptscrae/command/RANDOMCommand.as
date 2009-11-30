package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class RANDOMCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var number:IntegerToken = context.stack.popType(IntegerToken);
			context.stack.push(new IntegerToken(int(Math.random() * Number(number.data))));
		}
	}
}