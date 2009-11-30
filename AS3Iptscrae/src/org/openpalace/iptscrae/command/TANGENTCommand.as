package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class TANGENTCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var degrees:IntegerToken = context.stack.popType(IntegerToken);
			var radians:Number = degrees.data * Math.PI/180;
			context.stack.push(new IntegerToken(Math.round(Math.tan(radians) * 1000)));
		}
	}
}