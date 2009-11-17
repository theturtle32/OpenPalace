package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IptToken;
	import org.openpalace.iptscrae.token.IptTokenList;

	public class WHILECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var conditionTokenList:IptTokenList = context.stack.popType(IptTokenList);
			var executeTokenList:IptTokenList = context.stack.popType(IptTokenList);
			while (true)
			{
				conditionTokenList.execute(context);
				if (context.returnRequested || context.exitRequested) {
					return;
				}
				try {
					var conditionResult:IptToken = context.stack.pop();
				}
				catch(e:Error) {
					throw new IptError("Unable to get result of condition clause from stack: " + e.message); 
				}
				if (!conditionResult.toBoolean() ||
					 context.breakRequested) {
					context.breakRequested = false;
					break;
				}
				executeTokenList.execute(context);
			}
		}
	}
}