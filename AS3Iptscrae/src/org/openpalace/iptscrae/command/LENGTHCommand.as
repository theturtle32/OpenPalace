package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.ArrayToken;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.IptCommand;

	public class LENGTHCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var array:ArrayToken = context.stack.popType(ArrayToken);
			context.stack.push(new IntegerToken( array.data.length ));
		}
	}
}