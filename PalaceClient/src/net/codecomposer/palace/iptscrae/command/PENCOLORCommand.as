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
			PalaceIptManager(context.manager).pc.setPenColor(r.data, g.data, b.data);
		}
	}
}