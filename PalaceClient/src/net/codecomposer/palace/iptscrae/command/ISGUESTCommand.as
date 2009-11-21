package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class ISGUESTCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var isGuest:Boolean = PalaceIptManager(context.manager).pc.isGuest();
			context.stack.push(new IntegerToken(isGuest ? 1 : 0));
		}
	}
}