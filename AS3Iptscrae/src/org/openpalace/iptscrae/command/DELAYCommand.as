package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class DELAYCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var ticks:IntegerToken = context.stack.popType(IntegerToken);
			// Do nothing.
		}
	}
}