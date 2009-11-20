package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IptToken;
	import org.openpalace.iptscrae.IptTokenList;
	import org.openpalace.iptscrae.token.ArrayToken;
	
	public class FOREACHCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var array:ArrayToken = context.stack.popType(ArrayToken);
			var tokenList:IptTokenList = context.stack.popType(IptTokenList);
			for each (var token:IptToken in array.data) {
				context.stack.push(token);
				tokenList.execute(context);
			}
		}
	}
}