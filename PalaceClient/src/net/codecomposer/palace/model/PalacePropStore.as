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
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import net.codecomposer.palace.event.PropEvent;
	import net.codecomposer.palace.rpc.PalaceClient;
	
	public class PalacePropStore
	{
		private static var _instance:PalacePropStore = null;
		
		private var props:Object = new Object();
		
		CONTEXT::desktop
		private var _propsDirectory:File;
		
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
		
		public function getProp(assetId:int, assetCrc:int=0):PalaceProp {
			var prop:PalaceProp = props[assetId];
			if (prop == null) {
				CONTEXT::desktop {
					// if we're an Air application, attempt to load from disk
					var bucketNumber:uint = uint(assetId) % 256;
					var dir:File = propsDirectory.resolvePath(String(bucketNumber));
					dir.createDirectory();				

					var propDescriptionFile:File = dir.resolvePath(uint(assetId) + "-" + uint(assetCrc) + ".prop");
					if (propDescriptionFile.exists) {
						var fileStream:FileStream = new FileStream();
						fileStream.open(propDescriptionFile, FileMode.READ);
						
						// Reconstitute prop from deserialized data
						prop = props[assetId] = PalaceProp.fromObject(fileStream.readObject());
						 
						fileStream.close();
					}
					else {
						// make a new prop if we don't have one on disk.
						prop = props[assetId] = new PalaceProp(assetId, assetCrc);
					}
				}
				CONTEXT::web {
					// otherwise we make a new prop					
					prop = props[assetId] = new PalaceProp(assetId, assetCrc);
				}
				
				prop.addEventListener(PropEvent.PROP_LOADED, handlePropLoaded);
				loadImage(prop);
			}
			return prop;
		}
		
		public function loadImage(prop:PalaceProp):void {
			CONTEXT::desktop {
				// try loading the image off disk
				if (!prop.loadImageFromCache()) {
					// if we fail, request it from the server
					requestAsset(prop);
				}
			}
			CONTEXT::web {
				// If we're not an Air application we don't have a prop cache.
				requestAsset(prop);
			}
		}
		
		public function requestAsset(prop:PalaceProp):void {
			client.requestAsset(AssetManager.ASSET_TYPE_PROP, prop.asset.id, prop.asset.crc);
		}
		
		CONTEXT::desktop
		private function get propsDirectory():File {
			if (_propsDirectory == null) {
				_propsDirectory = File.applicationStorageDirectory.resolvePath('prop_cache');
				_propsDirectory.createDirectory();
			}
			return _propsDirectory;
		}
		
		private function handlePropLoaded(event:PropEvent):void {
			CONTEXT::desktop {
				// If we're an air application, cache the prop data to disk.
				
				var bucketNumber:uint = uint(event.prop.asset.id) % 256;
				var dir:File = propsDirectory.resolvePath(String(bucketNumber));
				dir.createDirectory();				
				var file:File = dir.resolvePath(uint(event.prop.asset.id) + "-" + uint(event.prop.asset.crc) + ".prop");
				var fileStream:FileStream = new FileStream();
				
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeObject(event.prop);
				fileStream.close();
			}
		}
	}
}