package org.openpalace.iptscrae
{
	import org.openpalace.iptscrae.command.IptCommand;
	import org.openpalace.iptscrae.token.IptToken;

	public class IptTokenList extends IptToken implements Runnable
	{
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
		
		public function reset():void {
			position = 0;
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
		
		public function addToken(token:IptToken):void {
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
			reset();
			while (tokensAvailable) {
				if (context.returnRequested) {
					context.returnRequested = false;
					break;
				}
				if (context.exitRequested) {
					break;
				}
				if (context.breakRequested) {
					break;
				}
				var token:IptToken = getNextToken();
				if (token is IptCommand) {
					try {
						IptCommand(token).execute(context);
					}
					catch (e:IptError) {
						throw new IptError(IptUtil.className(token) + ": " + e.message);
					}
				}
				else {
					context.stack.push(token);
				}
			}
		}
	}
}