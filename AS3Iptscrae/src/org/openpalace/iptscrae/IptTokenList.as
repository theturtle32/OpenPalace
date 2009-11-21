package org.openpalace.iptscrae
{

	public class IptTokenList extends IptToken implements Runnable
	{
		public var sourceScript:String;
		public var characterOffsetCompensation:int = 0;
		protected var _running:Boolean = false;
		public var context:IptExecutionContext;
		internal var tokenList:Vector.<IptToken>;
		internal var position:uint = 0;
		
		
		public function IptTokenList(tokenList:Vector.<IptToken> = null)
		{
			super();
			if (tokenList == null) {
				this.tokenList = new Vector.<IptToken>();
			}
			else {
				this.tokenList = tokenList;
			}
		}
		
		public function set running(newValue:Boolean):void {
			_running = newValue;
		}
		
		public function get running():Boolean {
			return _running;
		}
		
		public function reset():void {
			position = 0;
			_running = true;
		}
		
		public function getCurrentToken():IptToken {
			if (position < tokenList.length) {
				return tokenList[position];
			}
			return null;
		}
		
		public function getNextToken():IptToken {
			if (position >= tokenList.length) {
				throw new IptError("Read past end of tokenlist.");
			}
			if (tokenList.length == 0) {
				throw new IptError("No tokens to read.");
			}
			
			var token:IptToken;
			try {
				token = tokenList[position++];
			}
			catch (e:Error) {
				throw new IptError("Unable to get token: " + e.message);
			}
			return token;
		}
		
		public function get tokensAvailable():Boolean {
			return Boolean(position < tokenList.length);
		}
		
		public function get length():uint {
			return tokenList.length;
		}
		
		public function addToken(token:IptToken, characterOffset:int = -1):void {
			token.scriptCharacterOffset = characterOffset;
			tokenList.push(token);
		}
		
		public function popToken():IptToken {
			var token:IptToken;
			try {
				token = tokenList.pop();
			}
			catch (e:Error) {
				throw new IptError("Unable to pop token: " + e.message);
			}
			
			return token;
		}
		
		public override function clone():IptToken {
			return new IptTokenList(tokenList);
		}

		public function execute(context:IptExecutionContext):void {
			this.context = context;
			reset();
			context.manager.callStack.push(this);
		}
		
		public function end():void {
			_running = false;
		}
		
		public function step():void {
			if (tokensAvailable) {
				if (context.returnRequested) {
					context.returnRequested = false;
					end();
					return;
				}
				if (context.exitRequested || context.breakRequested) {
					end();
					return;
				}
				
				// Process next token...
				var token:IptToken = getNextToken();
				if (token is IptTokenList) {
					context.stack.push(token);
				}
				else if (token is IptCommand) {
					try {
						IptCommand(token).execute(context);
					}
					catch (e:IptError) {
						
						var offsetToReport:int = (e.characterOffset == -1) ?
								token.scriptCharacterOffset :
								e.characterOffset;
						end();
						throw new IptError("  " + IptUtil.className(token) + ":\n" + e.message, offsetToReport);
					}
				}
				else {
					context.stack.push(token);
				}
				if (!tokensAvailable) {
					end();
				}
			}
			else {
				end();
			}
		}
		override public function toString():String {
			var string:String = "[IptTokenList {";
			var snippet:String = sourceScript.replace(/[\r\n]/g, " ");;
			if (snippet.length > 20) {
				snippet = snippet.substr(0, 20) + "...";
			}
			string += (snippet + "}]"); 
			return string;
		}
	}
}