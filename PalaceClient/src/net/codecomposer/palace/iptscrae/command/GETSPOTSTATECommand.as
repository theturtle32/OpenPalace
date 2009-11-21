package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class GETSPOTSTATECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var spotId:IntegerToken = context.stack.popType(IntegerToken);
			var spotState:int = PalaceIptManager(context.manager).pc.getSpotState(spotId.data);
			context.stack.push(new IntegerToken(spotState));
		}
	}
}