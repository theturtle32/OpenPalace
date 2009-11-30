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
		public var alarms:Vector.<IptAlarm> = new Vector.<IptAlarm>();
		public var parser:IptParser;
		public var globalVariableStore:IptVariableStore;
		public var grepMatchData:Array;
		public var currentScript:String;
		public var paused:Boolean = false;
		public var debugMode:Boolean = false;
		public var stepsPerTimeSlice:int = 800;
		public var stepThroughScript:Boolean = false;
		private var _running:Boolean = false;
		
		public var executionContextClass:Class = IptExecutionContext;
		
		public function IptManager()
		{
			super();
			globalVariableStore = new IptVariableStore(new IptExecutionContext(this));
			parser = new IptParser(this);
		}
		
		public function get running():Boolean {
			return _running;
		}
		
		public function traceMessage(message:String):void {
			var event:IptEngineEvent = new IptEngineEvent(IptEngineEvent.TRACE);
			event.message = message;
			dispatchEvent(event);
		}
		
		public function addAlarm(alarm:IptAlarm):void {
			alarms.push(alarm);
			alarm.addEventListener(IptEngineEvent.ALARM, handleAlarm);
			alarm.start();
		}
		
		public function removeAlarm(alarm:IptAlarm):void {
			alarm.stop();
			var index:int = alarms.indexOf(alarm);
			if (index != -1) {
				alarms.splice(index, 1);
			}
		}
		
		public function clearAlarms():void {
			for each (var alarm:IptAlarm in alarms) {
				alarm.stop();
			}
			alarms = new Vector.<IptAlarm>;
		}
		
		public function handleAlarm(event:IptEngineEvent):void {
			var alarm:IptAlarm = IptAlarm(event.target);
			if (alarms.indexOf(alarm) == -1) { return; }
			executeTokenListWithContext(alarm.tokenList, alarm.context);
			removeAlarm(alarm);
			start();
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
		
		public function get moreToExecute():Boolean {
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
			stepThroughScript = false;
			if (paused) {
				paused = false;
				dispatchEvent(new IptEngineEvent(IptEngineEvent.RESUME));
				run();
			}
		}

		private function finish():void {
			_running = false;
			if (alarms.length == 0) {
				dispatchEvent(new IptEngineEvent(IptEngineEvent.FINISH));
			}
		}
		
		public function abort():void {
			clearAlarms();
			clearCallStack();
			_running = false;
			dispatchEvent(new IptEngineEvent(IptEngineEvent.ABORT));
			dispatchEvent(new IptEngineEvent(IptEngineEvent.FINISH));
		}
		
		public function start():void {
			if (!_running) {
				run();
			}
			if (debugMode && stepThroughScript) {
				pause();
			}
		}
		
		public function run():void {
			_running = true;
			
			// Pseudo-threading.  Execute a group of commands and then yield
			// before scheduling the next group.
			for (var i:int = 0; i < stepsPerTimeSlice; i++) {
				if (moreToExecute && !paused) {
					step();
				}
				else {
					if (!moreToExecute) { 
						finish();
					}
					return;
				}
			}
			setTimeout(run, 1);
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
			var tokenList:IptTokenList;
			try {
				tokenList = parser.tokenize(script);
			}
			catch(e:IptError) {
				var error:IptError = new IptError("Parse Error: " + e.message, e.characterOffset);
				outputError(currentScript, error, 0);
				abort();
				return;
			}
			try {
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
		
		public function parseEventHandlers(script:String):Object {
			var handlers:Object = {};
			try {
				handlers = parser.parseEventHandlers(script);
			}
			catch(e:IptError) {
				outputError(script, e);
			}
			return handlers;
		}
		
		private function outputError(script:String, e:IptError, characterOffsetCompensation:int = 0):void {
			var sourceContext:String = "";
			var output:String = e.message;
			if (e.characterOffset != -1) {
				var offset:int = e.characterOffset - characterOffsetCompensation;
				if (currentRunnableItem) {
					if (currentRunnableItem is IptTokenList) {
						var tokenList:IptTokenList = IptTokenList(currentRunnableItem);
						var charOffset:int = tokenList.scriptCharacterOffset;
						var currentToken:IptToken = tokenList.getCurrentToken();
						if (currentToken) {
							charOffset = currentToken.scriptCharacterOffset;
						}
						sourceContext = highlightSource(tokenList.sourceScript, offset - tokenList.characterOffsetCompensation, 30);
					}
				}
				output = "At character " + offset + ":\n" + output + "\n" + sourceContext;
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
					return highlightSource(tokenList.sourceScript, charOffset - tokenList.characterOffsetCompensation, 30);
				}
			}
			return "";
		}
		
		public function highlightSource(script:String, characterOffset:int, contextCharacters:int = 30):String {
			if (characterOffset != -1) {
				script = script.replace(/[\r\n]/g, " ");
				
				var charsAfter:int = script.length - characterOffset;
				var charsBefore:int = script.length - charsAfter;
				var output:String = "";
				
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