package org.openpalace.iptscrae
{

	public class IptTokenStack
	{
		public var stack:Vector.<IptToken>;
		
		public function IptTokenStack()
		{
			// Fixed size vector is much faster than dynamic one.
			stack = new Vector.<IptToken>();
		}

		public function get depth():uint {
			return stack.length;
		}
		
		public function popType(requestedType:Class):* {
			var token:IptToken = pop();
			if (token is IptVariable && requestedType != IptVariable) {
				token = token.dereference();
			}
			if (token is requestedType) {
				return token;
			}
			else {
				throw new IptError("Expected " + IptUtil.className(requestedType) + " element.  Got " + IptUtil.className(token) + " element instead."); 
			}
		}
		
		public function pop():IptToken {
			var token:IptToken;
			if ( stack.length == 0 ) {
				throw new IptError("Cannot pop from an empty stack.");
			}
			try {
				// Cannot use push/pop on fixed size vector
				token = stack.pop();
			}
			catch (e:Error) {
				throw new IptError(e.message);
			}
			return token;
		}
		
		public function push(token:IptToken):void {
			if (stack.length == IptConstants.STACK_DEPTH) {
				throw new IptError("Stack depth of " + IptConstants.STACK_DEPTH + " exceeded.");
			}
			try {
				// Cannot use push/pop on fixed size vector.
				stack.push(token);
			}
			catch (e:Error) {
				throw new IptError("Unable to push element onto the stack:" + e.message);
			}
		}
		
		public function pick(position:uint):IptToken {
			if (position > stack.length-1) {
				throw new IptError("You requested element #" + position + " from the top of the stack, but there are only " + depth + " element(s) available.");
			}
			var token:IptToken;
			try {
				token = stack[stack.length - 1 - position];
			}
			catch (e:Error) {
				throw new IptError("Unable to pick element " + position.toString() + " from the stack: " + e.message);
			}
			return token;
		}
		
		public function duplicate():void {
			try {
				push(pick(0));
			}
			catch (e:Error) {
				throw new IptError(e.message);
			}
		}
	}
}