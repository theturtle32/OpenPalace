package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptExecutionContext;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class SETALARMCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			var spotId:int = context.stack.popType(IntegerToken).data;
			var futureTime:IntegerToken = context.stack.popType(IntegerToken);
			if (spotId == 0) {
				spotId = PalaceIptExecutionContext(pc).hotspotId;
			}
			pc.setSpotAlarm(spotId, futureTime.data);
		}
	}
}