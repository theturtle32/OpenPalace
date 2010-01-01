package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class SETSPOTNAMELOCALCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var spotId:IntegerToken = context.stack.popType(IntegerToken);
			var text:StringToken = context.stack.popType(StringToken);
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			pc.setSpotName(spotId.data, text.data);
		}
	}
}