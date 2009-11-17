package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class ITOACommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var a1:IntegerToken = context.stack.popType(IntegerToken);
			var result:StringToken = new StringToken(a1.data.toString());
			context.stack.push(result);
		}
	}
}