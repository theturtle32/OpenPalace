package net.codecomposer.palace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class PENSIZECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var size:IntegerToken = context.stack.popType(IntegerToken);
			// TODO: Actually send the command
		}
	}
}