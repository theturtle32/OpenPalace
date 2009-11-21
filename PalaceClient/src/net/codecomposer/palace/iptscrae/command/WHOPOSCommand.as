package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class WHOPOSCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			var userId:IntegerToken = context.stack.popType(IntegerToken);
			var x:int = pc.getPosX(userId.data);
			var y:int = pc.getPosY(userId.data);
			context.stack.push(new IntegerToken(x));
			context.stack.push(new IntegerToken(y));
		}
	}
}