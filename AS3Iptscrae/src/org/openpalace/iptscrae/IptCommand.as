package org.openpalace.iptscrae
{

	public class IptCommand extends IptToken implements Runnable
	{
		public function IptCommand(characterOffset:int = -1)
		{
			super(characterOffset);
		}
		
		public function execute(context:IptExecutionContext):void
		{
		}
		
		override public function clone():IptToken {
			throw new IptError("You cannot clone a command token.");
		}
		
		public function get running():Boolean {
			return false;
		}
		
		public function step():void {
		}
		
		public function end():void {
			
		}
	}
}