package customCommands
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.command.IptCommand;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class SAYCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var message:StringToken = context.stack.popType(StringToken);
			TestIptscraeManager(context.manager).traceMessage("Chat text: " + message.data);
		}
	}
}