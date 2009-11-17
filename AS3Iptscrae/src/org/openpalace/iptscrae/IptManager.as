package org.openpalace.iptscrae
{
	import flash.events.EventDispatcher;
	
	import org.openpalace.iptscrae.token.IptTokenList;
	
	public class IptManager extends EventDispatcher implements IIptManager
	{
		internal var contextStack:Vector.<IptExecutionContext>;
		public var parser:IptParser;
		public var globalVariableStore:IptVariableStore;
		
		public var executionContextClass:Class = IptExecutionContext;
		
		public function IptManager()
		{
			super();
			globalVariableStore = new IptVariableStore(new IptExecutionContext(this));
			contextStack = new Vector.<IptExecutionContext>();
			parser = new IptParser(this);
		}
		
		public function get currentContext():IptExecutionContext {
			if (contextStack.length > 0) {
				return contextStack[contextStack.length-1];
			}
			return null;
		}
			

		public function execute(script:String):void {
			var context:IptExecutionContext = new executionContextClass(this);
			executeWithContext(script, context);
		}
		
		public function executeWithContext(script:String, context:IptExecutionContext):void {
			var tokenList:IptTokenList = parser.tokenize(script);
			contextStack.push(context);
			tokenList.execute(context);
			contextStack.pop();
		}
		
	}
}