package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;

	public class GREPSTRCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var pattern:StringToken = context.stack.popType(StringToken);
			var stringToSearch:StringToken = context.stack.popType(StringToken);
			
			context.manager.grepMatchData = null;
			
			var grepPattern:RegExp;
			try
			{
				grepPattern = new RegExp(pattern.data);
			}
			catch(e:Error)
			{
				grepPattern = null;
				throw new IptError("Bad GREPSTR Pattern: " + pattern.data);
			}
			
			context.manager.grepMatchData = stringToSearch.data.match(grepPattern);
			context.stack.push(new IntegerToken( (context.manager.grepMatchData == null) ? 0 : 1));
		}
	}
}