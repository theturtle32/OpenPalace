package net.codecomposer.palace.model
{
	import flash.utils.setTimeout;
	
	import net.codecomposer.palace.rpc.PalaceClient;
	
	public class PalacePropStore
	{
		private static var _instance:PalacePropStore = null;
		
		private var props:Object = new Object();
		
		private var client:PalaceClient = PalaceClient.getInstance();
		
		public function PalacePropStore()
		{
			if (_instance != null) {
				throw new Error("You can only instantiate one PropStore");
			}
		}
		
		public static function getInstance():PalacePropStore {
			if (_instance == null) {
				_instance = new PalacePropStore();
			}
			return _instance;
		}
		
		public function injectAsset(asset:PalaceAsset):void {
			var prop:PalaceProp = getProp(asset.id, asset.crc);
			prop.asset = asset;
			prop.decodeProp();
		}
		
		public function getProp(assetId:int, assetCrc:int):PalaceProp {
			var prop:PalaceProp = props[assetId];
			if (prop == null) {
				 prop = props[assetId] = new PalaceProp(assetId, assetCrc);
				 client.requestAsset(AssetManager.ASSET_TYPE_PROP, assetId, assetCrc);
			}
			return prop;
		}
	}
}