package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.ArrayToken;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.IptToken;

	public class GETCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var index:IntegerToken = context.stack.popType(IntegerToken);
			var array:ArrayToken = context.stack.popType(ArrayToken);
			var element:IptToken;
			try {
				element = array.data[index.data];
			}
			catch (e:Error) {
				throw new IptError("Unable to get element " + index.data + " from the array: " + e.message);
			}
			context.stack.push(element);
		}
	}
}