package org.openpalace.iptscrae
{
	public class IptTokenList extends IptCommand
	{
		internal var tokenList:Vector.<IptToken>;
		
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
		
		public function get tokensAvailable():Boolean {
			return Boolean(tokenList.length > 0);
		}
		
		public function pushToken(token:IptToken):void {
			tokenList.push(token);
		}
		
		public function popToken():IptToken {
			var token:IptToken;
			try {
				token = tokenList.pop();
			}
			catch (e:Error) {
				throw new IptError("Unable to pop next token: " + e.message);
			}
			
			return token;
		}
		
		public override function execute(context:IptExecutionContext):void {
			super.execute(context);
		}
		
		public override function clone():IptToken {
			return new IptTokenList(tokenList);
		}
	}
}