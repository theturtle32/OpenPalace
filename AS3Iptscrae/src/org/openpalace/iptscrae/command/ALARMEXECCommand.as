package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptAlarm;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptTokenList;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.IptCommand;

	public class ALARMEXECCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var delayTicks:IntegerToken = context.stack.popType(IntegerToken);
			var tokenList:IptTokenList = context.stack.popType(IptTokenList);
			var alarm:IptAlarm = new IptAlarm(tokenList, context.manager, delayTicks.data);
			context.manager.addAlarm(alarm);
		}
	}
}