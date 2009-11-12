package
{
	import flash.display.Bitmap;

	[Bindable]
	public class NewPropDefinition
	{
		public var name:String = "OpenPalace Prop";
		public var width:uint = 44;
		public var height:uint = 44;
		public var offsetX:int = 0;
		public var offsetY:int = 0;
		public var head:Boolean = false;
		public var ghost:Boolean = false;
		public var palindrome:Boolean = false;
		public var bounce:Boolean = false;
		public var rare:Boolean = false;
		public var animate:Boolean = false;
		public var bitmap:Bitmap;
	}
}