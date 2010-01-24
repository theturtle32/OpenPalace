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
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.Timer;
	
	import net.codecomposer.palace.event.PropEvent;
	import net.codecomposer.palace.rpc.PalaceClient;
	import net.codecomposer.palace.rpc.webservice.OPWSConfirmPropsUpload;
	import net.codecomposer.palace.rpc.webservice.OPWSEvent;
	import net.codecomposer.palace.rpc.webservice.OPWSGetProps;
	import net.codecomposer.palace.rpc.webservice.OPWSNewProps;
	import net.codecomposer.util.MultiPartFormBuilder;
	
	public class PalacePropStore
	{
		private static var _instance:PalacePropStore = null;
		
		private var props:Object = new Object();
		private var propsArray:Array = [];
		
		private var client:PalaceClient = PalaceClient.getInstance();
		
		private var assetsToRequest:Array = [];
		private var assetRequestTimer:Timer = new Timer(50, 1);
		
		private var propsToUpload:Array = [];
		private var propsUploadtimer:Timer = new Timer(1000, 1);
		
		private var propsToConfirmUpload:Array = [];
		private var propsUploadConfirmTimer:Timer = new Timer(1000, 1);
		
		public function PalacePropStore()
		{
			if (_instance != null) {
				throw new Error("You can only instantiate one PropStore");
			}
			assetRequestTimer.addEventListener(TimerEvent.TIMER, handleAssetRequestTimer);
			propsUploadtimer.addEventListener(TimerEvent.TIMER, handlePropsUploadTimer);
			propsUploadConfirmTimer.addEventListener(TimerEvent.TIMER, handlePropsUploadConfirmTimer);
		}
		
		public static function getInstance():PalacePropStore {
			if (_instance == null) {
				_instance = new PalacePropStore();
			}
			return _instance;
		}
		
		public function injectAsset(asset:PalaceAsset):void {
			var prop:PalaceProp = getProp(asset.guid, asset.id, asset.crc);
			prop.asset = asset;
			prop.decodeProp();
		}
		
		public function getProp(guid:String, assetId:int=0, assetCrc:int=0):PalaceProp {
			var prop:PalaceProp;
			var propToDelete:PalaceProp;
			if (guid) {
				prop = props[guid];
				if (prop == null) {
					prop = props[guid] = props[assetId] = new PalaceProp(guid, assetId, assetCrc);
					propsArray.push(prop);
					if (propsArray.length > PalaceConfig.numberPropsToCacheInRAM) {
						propToDelete = propsArray.shift();
						props[propToDelete.asset.guid] = null;
						props[propToDelete.asset.id] = null;
					}
					requestAsset(prop);
				}
			}
			else {
				prop = props[assetId];
				if (prop == null) {
					prop = props[assetId] = new PalaceProp(guid, assetId, assetCrc);
					propsArray.push(prop);
					if (propsArray.length > PalaceConfig.numberPropsToCacheInRAM) {
						propToDelete = propsArray.shift();
						props[propToDelete.asset.guid] = null;
						props[propToDelete.asset.id] = null;
					}
					requestAsset(prop);	
				}
			}
			return prop;
		}
		
		public function requestAsset(prop:PalaceProp):void {
			prop.addEventListener(PropEvent.PROP_DECODED, handlePropDecoded);
			assetsToRequest.push(prop);
			assetRequestTimer.reset();
			assetRequestTimer.start();
		}
		
		private function handlePropDecoded(event:PropEvent):void {
			// Need to send the prop to the web service
			propsToUpload.push(event.prop);
			propsUploadtimer.reset();
			propsUploadtimer.start();
		}
		
		private function handlePropsUploadTimer(event:TimerEvent):void {
			var rpc:OPWSNewProps = new OPWSNewProps();
			rpc.addEventListener(OPWSEvent.RESULT_EVENT, handleNewPropsResult);
			rpc.send(propsToUpload);
			propsToUpload = [];
		}
		
		private function confirmPropUpload(prop:PalaceProp):void {
			propsToConfirmUpload.push(prop);
			propsUploadConfirmTimer.reset();
			propsUploadConfirmTimer.start();
		}
		
		private function handlePropsUploadConfirmTimer(event:TimerEvent):void {
			var rpc:OPWSConfirmPropsUpload = new OPWSConfirmPropsUpload();
			rpc.addEventListener(OPWSEvent.RESULT_EVENT, handlePropsUploadConfirmResult);
			rpc.send(propsToConfirmUpload);
			propsToConfirmUpload = [];
		}
		
		private function handlePropsUploadConfirmResult(event:OPWSEvent):void {
//			trace("Props upload confirmed");
		}
		
		private function handleNewPropsResult(event:OPWSEvent):void {
			for each (var propDef:Object in event.result.props) {
				if ( propDef.success ) {
					var prop:PalaceProp = getProp(null, propDef.legacy_identifier.id, propDef.legacy_identifier.crc);
					prop.asset.guid = propDef.guid;
					prop.asset.imageDataURL = propDef.image_data_url;
					props[prop.asset.guid] = prop;
					uploadPropToS3(propDef);
				}
			}
		}
		
		private function uploadPropToS3(propDef:Object):void {
			var s3:Object = propDef.s3_upload_data;
			var request:URLRequest = new URLRequest(propDef.s3_upload_data.upload_url);
			request.method = URLRequestMethod.POST;
			
			var prop:PalaceProp = getProp(null, propDef.legacy_identifier.id);
			prop.asset.guid = propDef.guid;
			
			var builder:MultiPartFormBuilder = new MultiPartFormBuilder({
				success_action_status: 201,
				acl: s3.acl,
				key: s3.key,
				"Content-Type": s3.content_type,
				AWSAccessKeyId: s3.aws_access_key_id,
				Policy: s3.policy,
				Signature: s3.signature,
				Expires: s3.expires,
				file: prop.bitmap
			});
			builder.useBase64 = false;
			request.data = builder.data;
			request.contentType = builder.contentType;
			
//			trace("Uploading prop id " + prop.asset.id + " - guid " + prop.asset.guid + " - to Amazon S3");
			var guid:String = prop.asset.guid;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				var prop:PalaceProp = getProp(guid);
				confirmPropUpload(prop);
//				trace("Upload complete for prop guid: " + prop.asset.guid)
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
				trace("IO Error while uploading prop guid " + prop.asset.guid);
			});
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void {
				trace("Security error while uploading prop guid " + prop.asset.guid);
			});
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.load(request);
		}
		
		private function handleAssetRequestTimer(event:TimerEvent):void {
			var rpc:OPWSGetProps = new OPWSGetProps();
			rpc.addEventListener(OPWSEvent.RESULT_EVENT, handleGetPropsResult);
			rpc.addEventListener(OPWSEvent.FAULT_EVENT, handleGetPropsFault);
			rpc.send(assetsToRequest);
			assetsToRequest = [];
		}
		
		private function handleGetPropsResult(event:OPWSEvent):void {
			for each (var response:Object in event.result['props'] as Array) {
				if (!response['success']) {
//					trace("Unable to get prop " + response['legacy_identifier']['id'] + " from web service, downloading from palace server.");
					client.requestAsset(AssetManager.ASSET_TYPE_PROP,
						response['legacy_identifier']['id'],
						response['legacy_identifier']['crc']
					);
				}
				else if (response['legacy_identifier']) {
					var prop:PalaceProp = getProp(null, response['legacy_identifier']['id'], response['legacy_identifier']['crc']);
					if (response['status'] && !response['status']['ready']) {
//						trace("Web service knows about the prop but it's not ready.  Trying again.");
						requestAsset(prop);
					}
					else {
//						trace("Got prop " + response['legacy_identifier']['id'] + " - " + response['guid'] + " from web service.");
						var flags:Object = response['flags'];
						prop.width = response['size']['width'];
						prop.height = response['size']['height'];
						prop.horizontalOffset = response['offsets']['x'];
						prop.verticalOffset = response['offsets']['y'];
						prop.head = flags['head'];
						prop.ghost = flags['ghost'];
						prop.rare = flags['rare'];
						prop.animate = flags['animate'];
						prop.palindrome = flags['palindrome'];
						prop.bounce = flags['bounce'];
						prop.asset.imageDataURL = response['image_data_url'];
						prop.asset.name = response['name'];
						prop.loadBitmapFromURL();
					}
				}
			} 	
		}
		
		private function handleGetPropsFault(event:OPWSEvent):void {
//			trace("There was a problem getting props from the webservice.");
		}
		
		public function loadImage(prop:PalaceProp):void {
			requestAsset(prop);
		}
		
	}
}