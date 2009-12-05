package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class PENCOLORCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var b:IntegerToken = context.stack.popType(IntegerToken);
			var g:IntegerToken = context.stack.popType(IntegerToken);
			var r:IntegerToken = context.stack.popType(IntegerToken);
			var red:int = r.data & 0xFF;
			var green:int = g.data & 0xFF;
			var blue:int = b.data & 0xFF;
			PalaceIptManager(context.manager).pc.setPenColor(red, green, blue);
		}
	}
}