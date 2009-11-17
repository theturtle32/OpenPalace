package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.token.IptToken;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.Runnable;

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