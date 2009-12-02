package org.openpalace.iptscrae
{

	public interface IIptVariable
	{
		function globalize(globalVariable:IptVariable):void;
		function set value(value:IptToken):void;
		function get value():IptToken;
	}
}