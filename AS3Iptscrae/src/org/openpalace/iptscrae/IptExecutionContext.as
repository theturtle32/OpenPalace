package org.openpalace.iptscrae
{
	import flash.utils.Dictionary;
	
	import org.openpalace.iptscrae.token.IntegerToken;

	public class IptExecutionContext
	{
		public var manager:IptManager;
		public var data:Object;
		public var stack:IptTokenStack;
		
		internal var variables:Dictionary;
		
		public function IptExecutionContext(manager:IptManager, stack:IptTokenStack = null)
		{
			data = {};
			this.manager = manager;
			if (stack == null) {
				stack = new IptTokenStack();
			}
			this.stack = stack;
			variables = new Dictionary();
		}
		
		public function getVariable(variableName:String):IptVariable {
			var variable:IptVariable = variables[variableName.toUpperCase()];
			if (variable == null) {
				variable = new IptVariable(variableName.toUpperCase(), new IntegerToken(0));
			}
			return variable;
		}
		
		public function clone():IptExecutionContext {
			var context:IptExecutionContext = new IptExecutionContext(manager, stack);
			context.variables = variables;
			return context;
		}
	}
}