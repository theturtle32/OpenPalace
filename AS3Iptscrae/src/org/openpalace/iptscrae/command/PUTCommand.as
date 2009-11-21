package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.ArrayToken;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.IptCommand;

	public class PUTCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var index:IntegerToken = context.stack.popType(IntegerToken);
			var array:ArrayToken = context.stack.popType(ArrayToken);
			var data:IptToken = context.stack.pop();
			
			if (index.data >= 0 && index.data < array.data.length) {
				try {
					array.data[index.data] = data;
				}
				catch(e:Error) {
					throw new IptError("Unable to set element " + index.data + " in the array: " + e.message);
				}
			}
		}
	}
}