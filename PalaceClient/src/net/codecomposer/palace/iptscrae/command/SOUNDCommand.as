package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class SOUNDCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var sound:StringToken = context.stack.popType(StringToken);
			PalaceIptManager(context.manager).pc.playSound(sound.data);
		}
	}
}