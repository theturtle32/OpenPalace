package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.model.PalaceProp;
	import net.codecomposer.palace.model.PalacePropStore;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class PROPDIMENSIONSCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var propId:IntegerToken = context.stack.popType(IntegerToken);
			var prop:PalaceProp = PalacePropStore.getInstance().getProp(null, propId.data);
			context.stack.push(new IntegerToken(prop.width));
			context.stack.push(new IntegerToken(prop.height));
		}
	}
}