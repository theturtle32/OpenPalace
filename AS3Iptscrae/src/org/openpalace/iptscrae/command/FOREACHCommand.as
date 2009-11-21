package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptTokenList;
	import org.openpalace.iptscrae.token.ArrayToken;
	import org.openpalace.iptscrae.IptToken;
	
	public class FOREACHCommand extends IptCommand
	{
		private var array:ArrayToken;
		private var currentItemIndex:uint;
		private var tokenList:IptTokenList;
		public var context:IptExecutionContext;
		private var _running:Boolean = false;
		
		override public function get running():Boolean {
			return _running;
		}
		
		override public function end():void {
			_running = false;
		}
		
		override public function step():void {
			if (context.returnRequested || context.exitRequested || context.breakRequested) {
				context.breakRequested = false;
				end();
				return;
			}
			if (currentItemIndex < array.data.length) {
				context.stack.push(IptToken(array.data[currentItemIndex]));
				tokenList.execute(context);
				currentItemIndex++;
			}
			else {
				end();
			}
		}
		
		override public function execute(context:IptExecutionContext):void {
			this.context = context;
			context.manager.callStack.push(this);
			_running = true;
			array = context.stack.popType(ArrayToken);
			tokenList = context.stack.popType(IptTokenList);
			currentItemIndex = 0;
			step();
		}
	}
}