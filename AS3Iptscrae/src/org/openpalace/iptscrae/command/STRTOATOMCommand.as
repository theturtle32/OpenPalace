package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptTokenList;
	import org.openpalace.iptscrae.token.StringToken;
	import org.openpalace.iptscrae.IptCommand;

	public class STRTOATOMCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var stringToken:StringToken = context.stack.popType(StringToken);
			var tokenList:IptTokenList = context.manager.parser.tokenize(stringToken.data, stringToken.scriptCharacterOffset + 1);
			context.stack.push(tokenList);
		}
	}
}