package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	
	import org.openpalace.registration.RegistrationCode;

	public class Preferences extends EventDispatcher
	{
		private var sharedObject:SharedObject;
		
		private static var _instance:Preferences;
		
		public static function getInstance():Preferences {
			if (!_instance) {
				_instance = new Preferences();
			}
			return _instance;
		}
		
		public function Preferences()
		{
			if (_instance) {
				throw new Error("You can only create one Preferences instance");
			}
			sharedObject = SharedObject.getLocal("OpenPalaceBrowserPreferences");
		}
		
		[Bindable(event="hostNameChanged")]
		public function set hostName(newValue:String):void {
			sharedObject.data.hostName = newValue;
			sharedObject.flush();
			dispatchEvent(new Event('hostNameChanged'));
		}
		public function get hostName():String {
			var returnValue:String = sharedObject.data.hostName;
			if (!returnValue) {
				sharedObject.data.hostName = returnValue = "openpalace.org";
				sharedObject.flush();
			}
			return returnValue;
		}
		
		[Bindable(event="portChanged")]
		public function set port(newValue:String):void {
			sharedObject.data.port = newValue;
			sharedObject.flush();
			dispatchEvent(new Event('portChanged'));
		}
		public function get port():String {
			var returnValue:String = sharedObject.data.port;
			if (!returnValue) {
				sharedObject.data.port = returnValue = "9998";
				sharedObject.flush();
			}
			return returnValue;
		}
		
		[Bindable(event="userNameChanged")]
		public function set userName(newValue:String):void {
			sharedObject.data.userName = newValue;
			sharedObject.flush();
			dispatchEvent(new Event('userNameChanged'));
		}
		public function get userName():String {
			var returnValue:String = sharedObject.data.userName;
			if (!returnValue) {
				sharedObject.data.userName = returnValue = "OpenPalace User";
				sharedObject.flush();
			}
			return returnValue;
		}
		
		[Bindable(event="regCodeChanged")]
		public function set regCode(newValue:String):void {
			sharedObject.data.regCode = newValue;
			sharedObject.flush();
			dispatchEvent(new Event('regCodeChanged'));
		}
		public function get regCode():String {
			var returnValue:String = sharedObject.data.regCode;
			if (!returnValue) {
				sharedObject.data.regCode = returnValue = "";
				sharedObject.flush();
			}
			return returnValue;
		}
		
		public function resetPuid():void {
			sharedObject.data.puid = null;
			sharedObject.flush();
		}
		
		[Bindable(event="puidChanged")]
		public function set puid(newValue:RegistrationCode):void {
			sharedObject.data.puid = {};
			sharedObject.data.puid.crc = newValue.crc;
			sharedObject.data.puid.counter = newValue.counter;
			sharedObject.flush();
			dispatchEvent(new Event('puidChanged'));
		}
		public function get puid():RegistrationCode {
			var puid:RegistrationCode = new RegistrationCode();
			if (sharedObject.data.puid && schemaVersion >= 1) {
				trace("Loaded saved puid.  CRC: " + sharedObject.data.puid.crc + " Counter: " + sharedObject.data.puid.counter);
				puid.crc = sharedObject.data.puid.crc;
				puid.counter = sharedObject.data.puid.counter;
			}
			else {
				if (schemaVersion < 1) {
					schemaVersion = 1;
				}
				puid = RegistrationCode.generatePuid();
				sharedObject.data.puid = {};
				sharedObject.data.puid.crc = puid.crc;
				sharedObject.data.puid.counter = puid.counter;
				trace("Generated new puid.  CRC: " + sharedObject.data.puid.crc + " Counter: " + sharedObject.data.puid.counter);
				sharedObject.flush();
			}
			return puid;
		}
		
		[Bindable(event="cyborgChanged")]
		public function set cyborg(newValue:String):void {
			sharedObject.data.cyborg = newValue;
			sharedObject.flush();
			dispatchEvent(new Event('cyborgChanged'));
		}
		public function get cyborg():String {
			var returnValue:String = sharedObject.data.cyborg;
			if (!returnValue) {
				sharedObject.data.cyborg = returnValue = "";
				sharedObject.flush();
			}
			return returnValue;
		}
		
		private function get schemaVersion():uint {
			return sharedObject.data.schemaVersion ? sharedObject.data.schemaVersion : 0;
		}
		private function set schemaVersion(newValue:uint):void {
			sharedObject.data.schemaVersion = newValue;
			sharedObject.flush();
		}
		
	}
}