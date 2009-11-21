package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class SETPOSCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var y:IntegerToken = context.stack.popType(IntegerToken);
			var x:IntegerToken = context.stack.popType(IntegerToken);
			PalaceIptManager(context.manager).pc.moveUserAbs(x.data, y.data);
		}
	}
}