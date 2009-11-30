package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.IptCommand;

	public class TICKSCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var date:Date = new Date();
			context.stack.push(new IntegerToken(int(date.valueOf() / Number(17) % 0x4F1A00)));
		}
	}
}