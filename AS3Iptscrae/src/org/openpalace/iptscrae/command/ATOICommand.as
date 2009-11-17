package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class ATOICommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var a1:StringToken = context.stack.popType(StringToken);
			var result:IntegerToken = new IntegerToken(parseInt(a1.data));
			context.stack.push(result);
		}
	}
}