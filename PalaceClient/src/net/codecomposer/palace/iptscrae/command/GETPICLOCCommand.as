package net.codecomposer.palace.iptscrae.command
{
	import flash.geom.Point;
	
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class GETPICLOCCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var hotspotId:IntegerToken = context.stack.popType(IntegerToken);
			var spotState:IntegerToken = context.stack.popType(IntegerToken);
			var point:Point = PalaceIptManager(context.manager).pc.getPicOffset(hotspotId.data, spotState.data);
			context.stack.push(new IntegerToken(point.x));
			context.stack.push(new IntegerToken(point.y));
		}
	}
}