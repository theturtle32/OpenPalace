package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class SINECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var degrees:IntegerToken = context.stack.popType(IntegerToken);
			var radians:Number = degrees.data * Math.PI/180;
			context.stack.push(new IntegerToken(Math.round(Math.sin(radians) * 1000)));
		}
	}
}