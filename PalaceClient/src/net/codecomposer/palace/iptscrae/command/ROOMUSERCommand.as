package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class ROOMUSERCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			var userIndex:IntegerToken = context.stack.popType(IntegerToken);
			context.stack.push(new IntegerToken(pc.getRoomUserIdByIndex(userIndex.data)));
		}
	}
}