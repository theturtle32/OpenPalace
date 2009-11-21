package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class HASPROPCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			var token:IptToken = context.stack.pop().dereference();
			if (token is IntegerToken) {
				context.stack.push(new IntegerToken(pc.hasPropById(IntegerToken(token).data) ? 1 : 0));
			}
			else if (token is StringToken) {
				context.stack.push(new IntegerToken(pc.hasPropByName(StringToken(token).data) ? 1 : 0));
			}
			else {
				context.stack.push(new IntegerToken(0));
			}
		}
	}
}