package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class LOOSEPROPCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var propId:IntegerToken = context.stack.popType(IntegerToken);
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			var propIndex:int = pc.getLoosePropIndexById(propId.data);
			context.stack.push(new IntegerToken(propIndex));
		}
	}
}