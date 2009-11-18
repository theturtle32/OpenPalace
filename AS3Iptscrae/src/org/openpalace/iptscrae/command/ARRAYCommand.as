package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.ArrayToken;
	import org.openpalace.iptscrae.token.IntegerToken;

	public class ARRAYCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var itemCount:IntegerToken = context.stack.popType(IntegerToken);
			if (itemCount.data >= 0) {
				var array:ArrayToken = new ArrayToken();
				for (var i:int = 0; i < itemCount.data; i++) {
					array.data.push(new IntegerToken(0));
				}
				context.stack.push(array);
			}
			else {
				context.stack.push(new IntegerToken(0));
			}
		}
	}
}