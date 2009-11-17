package org.openpalace.iptscrae
{
	import flash.net.getClassByAlias;
	import flash.utils.getQualifiedClassName;
	
	import org.openpalace.iptscrae.token.IptToken;

	public class IptTokenStack
	{
		internal var stack:Vector.<IptToken>;
		internal var stackDepth:uint = 0;
		
		public function IptTokenStack()
		{
			// Fixed size vector is much faster than dynamic one.
			stack = new Vector.<IptToken>(IptConstants.STACK_DEPTH);
		}

		public function get depth():uint {
			return stackDepth;
		}
		
		public function popType(requestedType:Class):* {
			var token:IptToken = pop();
			if (requestedType != IptVariable) {
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
			if ( stackDepth == 0 ) {
				throw new IptError("Cannot pop from an empty stack.");
			}
			try {
				// Cannot use push/pop on fixed size vector
				token = stack[--stackDepth];
				stack[stackDepth] = null;
			}
			catch (e:Error) {
				throw new IptError(e.message);
			}
			return token;
		}
		
		public function push(token:IptToken):void {
			if (stackDepth == IptConstants.STACK_DEPTH) {
				throw new IptError("Stack depth of " + IptConstants.STACK_DEPTH + " exceeded.");
			}
			try {
				// Cannot use push/pop on fixed size vector.
				stack[stackDepth++] = token;
			}
			catch (e:Error) {
				throw new IptError("Unable to push element onto the stack:" + e.message);
			}
		}
		
		public function pick(position:uint):IptToken {
			var token:IptToken;
			try {
				token = stack[position - 1 - position];
			}
			catch (e:Error) {
				throw new IptError("Unable to pick element " + position.toString() + " from the stack: " + e.message);
			}
			return token;
		}
		
		public function duplicate():void {
			try {
				stack.push(pick(0));
			}
			catch (e:Error) {
				throw new IptError("Unable to duplicate the top element on the stack: " + e.message);
			}
		}
	}
}