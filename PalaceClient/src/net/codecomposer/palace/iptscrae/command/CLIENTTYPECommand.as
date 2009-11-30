package net.codecomposer.palace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class CLIENTTYPECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			context.stack.push(new StringToken("WINDOWS32"));
		}
	}
}