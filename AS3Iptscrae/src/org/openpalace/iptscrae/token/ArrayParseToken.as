package org.openpalace.iptscrae.token
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.command.IptCommand;
	
	public class ArrayParseToken extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var array:ArrayToken = new ArrayToken();
			while (context.stack.depth > 0) {
				var token:IptToken = context.stack.pop();
				if (token is ArrayMarkToken) {
					array.scriptCharacterOffset = token.scriptCharacterOffset;
					break;
				}
				else {
					array.data.unshift(token);
				}
			}
			context.stack.push(array);
		}
	}
}