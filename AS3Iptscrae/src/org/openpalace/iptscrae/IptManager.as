package org.openpalace.iptscrae
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class IptManager extends EventDispatcher implements IIptManager
	{
		internal var contextStack:Vector.<IptExecutionContext>;
		public var parser:IptParser;
		
		public function IptManager()
		{
			super();
			contextStack = new Vector.<IptExecutionContext>();
			parser = new IptParser();
		}

		public function execute(script:String):void {
			var context:IptExecutionContext = new IptExecutionContext(this);
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