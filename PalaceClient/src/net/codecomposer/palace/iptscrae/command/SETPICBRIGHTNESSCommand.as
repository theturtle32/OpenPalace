package net.codecomposer.palace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class SETPICBRIGHTNESSCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var spotId:IntegerToken = context.stack.popType(IntegerToken);
			var spotState:IntegerToken = context.stack.popType(IntegerToken);
			var brightness:IntegerToken = context.stack.popType(IntegerToken);
		}			
	}
}