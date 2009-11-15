package net.codecomposer.palace.script
{
	public class PalaceErrorHandler
	{
		public static const ERROR_STRINGS:Array = [
			"INFO",
			"WARNING",
			"ERROR",
			"FAILURE"
		];
		
		public static const LEVEL_INFO:int = 0;
		public static const LEVEL_WARNING:int = 1;
		public static const LEVEL_ERROR:int = 2;
		public static const LEVEL_FAILURE:int = 3;

		public function reportError(errorMessage:String, errorLevel:int):void {
			switch (errorLevel) {
				case LEVEL_INFO:
					handleInfo(errorMessage);
					break;
				case LEVEL_WARNING:
					handleWarning(errorMessage);
					break;
				case LEVEL_ERROR:
					handleError(errorMessage);
					break;
				case LEVEL_FAILURE:
					handleFailure(errorMessage);
					break;
				default:
					trace("Unhandled error level " + errorLevel + ": " + errorMessage);
					break;
			}
		}
		
		private function handleWarning(errorMessage:String):void {
			trace("Warning: " + errorMessage);
		}
		
		private function handleInfo(errorMessage:String):void {
			trace("Info: " + errorMessage);
		}
		
		private function handleError(errorMessage:String):void {
			trace("Error: " + errorMessage);
		}
		
		private function handleFailure(errorMessage:String):void {
			trace("Failure: " + errorMessage);
		}
	}
}