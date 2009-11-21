package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptTokenList;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.IptCommand;

	public class IFELSECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var condition:IptToken = context.stack.pop().dereference();
			var falseClause:IptTokenList = context.stack.popType(IptTokenList);
			var trueClause:IptTokenList = context.stack.popType(IptTokenList);
			if (condition.toBoolean()) {
				trueClause.execute(context);
			}
			else {
				falseClause.execute(context);
			}
		}
	}
}