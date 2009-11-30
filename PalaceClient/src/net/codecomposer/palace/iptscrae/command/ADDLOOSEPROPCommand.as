package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class ADDLOOSEPROPCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			var y:IntegerToken = context.stack.popType(IntegerToken);
			var x:IntegerToken = context.stack.popType(IntegerToken);
			var id:int = 0;
			var propId:IptToken = context.stack.pop().dereference();
			if(propId is IntegerToken) {
				id = IntegerToken(propId).data;
			}
			else if(propId is StringToken) {
				id = pc.getPropIdByName(StringToken(propId).data);
			}
			if(id != 0) {
				pc.addLooseProp(id, x.data, y.data);
			}
		}
	}
}