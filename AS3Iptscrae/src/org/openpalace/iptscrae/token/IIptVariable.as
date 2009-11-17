package org.openpalace.iptscrae.token
{
	import org.openpalace.iptscrae.IptVariable;

	public interface IIptVariable
	{
		function globalize(globalVariable:IptVariable):void;
		function set value(value:IptToken):void;
		function get value():IptToken;
	}
}