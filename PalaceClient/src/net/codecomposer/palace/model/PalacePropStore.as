/*
This file is part of OpenPalace.

OpenPalace is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

OpenPalace is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenPalace.  If not, see <http://www.gnu.org/licenses/>.
*/

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