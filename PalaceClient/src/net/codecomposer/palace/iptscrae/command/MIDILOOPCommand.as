package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class MIDILOOPCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var name:StringToken = context.stack.popType(StringToken);
			var loopCount:IntegerToken = context.stack.popType(IntegerToken);
			PalaceIptManager(context.manager).pc.midiLoop(loopCount.data, name.data);
		}
	}
}