package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class MOVECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			var yBy:IntegerToken = context.stack.popType(IntegerToken);
			var xBy:IntegerToken = context.stack.popType(IntegerToken);
			pc.moveUserRel(xBy.data, yBy.data);
		}
	}
}