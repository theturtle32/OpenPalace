package net.codecomposer.palace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptUtil;
	
	public class UnsupportedCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			context.stack.pop();
			context.manager.traceMessage("Unsupported Iptscrae Command");
		}
	}
}