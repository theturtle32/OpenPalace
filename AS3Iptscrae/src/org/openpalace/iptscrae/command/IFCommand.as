package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptTokenList;
	import org.openpalace.iptscrae.token.IptToken;

	public class IFCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var condition:IptToken = context.stack.pop().dereference();
			var tokenList:IptTokenList = context.stack.popType(IptTokenList);
			if (condition.toBoolean()) {
				tokenList.execute(context);
			}
		}
	}
}