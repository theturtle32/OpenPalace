package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class NETGOTOCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			PalaceIptManager(context.manager).pc.gotoURL(context.stack.popType(StringToken));
		}
	}
}