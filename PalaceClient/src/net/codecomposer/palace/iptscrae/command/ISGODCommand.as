package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class ISGODCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var isGod:Boolean = PalaceIptManager(context.manager).pc.isGod();
			context.stack.push(new IntegerToken(isGod ? 1 : 0));
		}
	}
}