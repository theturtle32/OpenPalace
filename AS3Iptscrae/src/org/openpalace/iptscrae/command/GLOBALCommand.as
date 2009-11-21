package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptVariable;
	import org.openpalace.iptscrae.IptCommand;

	public class GLOBALCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var variable:IptVariable = context.stack.popType(IptVariable);
			var globalVariable:IptVariable = context.manager.globalVariableStore.getVariable(variable.name);
			variable.globalize(globalVariable);
		}
	}
}