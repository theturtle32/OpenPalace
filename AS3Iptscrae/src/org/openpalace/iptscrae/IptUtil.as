package org.openpalace.iptscrae
{
	import flash.utils.getQualifiedClassName;

	public class IptUtil
	{
		public static function className(o:Object):String {
			var fullClassName:String = getQualifiedClassName(o);
			return fullClassName.slice(fullClassName.lastIndexOf("::") + 2);
		}
	}
}