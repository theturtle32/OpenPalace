package net.codecomposer.palace.iptscrae
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptManager;
	import org.openpalace.iptscrae.IptTokenStack;
	import org.openpalace.iptscrae.IptVariableStore;
	
	public class PalaceIptExecutionContext extends IptExecutionContext
	{
		public var hotspotId:int = 0;
		
		public function PalaceIptExecutionContext(manager:IptManager, stack:IptTokenStack=null, variableStore:IptVariableStore=null)
		{
			super(manager, stack, variableStore);
		}
		
	}
}