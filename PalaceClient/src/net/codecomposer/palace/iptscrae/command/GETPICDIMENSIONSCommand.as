package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	import spark.primitives.Rect;
	
	public class GETPICDIMENSIONSCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var spotId:IntegerToken = context.stack.popType(IntegerToken);
			var spotState:IntegerToken = context.stack.popType(IntegerToken);
			
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			var rect:Rect = pc.getPicDimensions(spotId.data, spotState.data);
			
			context.stack.push(new IntegerToken(rect.width));
			context.stack.push(new IntegerToken(rect.height));
		}
	}
}