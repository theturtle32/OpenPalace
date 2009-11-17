package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptTokenList;

	public class EXECCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var tokenList:IptTokenList = context.stack.popType(IptTokenList);
			tokenList.execute(context);
		}
	}
}