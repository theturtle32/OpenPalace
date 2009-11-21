package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class PRIVATEMSGCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			var userId:IntegerToken = context.stack.popType(IntegerToken);
			var message:StringToken = context.stack.popType(StringToken);
			pc.sendPrivateMessage(message.data, userId.data);
		}
	}
}