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
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.setTimeout;
	
	import mx.core.FlexSprite;
	
	import net.codecomposer.palace.event.HotspotEvent;
	import net.codecomposer.palace.iptscrae.IptEventHandler;
	import net.codecomposer.palace.model.PalaceConfig;
	import net.codecomposer.palace.model.PalaceHotspot;
	import net.codecomposer.palace.rpc.PalaceClient;

	public class HotSpotSprite extends FlexSprite
	{
		
		public var hotSpot:PalaceHotspot;
		public var client:PalaceClient = PalaceClient.getInstance();		

		private var mouseOver:Boolean = false;
		private var useHand:Boolean = false;
		
		public function HotSpotSprite(hotSpot:PalaceHotspot, highlightOnMouseOver:Boolean = false)
		{
			this.hotSpot = hotSpot;
			super();
			hotSpot.addEventListener(HotspotEvent.MOVED, handleHotspotMoved)
			x = hotSpot.location.x;
			y = hotSpot.location.y;
			draw();
			addEventListener(MouseEvent.MOUSE_DOWN, handleHotSpotMouseDown);
			addEventListener(MouseEvent.ROLL_OVER, handleIptscraeRollOver);
			addEventListener(MouseEvent.ROLL_OUT, handleIptscraeRollOut);
			if (hotSpot.hasEventHandler(IptEventHandler.TYPE_MOUSEMOVE)) {
				addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}
			if (hotSpot.dest != 0 &&
					(hotSpot.type == PalaceHotspot.TYPE_PASSAGE ||
					 hotSpot.type == PalaceHotspot.TYPE_LOCKABLE_DOOR ||
					 hotSpot.type == PalaceHotspot.TYPE_SHUTABLE_DOOR ||
					 hotSpot.type == PalaceHotspot.TYPE_BOLT)
				)
			{
				if (highlightOnMouseOver) {
					addEventListener(MouseEvent.ROLL_OVER, handleMouseOver);
					addEventListener(MouseEvent.ROLL_OUT, handleMouseOut);
				}
				useHand = true;
			}
//			trace("Hotspot " + hotSpot.name + " is type: " + hotSpot.type);
		}
		
		private function handleIptscraeRollOver(event:MouseEvent):void {
			client.palaceController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_ROLLOVER);
		}
		
		private function handleIptscraeRollOut(event:MouseEvent):void {
			client.palaceController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_ROLLOUT);
		}
		
		private var mousePos:Point = new Point(-1, -1);
		private var lastMousePos:Point = new Point(-1, -1);
		
		private function handleEnterFrame(event:Event):void {
			mousePos.x = client.currentRoom.roomView.mouseX;
			mousePos.y = client.currentRoom.roomView.mouseY;
			var globalPos:Point = client.currentRoom.roomView.localToGlobal(mousePos);
			if (hitTestPoint(globalPos.x, globalPos.y, true) && (mousePos.x != lastMousePos.x || mousePos.y != lastMousePos.y)) {
				lastMousePos = mousePos.clone();
				client.palaceController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_MOUSEMOVE);
			}
		}
		
		private function handleIptscraeMouseMove(event:MouseEvent):void {
			mousePos.x = event.localX;
			mousePos.y = event.localY;
			client.palaceController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_MOUSEMOVE);
		}
		
		private function handleHotspotMoved(event:HotspotEvent):void {
			x = hotSpot.location.x;
			y = hotSpot.location.y;
		}
		
		public function draw():void {
			graphics.clear();
			var points:Array = hotSpot.polygon;
			if (points.length < 3) {
//				trace("Not enough vertices to draw hotspot: " + points.length);
				return;
			}
			var firstPoint:Point = Point(points[0]);
			if (mouseOver || hotSpot.drawFrame) {
				graphics.lineStyle(1, 0x000000);
			}
			else {
				graphics.lineStyle(1, 0x000000, 0);
			}
			if (mouseOver) {
				graphics.beginFill(0x333333, 0.5);
			}
			else {
				graphics.beginFill(0x333333, 0.0);
			}
			graphics.moveTo(firstPoint.x, firstPoint.y);
			for (var i:int = 1; i < points.length; i++) {
				var point:Point = Point(points[i]);
				graphics.lineTo(point.x, point.y);
			}
			graphics.lineTo(firstPoint.x, firstPoint.y);
			graphics.endFill();
		}

		private function handleHotSpotMouseDown(event:MouseEvent):void {
//			trace("Clicked hotspot - id: " + hotSpot.id + " Destination: " + hotSpot.dest + " type: " + hotSpot.type + " state: " + hotSpot.state);
			
			if (hotSpot.dontMoveHere) {
				event.stopImmediatePropagation();
			}
			
			if (hotSpot.hasEventHandler(IptEventHandler.TYPE_SELECT)) {
				setTimeout(function():void {
					client.palaceController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_SELECT);
				}, 1);
				return;
			}
			
			switch (hotSpot.type) {
				case PalaceHotspot.TYPE_NORMAL:
					break;
				case PalaceHotspot.TYPE_PASSAGE:
					if (hotSpot.dest != 0) {
						client.gotoRoom(hotSpot.dest);
					}
					break;
				case PalaceHotspot.TYPE_LOCKABLE_DOOR:
					if (hotSpot.state == PalaceHotspot.STATE_UNLOCKED) {
						if (hotSpot.dest != 0) {
							client.gotoRoom(hotSpot.dest);
						}
					}
					else if (hotSpot.state == PalaceHotspot.STATE_LOCKED) {
						event.stopPropagation();
						client.currentRoom.roomMessage("Sorry, the door is locked.");
					}
					break;
				case PalaceHotspot.TYPE_SHUTABLE_DOOR:
					if (hotSpot.state == PalaceHotspot.STATE_UNLOCKED) {
						if (hotSpot.dest != 0) {
							client.gotoRoom(hotSpot.dest);
						}
					}
					else if (hotSpot.state == PalaceHotspot.STATE_LOCKED) {
						event.stopPropagation();
						client.currentRoom.roomMessage("Sorry, the door is closed.");
					}
					break;
				case PalaceHotspot.TYPE_NAVAREA:
//					trace("You clicked a nav area");
					break;
				case PalaceHotspot.TYPE_BOLT:
					var doorToBolt:PalaceHotspot = client.currentRoom.hotSpotsById[hotSpot.dest];
					if (doorToBolt != null) {
						if (doorToBolt.state == PalaceHotspot.STATE_UNLOCKED) {
							client.lockDoor(client.currentRoom.id, doorToBolt.id);
						}
						else {
							client.unlockDoor(client.currentRoom.id, doorToBolt.id);
						}
					}
					break;
			}
		}
		
		private function handleMouseOver(event:MouseEvent):void {
			if (useHand) {
				Mouse.cursor = MouseCursor.BUTTON;
			}
			if (PalaceConfig.highlightHotspotsOnMouseover) {
				mouseOver = true;
				draw();
			}
		}
		
		private function handleMouseOut(event:MouseEvent):void {
			if (useHand) {
				Mouse.cursor = MouseCursor.ARROW;
			}
			if (PalaceConfig.highlightHotspotsOnMouseover) {
				mouseOver = false;
				draw();
			}
		}

	}
}