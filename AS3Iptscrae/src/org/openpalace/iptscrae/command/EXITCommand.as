package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;

	public class EXITCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			context.exitRequested = true;
		}
	}
}