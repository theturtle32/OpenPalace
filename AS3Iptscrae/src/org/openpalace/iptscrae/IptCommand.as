package org.openpalace.iptscrae
{
	public class IptCommand extends IptToken implements Runnable
	{
		public function IptCommand()
		{
		}
		
		public function execute(context:IptExecutionContext):void
		{
		}
		
		override public function clone():IptToken {
			throw new IptError("You cannot clone a command token.");
		}
	}
}