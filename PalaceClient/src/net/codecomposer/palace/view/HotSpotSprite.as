/*
This file is part of OpenPalace.

OpenPalace is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

OpenPalace is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenPalace.  If not, see <http://www.gnu.org/licenses/>.
*/

package net.codecomposer.palace.view
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.FlexSprite;
	
	import net.codecomposer.palace.model.PalaceHotspot;
	import net.codecomposer.palace.rpc.PalaceClient;

	public class HotSpotSprite extends FlexSprite
	{
		
		public var hotSpot:PalaceHotspot;
		public var client:PalaceClient = PalaceClient.getInstance();		
		
		public function HotSpotSprite(hotSpot:PalaceHotspot, highlightOnMouseOver:Boolean = false)
		{
			this.hotSpot = hotSpot;
			super();
			draw();
			addEventListener(MouseEvent.CLICK, handleHotSpotClick);
			if (highlightOnMouseOver) {
				addEventListener(MouseEvent.ROLL_OVER, handleMouseOver);
				addEventListener(MouseEvent.ROLL_OUT, handleMouseOut);
			}
		}
		
		public function draw():void {
			alpha = 0;
			graphics.clear();
			var points:Array = hotSpot.polygon;
			var firstPoint:Point = Point(points[0]);
			graphics.lineStyle(1, 0);
			graphics.beginFill(0x333333, 0.5);
			graphics.moveTo(firstPoint.x, firstPoint.y);
			for (var i:int = 1; i < points.length; i++) {
				var point:Point = Point(points[i]);
				graphics.lineTo(point.x, point.y);
			}
			graphics.lineTo(firstPoint.x, firstPoint.y);
			graphics.endFill();
			if (hotSpot.type == PalaceHotspot.TYPE_DOOR) {
				buttonMode = true;
				useHandCursor = true;
			}
		}
		
		private function handleHotSpotClick(event:MouseEvent):void {
			if (hotSpot.type == PalaceHotspot.TYPE_DOOR) {
				event.stopPropagation();
				client.gotoRoom(hotSpot.dest);
			}
			trace("Clicked hotspot - Destination: " + hotSpot.dest);
		}
		
		private function handleMouseOver(event:MouseEvent):void {
			alpha = 1;
		}
		
		private function handleMouseOut(event:MouseEvent):void {
			alpha = 0;
		}

	}
}