package org.openpalace.iptscrae.token
{
	import org.openpalace.iptscrae.IptVariable;
	import org.openpalace.iptscrae.IptToken;

	public interface IIptVariable
	{
		function globalize(globalVariable:IptVariable):void;
		function set value(value:IptToken):void;
		function get value():IptToken;
	}
}