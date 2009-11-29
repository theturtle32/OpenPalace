package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.IptTokenList;
	import org.openpalace.iptscrae.IptUtil;
	import org.openpalace.iptscrae.token.IntegerToken;

	public class EXECCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var tokenList:IptToken = context.stack.pop().dereference();
			
			// Exec fails silently if given a zero-valued integer input.
			if (tokenList is IntegerToken && IntegerToken(tokenList).data == 0) {
				return;
			}
			
			if (tokenList is IptTokenList) {
				IptTokenList(tokenList).execute(context);
			}
			else {
				throw new IptError("Expected an IptTokenList object.  Got a " + IptUtil.className(tokenList)); 
			}
		}
	}
}