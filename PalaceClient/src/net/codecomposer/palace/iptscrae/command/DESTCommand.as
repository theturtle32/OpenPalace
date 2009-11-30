package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptExecutionContext;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class DESTCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			var selfHotspotId:int = PalaceIptExecutionContext(context).hotspotId;
			context.stack.push(new IntegerToken(pc.getSpotDest(selfHotspotId)));
		}
	}
}