package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class DIMROOMCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var dimLevel:IntegerToken = context.stack.popType(IntegerToken);
			PalaceIptManager(context.manager).pc.dimRoom(dimLevel.data);
		}
	}
}