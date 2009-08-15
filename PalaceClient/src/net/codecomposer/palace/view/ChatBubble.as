package net.codecomposer.palace.view
{
	import flash.events.Event;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.primitives.supportClasses.GraphicElement;
	import spark.primitives.supportClasses.TextGraphicElement;

	[SkinState("bottomRight")]
	[SkinState("bottomLeft")]
	[SkinState("topRight")]
	[SkinState("topLeft")]
	
	
	public class ChatBubble extends SkinnableComponent
	{
		[SkinPart(required="true")]
		public var textElement:TextGraphicElement;
		
		[SkinPart(required="false")]
		public var backgroundElement:GraphicElement;
		
		private var _text:String;
			
		private var currentPosition:int = 0;
		private static const positions:Array = [
			"bottomRight",
			"bottomLeft",
			"topRight",
			"topLeft"
		];
		
		private var _tintColor:uint = 0xFFFFAA;
			
		[Bindable('tintColorChanged')]
		public function set tintColor(newValue:uint):void {
			_tintColor = newValue;
			if (skin && skin is ChatBubbleSkin)
				ChatBubbleSkin(skin).tintColor = _tintColor;
			dispatchEvent(new Event('tintColorChanged'));
		}
		
		public function get tintColor():uint {
			return _tintColor;
		}
		
		[Bindable(event="textChanged")]
		public function set text(newValue:String):void {
			_text = newValue;
			if (textElement && textElement.text != _text) {
				textElement.text = _text; 
			}
			dispatchEvent(new Event('textChanged'));
		}
		
		override protected function getCurrentSkinState():String {
			return positions[currentPosition];
		}
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			if (_text !== null && instance == textElement) {
				textElement.text = _text;
			}
			if ( instance == backgroundElement ) {
				ChatBubbleSkin(skin).tintColor = _tintColor;
			}
		}
		
		public function tryNextPosition():void {
			currentPosition = (currentPosition + 1) % 4;
			invalidateSkinState();
		}
		
		public function ChatBubble()
		{
			super();
		}
	}
}