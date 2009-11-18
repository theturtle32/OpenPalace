package org.openpalace.iptscrae
{
	import flash.events.EventDispatcher;

	[Event(name="traceEvent", type="org.openpalace.iptscrae.IptEngineEvent")]
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
		
		public function traceMessage(message:String):void {
			var event:IptEngineEvent = new IptEngineEvent(IptEngineEvent.TRACE_MESSAGE);
			event.message = message;
			dispatchEvent(event);
		}
		
		public function handleAlarm(alarm:IptAlarm):void {
			var context:IptExecutionContext = new executionContextClass(this);
			executeTokenListWithContext(alarm.tokenList, context);
		}

		public function execute(script:String):void {
			var context:IptExecutionContext = new executionContextClass(this);
			executeWithContext(script, context);
		}
		
		public function executeTokenListWithContext(tokenList:IptTokenList, context:IptExecutionContext):void {
			contextStack.push(context);
			try {
				tokenList.execute(context);
			}
			catch(e:IptError) {
				outputError(tokenList.sourceScript, e);
			}
			contextStack.pop();	
		}
		
		public function executeWithContext(script:String, context:IptExecutionContext):void {
			contextStack.push(context);
			try {
				var tokenList:IptTokenList = parser.tokenize(script);
				tokenList.execute(context);
			}
			catch(e:IptError) {
				outputError(script, e, tokenList.characterOffsetCompensation);
			}
			contextStack.pop();
		}
		
		private function outputError(script:String, e:IptError, characterOffsetCompensation:int = 0):void {
			var output:String = e.message;
			if (e.characterOffset != -1) {
				var offset:int = e.characterOffset - characterOffsetCompensation;
				output = "At character " + offset + ":\n" + output +
					highlightSource(script, offset);
			}
			trace(output);
			traceMessage(output);
		}
		
		public function highlightSource(script:String, characterOffset:int, contextCharacters:int = 30):String {
			if (characterOffset != -1) {
				script = script.replace(/[\r\n]/g, " ");
				
				var charsAfter:int = script.length - characterOffset;
				var charsBefore:int = script.length - charsAfter;
				var output:String = "\n";
				
				output += script.slice(
					characterOffset - Math.min(charsBefore, contextCharacters),
					characterOffset + Math.min(charsAfter, contextCharacters)
				);
				
				output += "\n";
				
				var pointerPadding:int = Math.min(charsBefore, contextCharacters);
				var pointer:String = "";
				for (var i:int = 0; i < pointerPadding; i++) {
					pointer += " ";
				}
				pointer += "^";
				
				output += pointer;
				return output;
			}
			return "";
		}
		
	}
}