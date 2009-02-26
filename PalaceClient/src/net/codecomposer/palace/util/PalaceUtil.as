package net.codecomposer.palace.util
{
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;
	
	public class PalaceUtil
	{
		
		public static function htmlUnescape(str:String):String {
		    return new XMLDocument(str).firstChild.nodeValue;
		}
		
		public static function htmlEscape(str:String):String {
		    return XML( new XMLNode( XMLNodeType.TEXT_NODE, str ) ).toXMLString();
		}

	}
}