package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.IptTokenList;

	public class WHILECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var conditionTokenList:IptTokenList = context.stack.popType(IptTokenList);
			var executeTokenList:IptTokenList = context.stack.popType(IptTokenList);
			while (true) {
				conditionTokenList.execute(context);
				var conditionResult:IptToken = context.stack.pop();
				if (conditionResult.toBoolean()) {
					executeTokenList.execute(context);
				}
			}
		}
	}
}