package net.codecomposer.palace.model
{
	public class AssetManager
	{
		private static var _instance:AssetManager = null
		
		public static const ASSET_TYPE_PROP:int = 0x50726F70;
		
		public function AssetManager()
		{
			if (_instance != null) {
				throw new Error("You can only instantiate one AssetManager.");
			}
		}
		
		public static function getInstance():AssetManager {
			if (_instance == null) {
				_instance = new AssetManager();
			}
			return _instance;
		}
		
		public function addAsset(assetType:int, assetId:int, assetCrc:int):void {
			
		}
	}
}