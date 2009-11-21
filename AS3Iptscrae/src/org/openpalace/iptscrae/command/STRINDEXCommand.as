package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class STRINDEXCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var string2:StringToken = context.stack.popType(StringToken);
			var string1:StringToken = context.stack.popType(StringToken);
			context.stack.push(new IntegerToken(string1.data.indexOf(string2.data)));
		}
	}
}