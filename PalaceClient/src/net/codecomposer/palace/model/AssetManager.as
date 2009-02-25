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