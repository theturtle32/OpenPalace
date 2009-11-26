package org.openpalace.iptscrae
{
	import org.openpalace.iptscrae.token.IIptVariable;

	public class IptVariable extends IptToken implements IIptVariable
	{
		private var _value:IptToken;
		private var _name:String;
		private var context:IptExecutionContext;
		private var _globalized:Boolean;
		private var _globalVariable:IptVariable;
		public var external:Boolean = false;
		
		public function IptVariable(context:IptExecutionContext, name:String, value:IptToken)
		{
			super();
			this.context = context;
			this._name = name;
			this.value = value;
		}
		
		public function get name():String { 
			return _name;
		}
		
		public function get value():IptToken {
			if (external) {
				return context.getExternalVariable(_name); 
			}
			else if (_globalized) {
				return _globalVariable.value;
			}
			return _value;
		}
		
		public function set value(newValue:IptToken):void {
			if (external) {
				context.setExternalVariable(name, newValue);
			}
			else if (_globalized) {
				_globalVariable.value = newValue;
			}
			else {
				_value = newValue;
			}
		}
		
		override public function clone():IptToken {
			var newVariable:IptVariable = new IptVariable(context, _name, _value);
			newVariable._globalized = _globalized;
			newVariable._globalVariable = _globalVariable;
			return newVariable;
		}
		
		public function globalize(globalVariable:IptVariable):void {
			_globalVariable = globalVariable;
			_globalized = true;
		}
		
		override public function dereference():IptToken {
			return value;
		}
		
		override public function toString():String {
			var string:String = "[IptVariable ";
			if (_globalized) {
				string += "(global) ";
			}
			string += "\"" + name + "\" " + value.toString() + "]";
			return string;
		}
	}
}