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
	
	import net.codecomposer.palace.event.HotspotEvent;
	import net.codecomposer.palace.model.PalaceHotspot;
	import net.codecomposer.palace.rpc.PalaceClient;
	import net.codecomposer.palace.iptscrae.IptEventHandler;

	public class HotSpotSprite extends FlexSprite
	{
		
		public var hotSpot:PalaceHotspot;
		public var client:PalaceClient = PalaceClient.getInstance();		

		private var mouseOver:Boolean = false;
		
		public function HotSpotSprite(hotSpot:PalaceHotspot, highlightOnMouseOver:Boolean = false)
		{
			this.hotSpot = hotSpot;
			super();
			hotSpot.addEventListener(HotspotEvent.MOVED, handleHotspotMoved)
			x = hotSpot.location.x;
			y = hotSpot.location.y;
			draw();
			addEventListener(MouseEvent.CLICK, handleHotSpotClick);
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
				buttonMode = true;
				useHandCursor = true;
			}
			trace("Hotspot " + hotSpot.name + " is type: " + hotSpot.type);
		}
		
		private function handleHotspotMoved(event:HotspotEvent):void {
			x = hotSpot.location.x;
			y = hotSpot.location.y;
		}
		
		public function draw():void {
			graphics.clear();
			var points:Array = hotSpot.polygon;
			if (points.length < 3) {
				trace("Not enough vertices to draw hotspot: " + points.length);
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
		
		private function handleHotSpotClick(event:MouseEvent):void {
			trace("Clicked hotspot - id: " + hotSpot.id + " Destination: " + hotSpot.dest + " type: " + hotSpot.type + " state: " + hotSpot.state);
			if (hotSpot.dontMoveHere) {
				event.stopImmediatePropagation();
			}
			
			client.palaceController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_SELECT);
			
			switch (hotSpot.type) {
				case PalaceHotspot.TYPE_NORMAL:
					//checkForPalaceLinksInScript();
					break;
				case PalaceHotspot.TYPE_PASSAGE:
					event.stopPropagation();
					//checkForPalaceLinksInScript();
					if (hotSpot.dest != 0) {
						client.gotoRoom(hotSpot.dest);
					}
					break;
				case PalaceHotspot.TYPE_LOCKABLE_DOOR:
					if (hotSpot.state == PalaceHotspot.STATE_UNLOCKED) {
						event.stopPropagation();
						if (hotSpot.dest != 0) {
							client.gotoRoom(hotSpot.dest);
						}
					}
					else if (hotSpot.state == PalaceHotspot.STATE_LOCKED) {
						client.currentRoom.roomMessage("Sorry, the door is locked.");
					}
					break;
				case PalaceHotspot.TYPE_SHUTABLE_DOOR:
					if (hotSpot.state == PalaceHotspot.STATE_UNLOCKED) {
						event.stopPropagation();
						if (hotSpot.dest != 0) {
							client.gotoRoom(hotSpot.dest);
						}
					}
					else if (hotSpot.state == PalaceHotspot.STATE_LOCKED) {
						client.currentRoom.roomMessage("Sorry, the door is closed.");
					}
					break;
				case PalaceHotspot.TYPE_NAVAREA:
					trace("You clicked a nav area");
					break;
				case PalaceHotspot.TYPE_BOLT:
					trace("You clicked a deadbolt");
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
		}//
		
		private function checkForPalaceLinksInScript():void {
			trace("Checking for palace links in script...");
			trace(hotSpot.scriptString);
			var matchParts:Array = hotSpot.scriptString.toLowerCase().match(/on select.*\{.*["']palace:\/\/(.+?):{0,1}([0-9]*)["'].*netgoto/ms); 
			if (matchParts && matchParts.length > 0) {
				var port:int = int(matchParts[2]);
				if (port < 1) { port = 9998; }
				trace("Taking you to host: " + matchParts[1] + " port " + port);
				client.connect(client.userName, matchParts[1], int(port));
			}
		}
		
		private function handleMouseOver(event:MouseEvent):void {
			mouseOver = true;
			draw();
		}
		
		private function handleMouseOut(event:MouseEvent):void {
			mouseOver = false;
			draw();
		}

	}
}