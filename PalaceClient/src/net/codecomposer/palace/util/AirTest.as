package net.codecomposer.palace.util
{
	import flash.display.NativeWindow;
	
	public class AirTest
	{
		private static var _isAir:Boolean;
		private static var seeded:Boolean = false;
		
		public static function get isAir():Boolean {
			if (!seeded) {
				try {
					var a:Boolean = NativeWindow.supportsMenu;
					_isAir = true;
				}
				catch (e:Error) {
					_isAir = false;
				}
				seeded = true;				
			}
			return _isAir;
		}
	}
}