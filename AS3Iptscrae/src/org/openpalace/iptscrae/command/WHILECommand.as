package org.openpalace.iptscrae.command
{
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptTokenList;
	import org.openpalace.iptscrae.IptToken;

	public class WHILECommand extends IptCommand
	{
		private var conditionTokenList:IptTokenList;
		private var executeTokenList:IptTokenList;
		private var _running:Boolean = false;
		public var context:IptExecutionContext;
		private var checkingCondition:Boolean = false;
		
		override public function get running():Boolean {
			return _running;
		}
		
		override public function end():void {
			_running = false;
		}
		
		override public function step():void {
			if (context.returnRequested || context.exitRequested) {
				end();
				return;
			}
			
			if (checkingCondition) {
				conditionTokenList.execute(context);
				checkingCondition = false;
			}
			else {
				try {
					var conditionResult:IptToken = context.stack.pop();
				}
				catch(e:Error) {
					throw new IptError("Unable to get result of condition clause from stack: " + e.message); 
				}
				if (!conditionResult.toBoolean() ||
					context.breakRequested)
				{
					context.breakRequested = false;
					end();
					return;
				}
				checkingCondition = true;
				executeTokenList.execute(context);
			}
		} 
		
		override public function execute(context:IptExecutionContext):void {
			this.context = context;
			context.manager.callStack.push(this);
			_running = true;
			checkingCondition = true;
			conditionTokenList = context.stack.popType(IptTokenList);
			executeTokenList = context.stack.popType(IptTokenList);
			step();
		}
	}
}