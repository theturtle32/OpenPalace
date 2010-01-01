package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class MOVELOOSEPROPCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var index:IntegerToken = context.stack.popType(IntegerToken);
			var y:IntegerToken = context.stack.popType(IntegerToken);
			var x:IntegerToken = context.stack.popType(IntegerToken);
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			pc.moveLooseProp(index.data, x.data, y.data);
		}
	}
}