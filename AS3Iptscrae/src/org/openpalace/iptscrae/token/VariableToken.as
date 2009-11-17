package org.openpalace.iptscrae.token
{
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.command.IptCommand;

	public class VariableToken extends IptCommand
	{
		public var name:String;
		
		public function VariableToken(name:String) {
			this.name = name.toUpperCase();
		}
		
		/* When this token is encountered it will be executed, which will
		   Look up the variable in the variable store and push the real
		   variable onto the stack instead. */
		override public function execute(context:IptExecutionContext):void {
			context.stack.push(context.variableStore.getVariable(name));
		}
	}
}