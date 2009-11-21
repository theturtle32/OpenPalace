package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class SETSPOTSTATELOCALCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var spotId:IntegerToken = context.stack.popType(IntegerToken);
			var state:IntegerToken = context.stack.popType(IntegerToken);
			PalaceIptManager(context.manager).pc.setSpotStateLocal(spotId.data, state.data);
		}
	}
}