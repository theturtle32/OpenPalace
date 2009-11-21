package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptExecutionContext;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class MECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			context.stack.push(new IntegerToken(PalaceIptExecutionContext(context).hotspotId));
		}
	}
}