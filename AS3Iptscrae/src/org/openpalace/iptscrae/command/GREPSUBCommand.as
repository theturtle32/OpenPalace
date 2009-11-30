package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.StringToken;
	import org.openpalace.iptscrae.IptCommand;

	public class GREPSUBCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var sourceString:StringToken = context.stack.popType(StringToken);
			
			var matchdata:Array = context.manager.grepMatchData;
			var result:String = sourceString.data;
			
			if (matchdata) {
				for (var i:int = 0; i < matchdata.length; i++) {
					var regexp:RegExp = new RegExp("\\$" + i.toString(), "g");
					result = result.replace(regexp, matchdata[i]); 
				}
			}
			
			context.stack.push(new StringToken(result));
		}
	}
}