package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;

	public class SETPICOPACITYCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var hotspotId:IntegerToken = context.stack.popType(IntegerToken);
			var hotspotState:IntegerToken = context.stack.popType(IntegerToken);
			var opacityValue:IntegerToken = context.stack.popType(IntegerToken);
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			var opacityFloat:Number = Number(opacityValue.data) / 100;
			pc.setPicOpacity(hotspotId.data, hotspotState.data, opacityFloat);
		}
	}
}