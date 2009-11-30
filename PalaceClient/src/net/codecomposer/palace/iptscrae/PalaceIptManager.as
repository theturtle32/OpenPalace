package net.codecomposer.palace.iptscrae
{
	
	import org.openpalace.iptscrae.IptManager;
	
	public class PalaceIptManager extends IptManager
	{
		public var pc:PalaceController;
		
		public function PalaceIptManager(pc:PalaceController = null)
		{
			super();
			if (pc == null) {
				pc = new PalaceController();
			}
			this.pc = pc;
			executionContextClass = PalaceIptExecutionContext;
		}
		
	}
}