package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;

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
	}
}