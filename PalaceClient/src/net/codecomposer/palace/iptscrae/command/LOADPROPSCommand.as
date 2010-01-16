package net.codecomposer.palace.iptscrae.command
{
	import net.codecomposer.palace.model.PalacePropStore;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.token.ArrayToken;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class LOADPROPSCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var propIds:ArrayToken = context.stack.popType(ArrayToken);
			var propStore:PalacePropStore = PalacePropStore.getInstance();
			if (propIds.data.length > 500) {
				throw new IptError("You may only load up to 500 props at a time.");
			}
			for each (var propId:IptToken in propIds.data) {
				if (propId is IntegerToken) {
					propStore.getProp(null, IntegerToken(propId).data); // load prop but don't do anything with it.
				}
				else {
					throw new IptError("Only Prop IDs are allowed to be specified for LOADPROPS.");
				}
			}
		}
	}
}