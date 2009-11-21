package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class LOCALMSGCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var message:StringToken = context.stack.popType(StringToken);
			PalaceIptManager(context.manager).pc.sendLocalMsg(message.data);
		}
	}
}