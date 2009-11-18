package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;

	public class OVERCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			context.stack.push(context.stack.pick(1));
		}
	}
}