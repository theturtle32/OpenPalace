package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class LINECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var y2:IntegerToken = context.stack.popType(IntegerToken);
			var x2:IntegerToken = context.stack.popType(IntegerToken);
			var y1:IntegerToken = context.stack.popType(IntegerToken);
			var x1:IntegerToken = context.stack.popType(IntegerToken);
			PalaceIptManager(context.manager).pc.drawLineAbs(x1.data, y1.data, x2.data, y2.data);
		}
	}
}