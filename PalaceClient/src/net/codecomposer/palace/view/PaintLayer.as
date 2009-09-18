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
	
	import net.codecomposer.palace.model.PalaceDrawRecord;
	
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
		}
		
		override protected function updateDisplayList(width:Number, height:Number):void {
			super.updateDisplayList(width, height);
			draw();
		}
		
		public function draw():void {
			graphics.clear();
			if (dataProvider == null) { return; }
			for (var i:int = 0; i < dataProvider.length; i ++) {
				 var drawCommand:PalaceDrawRecord = PalaceDrawRecord(dataProvider.getItemAt(i));

				var x:int = 0;
				var y:int = 0;
				
				if (drawCommand.useFill) {
					graphics.beginFill(drawCommand.pencolor, 1);
					graphics.lineStyle(0, drawCommand.pencolor, 1);
					x = drawCommand.polygon[0].x;
					y = drawCommand.polygon[0].y;
				}
				else {
					graphics.lineStyle(drawCommand.pensize, drawCommand.pencolor, 1);
					x = drawCommand.polygon[0].x + Math.ceil(drawCommand.pensize / 2);
					y = drawCommand.polygon[0].y + Math.ceil(drawCommand.pensize / 2);
				}
				
				
				graphics.moveTo(x-0.25, y-0.25);
				for (var j:int = 1; j < drawCommand.polygon.length; j ++) {
					x = x + drawCommand.polygon[j].x;
					y = y + drawCommand.polygon[j].y;
					graphics.lineTo(x, y);
				}
				
				if (drawCommand.useFill) {
					graphics.endFill();
				}
			}
		}
	}
}