package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.iptscrae.PalaceController;
	import net.codecomposer.palace.iptscrae.PalaceIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.IptUtil;
	import org.openpalace.iptscrae.token.ArrayToken;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class SETPROPSCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var pc:PalaceController = PalaceIptManager(context.manager).pc;
			
			var props:ArrayToken = context.stack.popType(ArrayToken);
			var propIds:Array = [];
			
			for each (var prop:IptToken in props.data) {
				prop = prop.dereference();
				var propId:int = 0;
				if (prop is IntegerToken) {
					propId = IntegerToken(prop).data;
				}
				else if (prop is StringToken) {
					propId = pc.getPropIdByName(StringToken(prop).data);
				}
				else {
					throw new IptError("Unsupported data type " + IptUtil.className(prop) + ". " +
									   "Expected a StringToken (prop name) or an IntegerToken (prop id).");
				}
				propIds.push(propId);
			}
			pc.setProps(propIds);

		}
	}
}