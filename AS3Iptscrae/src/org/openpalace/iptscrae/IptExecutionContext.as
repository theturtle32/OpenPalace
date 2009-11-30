package org.openpalace.iptscrae
{

	public class IptExecutionContext
	{
		public var manager:IptManager;
		public var data:Object;
		public var stack:IptTokenStack;
		public var variableStore:IptVariableStore;
		
		// Provide a means for handling loop exiting
		public var breakRequested:Boolean = false;
		public var returnRequested:Boolean = false;
		public var exitRequested:Boolean = false;
		
		public function resetExecutionControls():void {
			breakRequested = returnRequested = exitRequested = false;
		}
		
		public function IptExecutionContext(manager:IptManager, stack:IptTokenStack = null, variableStore:IptVariableStore = null)
		{
			if (stack == null) {
				stack = new IptTokenStack();
			}
			if (variableStore == null) {
				variableStore = new IptVariableStore(this);
			}
			
			data = {};
			this.manager = manager;
			this.stack = stack;
			this.variableStore = variableStore;
		}
		
		public function isExternalVariable(name:String):Boolean {
			return false;
		}
		
		public function setExternalVariable(name:String, value:IptToken):void {
			
		}
		
		public function getExternalVariable(name:String):IptToken {
			return new IptToken();
		}
		
		public function clone():IptExecutionContext {
			var context:IptExecutionContext = new IptExecutionContext(manager, stack, variableStore);
			return context;
		}
	}
}