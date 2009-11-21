package org.openpalace.iptscrae
{
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;

	[Event(name="trace", type="org.openpalace.iptscrae.IptEngineEvent")]
	[Event(name="pause", type="org.openpalace.iptscrae.IptEngineEvent")]
	[Event(name="resume", type="org.openpalace.iptscrae.IptEngineEvent")]
	[Event(name="abort", type="org.openpalace.iptscrae.IptEngineEvent")]
	[Event(name="start", type="org.openpalace.iptscrae.IptEngineEvent")]
	public class IptManager extends EventDispatcher implements IIptManager
	{
		public var callStack:Vector.<Runnable> = new Vector.<Runnable>();
		public var parser:IptParser;
		public var globalVariableStore:IptVariableStore;
		public var grepMatchData:Array;
		public var currentScript:String;
		public var paused:Boolean = false;
		public var debugMode:Boolean = false;
		public var stepsPerTimeSlice:int = 800;
		
		public var executionContextClass:Class = IptExecutionContext;
		
		public function IptManager()
		{
			super();
			globalVariableStore = new IptVariableStore(new IptExecutionContext(this));
			parser = new IptParser(this);
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
		
		public function clearCallStack():void {
			callStack = new Vector.<Runnable>();
		}

		public function get currentRunnableItem():Runnable {
			if (callStack.length > 0) {
				return callStack[callStack.length-1];
			}
			return null;
		}
		
		public function get running():Boolean {
			return Boolean(callStack.length > 0);
		}
		
		public function cleanupCurrentItem():void {
			var runnableItem:Runnable = currentRunnableItem;
			if (runnableItem && !runnableItem.running) {
				callStack.pop();
			}
		}
		
		public function step():void {
			var runnableItem:Runnable = currentRunnableItem;
			if (runnableItem) {
				if (runnableItem.running) {
					try {
						runnableItem.step();
					}
					catch(e:IptError) {
						var charOffset:int = 0;
						if (runnableItem is IptTokenList) {
							outputError(currentScript, e, charOffset);
							clearCallStack();
						}
					}
					cleanupCurrentItem();
				}
				else {
					callStack.pop();
				}
			}
		}

		public function pause():void {
			if (debugMode) {
				paused = true;
				dispatchEvent(new IptEngineEvent(IptEngineEvent.PAUSE));
			}
		}
		
		public function resume():void {
			paused = false;
			dispatchEvent(new IptEngineEvent(IptEngineEvent.RESUME));
		}
		
		public function abort():void {
			clearCallStack();
			dispatchEvent(new IptEngineEvent(IptEngineEvent.ABORT));
			dispatchEvent(new IptEngineEvent(IptEngineEvent.FINISH));
		}
		
		public function run():void {
			// Pseudo-threading.  Execute a group of commands and then yield
			// before scheduling the next group.
			for (var i:int = 0; i < stepsPerTimeSlice; i++) {
				if (running && !paused) {
					step();
				}
				else {
					if (!running) {
						finish();
					}
					return;
				}
			}
			setTimeout(run, 1);
		}
		
		private function finish():void {
			dispatchEvent(new IptEngineEvent(IptEngineEvent.FINISH));
		}
		
		public function execute(script:String):void {
			var context:IptExecutionContext = new executionContextClass(this);
			executeWithContext(script, context);
		}
		
		public function executeTokenListWithContext(tokenList:IptTokenList, context:IptExecutionContext):void {
			try {
				currentScript = tokenList.sourceScript;
				tokenList.execute(context);
				dispatchEvent(new IptEngineEvent(IptEngineEvent.START));
			}
			catch(e:IptError) {
				outputError(tokenList.sourceScript, e);
				abort();
			}
		}
		
		public function executeWithContext(script:String, context:IptExecutionContext):void {
			currentScript = script;
			try {
				var tokenList:IptTokenList = parser.tokenize(script);
				tokenList.execute(context);
				dispatchEvent(new IptEngineEvent(IptEngineEvent.START));
			}
			catch(e:IptError) {
				var charOffset:int = 0;
				if (tokenList) {
					charOffset = tokenList.characterOffsetCompensation;
				}
				outputError(currentScript, e, charOffset);
				abort();
			}
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
		
		public function get scriptContextDisplay():String {
			if (currentRunnableItem) {
				if (currentRunnableItem is IptTokenList) {
					var tokenList:IptTokenList = IptTokenList(currentRunnableItem);
					var charOffset:int = tokenList.scriptCharacterOffset;
					var currentToken:IptToken = tokenList.getCurrentToken();
					if (currentToken) {
						charOffset = currentToken.scriptCharacterOffset;
					}
					return highlightSource(currentScript, charOffset, 25);
				}
			}
			return "";
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