package org.openpalace.iptscrae
{
	import flash.utils.Dictionary;
	
	import org.openpalace.iptscrae.token.IntegerToken;

	public class IptVariableStore
	{
		internal var variables:Dictionary;
		private var context:IptExecutionContext;
		
		public function IptVariableStore(context:IptExecutionContext)
		{
			variables = new Dictionary();
			this.context = context;
		}
		
		public function getVariable(variableName:String):IptVariable {
			var ucVariableName:String = variableName.toUpperCase();
			var variable:IptVariable = variables[ucVariableName];
			if (variable == null) {
				variable = new IptVariable(context, ucVariableName, new IntegerToken(0));
				if (context.isExternalVariable(ucVariableName)) {
					variable.external = true;
				}
				variables[ucVariableName] = variable;
			}
			return variable;
		}
	}
}