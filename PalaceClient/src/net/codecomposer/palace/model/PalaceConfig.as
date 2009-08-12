package net.codecomposer.palace.model
{
	[Bindable]
	public class PalaceConfig
	{
		public function PalaceConfig()
		{
		}

		public static var webServiceURL:String = "http://www.openpalace.org/webservice";
		public static var numberPropsToCacheInRAM:int = 1000; 
		public static var URIEncodeImageNames:Boolean = true;
	}
}