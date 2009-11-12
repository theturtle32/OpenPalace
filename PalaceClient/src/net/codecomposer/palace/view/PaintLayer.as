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
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	
	import net.codecomposer.palace.record.PalaceDrawRecord;
	
	public class PaintLayer extends UIComponent
	{

		private var _dataProvider:ArrayCollection;
		
		[Bindable("dataProviderChange")]
		public function set dataProvider(newValue:ArrayCollection):void {
			if (_dataProvider !== newValue) {
				_dataProvider = newValue;
				_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChange);
				dispatchEvent(new Event("dataProviderChange"));
			}
		}
		
		public function get dataProvider():ArrayCollection {
			return _dataProvider;
		}
		
		private function handleCollectionChange(event:CollectionEvent):void {
			draw();
		}
		
		
		override public function PaintLayer()
		{
			super();
			this.mouseEnabled = false;
		}
		
		override protected function updateDisplayList(width:Number, height:Number):void {
			super.updateDisplayList(width, height);
			draw();
		}
		
		public function draw():void {
			var originX:int;
			var originY:int;
			var x:int;
			var y:int;
			graphics.clear();
			if (dataProvider == null) { return; }
			for (var i:int = 0; i < dataProvider.length; i ++) {
				var drawCommand:PalaceDrawRecord = PalaceDrawRecord(dataProvider.getItemAt(i));

				// We have to offset by half the width of the "brush" so that
				// the positioning of thicker lines matches the positioning of
				// the Palace32, which positions the top-left of its square
				// brush at the specified coordinates.
				originX = x = drawCommand.polygon[0].x + Math.ceil(drawCommand.penSize / 2);
				originY = y = drawCommand.polygon[0].y + Math.ceil(drawCommand.penSize / 2);

				if (drawCommand.isEllipse) {
				   graphics.lineStyle(drawCommand.penSize, drawCommand.lineColor, drawCommand.lineAlpha);
                   if (drawCommand.useFill) {
                       graphics.beginFill(drawCommand.fillColor, drawCommand.fillAlpha);
                   }
                   // since it uses the top left corner we need to correct that to center it.
                   originX = x = drawCommand.polygon[1].x / 2
                   originY = y = drawCommand.polygon[1].y / 2 

					// points x and y are reversed on ellipses...
                   graphics.drawEllipse(drawCommand.polygon[0].y - y,drawCommand.polygon[0].x - x,drawCommand.polygon[1].y,drawCommand.polygon[1].x);
                   if (drawCommand.useFill) {
                       graphics.endFill();
                   }
				}
				else if (drawCommand.polygon.length == 2 &&
						drawCommand.polygon[1].x == 0 &&
						drawCommand.polygon[1].y == 0) {
					// single point
					graphics.beginFill(drawCommand.lineColor, drawCommand.lineAlpha);
					graphics.lineStyle(drawCommand.penSize,drawCommand.lineColor,drawCommand.lineAlpha);
					graphics.drawCircle(x, y, Math.ceil(drawCommand.penSize/2));
					graphics.endFill();
				}
				else {
					// normal line
					
					if (drawCommand.useFill) {
						// With filled lines, we don't correct the offset so that we
						// can match the old buggy behavior, and drawings made by
						// people with other clients will render consistently on
						// OpenPalace
						originX = x = drawCommand.polygon[0].x;
						originY = y = drawCommand.polygon[0].y;

						graphics.beginFill(drawCommand.fillColor, drawCommand.fillAlpha);
						graphics.lineStyle(drawCommand.penSize, drawCommand.lineColor, drawCommand.lineAlpha);
					}
					else {
						graphics.lineStyle(drawCommand.penSize, drawCommand.lineColor, drawCommand.lineAlpha);
					}
					
					graphics.moveTo(originX, originY);
					
					for (var j:int = 1; j < drawCommand.polygon.length; j ++) {
						// each coordinate is relative to its predecessor
						x = x + drawCommand.polygon[j].x;
						y = y + drawCommand.polygon[j].y;
						graphics.lineTo(x, y);
					}
					
					if (drawCommand.useFill) {
						graphics.lineTo(originX, originY);
						graphics.endFill();
					}
				}
			}
		}
	}
}