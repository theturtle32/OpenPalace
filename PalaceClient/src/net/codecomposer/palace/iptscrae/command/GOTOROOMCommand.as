package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class GOTOROOMCommand extends IptCommand
	{
		public override function execute(context:IptExecutionContext) : void {
			var roomId:IntegerToken = context.stack.popType(IntegerToken);
			// A GOTOROOM command cancels the rest of the script.
			context.exitRequested = true;
			PalaceIptManager(context.manager).pc.gotoRoom(roomId.data);
		}
	}
}