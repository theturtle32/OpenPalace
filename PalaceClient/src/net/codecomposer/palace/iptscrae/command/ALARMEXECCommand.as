package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceIptExecutionContext;
	
	import org.openpalace.iptscrae.IptAlarm;
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptTokenList;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class ALARMEXECCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var delayTicks:IntegerToken = context.stack.popType(IntegerToken);
			var tokenList:IptTokenList = context.stack.popType(IptTokenList);
			var newContext:PalaceIptExecutionContext = new PalaceIptExecutionContext(context.manager);
			newContext.hotspotId = PalaceIptExecutionContext(context).hotspotId;
			var alarm:IptAlarm = new IptAlarm(tokenList, context.manager, delayTicks.data, newContext);
			context.manager.addAlarm(alarm);
		}
	}
}
