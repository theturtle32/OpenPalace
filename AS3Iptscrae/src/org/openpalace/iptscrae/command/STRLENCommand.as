package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;

	public class STRLENCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var string:StringToken = context.stack.popType(StringToken);
			context.stack.push(new IntegerToken( string.data.length ));
		}
	}
}