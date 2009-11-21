package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class SUBSTRINGCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var length:IntegerToken = context.stack.popType(IntegerToken);
			var offset:IntegerToken = context.stack.popType(IntegerToken);
			var string:StringToken = context.stack.popType(StringToken);
			if (offset.data < 0) {
				throw new IptError("Offset cannot be negative.");
			}
			context.stack.push(new StringToken(string.data.substr(offset.data, length.data)));
		}
	}
}