package
{
	import net.codecomposer.palace.iptscrae.TestPalaceController;
	
	import org.openpalace.iptscrae.IptManager;
	
	public class TestIptscraeManager extends IptManager
	{
		public var palaceController:TestPalaceController
		
		public function TestIptscraeManager()
		{
			super();
			palaceController = new TestPalaceController();
		}
	}
}