package org.openpalace.iptscrae.token
{
	import org.openpalace.iptscrae.IptConstants;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptToken;
	
	public class ArrayParseToken extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var array:ArrayToken = new ArrayToken();
			if (IptConstants.ENABLE_DEBUGGING) {
				context.manager.traceMessage("Building array:")
			}
			while (context.stack.depth > 0) {
				var token:IptToken = context.stack.pop();
				if (IptConstants.ENABLE_DEBUGGING) {
					context.manager.traceMessage(" - Found element: " + token.toString());
				}	
				if (token is ArrayMarkToken) {
					array.scriptCharacterOffset = token.scriptCharacterOffset;
					break;
				}
				else {
					array.data.unshift(token);
				}
			}
			context.stack.push(array);
			if (IptConstants.ENABLE_DEBUGGING) {
				context.manager.traceMessage("Array built.");
			}
		}
		
		override public function toString():String {
			return "[ArrayParseToken]";
		}
	}
}