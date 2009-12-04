package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	
	public class PENFRONTCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			PalaceIptManager(context.manager).pc.paintFrontLayer();
		}
	}
}