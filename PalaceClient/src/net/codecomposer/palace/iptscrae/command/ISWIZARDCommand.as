package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class ISWIZARDCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var isWizard:Boolean = PalaceIptManager(context.manager).pc.isWizard();
			context.stack.push(new IntegerToken(isWizard ? 1 : 0));
		}
	}
}