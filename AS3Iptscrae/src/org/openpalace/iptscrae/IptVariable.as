package org.openpalace.iptscrae
{
	public class IptVariable extends IptToken implements IIptVariable
	{
		private var _value:IptToken;
		private var _name:String;
		
		public function IptVariable(name:String, value:IptToken)
		{
			super();
			this._name = name;
			this.value = value;
		}
		
		public function get name():String { 
			return _name;
		}
		
		public function get value():IptToken {
			return _value;
		}
		
		public function set value(newValue:IptToken):void {
			_value = newValue;
		}
	}
}