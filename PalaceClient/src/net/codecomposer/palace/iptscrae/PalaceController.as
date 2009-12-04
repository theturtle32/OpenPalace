package net.codecomposer.palace.iptscrae
{
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import net.codecomposer.palace.model.PalaceCurrentRoom;
	import net.codecomposer.palace.model.PalaceHotspot;
	import net.codecomposer.palace.model.PalaceLooseProp;
	import net.codecomposer.palace.model.PalaceProp;
	import net.codecomposer.palace.model.PalacePropStore;
	import net.codecomposer.palace.model.PalaceUser;
	import net.codecomposer.palace.record.PalaceDrawRecord;
	import net.codecomposer.palace.rpc.PalaceClient;
	import net.codecomposer.palace.util.DrawColorUtil;
	import net.codecomposer.palace.view.PalaceSoundPlayer;
	
	import org.openpalace.iptscrae.IptAlarm;
	import org.openpalace.iptscrae.IptEngineEvent;
	import org.openpalace.iptscrae.IptTokenList;

	public class PalaceController implements IPalaceController
	{
		[Bindable]
		public var scriptManager:PalaceIptManager;
		[Bindable]
		public var output:String;
		public var client:PalaceClient;
		
		// pen starts in the center of the old size viewport
		private var penPosition:Point = new Point(256,192);
		private var lineColor:uint = 0x00000000;
		private var lineSize:uint = 1;
		private var lineAlpha:Number = 1;
		private var fillColor:uint = 0x00000000;
		private var fillAlpha:Number = 1;
		private var useFill:Boolean = false;
		private var drawLayer:uint = PalaceDrawRecord.LAYER_BACK;
		
		public function PalaceController()
		{
			output = "";
			scriptManager = new PalaceIptManager(this);
			scriptManager.parser.removeCommand("ALARMEXEC");
			scriptManager.parser.addCommands(PalaceIptscraeCommands.commands);
			scriptManager.addEventListener(IptEngineEvent.TRACE, handleTrace);
		}
		
		private function handleTrace(event:IptEngineEvent):void {
			logResult(event.message);
		}
		
		public function logError(message:String):void {
			logResult(message);
		}
		
		private function logResult(value:String):void {
			output += value + "\n";
			client.currentRoom.logScript(value);
			trace(value);
		}
				
		public function triggerHotspotEvent(hotspot:PalaceHotspot, eventType:int):void {
			var tokenList:IptTokenList = hotspot.getEventHandler(eventType);
			if (tokenList) {
				var context:PalaceIptExecutionContext = new PalaceIptExecutionContext(scriptManager);
				context.hotspotId = hotspot.id;
				scriptManager.executeTokenListWithContext(tokenList, context);
				scriptManager.start();
			}
		}
		
		public function triggerHotspotEvents(eventType:int):void {
			for each (var hotspot:PalaceHotspot in client.currentRoom.hotSpots) {
				triggerHotspotEvent(hotspot, eventType);
			}
		}
		
		
		
		public function executeScript(script:String):void {
			if (scriptManager) {
				scriptManager.execute(script);
				scriptManager.start();
			}
		}
		
		public function gotoURL(url:String):void
		{
			var match:Array = url.match(/^palace:\/\/(.*)$/i);
			if (match && match.length > 0) {
				url = match[1];
			}
			
			var parts:Array = url.split(':');
			var hostName:String = parts[0];
			var port:Number = 9998;
			if ( parts[1] && String(parts[1]).length > 0 ) {
				port = uint(parts[1]);
			} 
			
			if (match) {
				trace("Taking you to host: " + hostName + " port " + port);
				client.connect(client.userName, hostName, port);
			}
			else {
				client.gotoURL(url);
			}
		}
		
		public function launchApp(app:String):void
		{
			logResult("launchApp: " + app);
		}
		
		public function getWhoChat():int
		{
			return client.whochat;
		}
		
		public function midiLoop(loopNbr:int, name:String):void
		{
			logResult("midiLoop loopNbr:" + loopNbr + " name: " + name);
		}
		
		public function midiPlay(name:String):void
		{
			logResult("midiPlay name: " + name);
		}
		
		public function selectHotSpot(spotId:int):void
		{
			var hotspot:PalaceHotspot = client.currentRoom.getHotspotById(spotId);
			if (hotspot) {
				triggerHotspotEvent(hotspot, IptEventHandler.TYPE_SELECT);
			}
		}
		
		public function getNumDoors():int
		{
			var spotCount:int = 0;
			for each (var hotspot:PalaceHotspot in client.currentRoom.hotSpots) {
				if (hotspot.isDoor) {
					spotCount ++;
				}
			}
			return spotCount;
		}
		
		public function isGuest():Boolean
		{
			return client.currentUser.isGuest;
		}
		
		public function dimRoom(dimLevel:int):void
		{
			client.currentRoom.dimRoom(dimLevel);
		}
		
		public function getSelfPosY():int
		{
			return client.currentUser.y;
		}
		
		public function getSelfPosX():int
		{
			return client.currentUser.x;
		}
		
		public function isWizard():Boolean
		{
			return (client.currentUser.isWizard || client.currentUser.isGod);
		}
		
		public function moveUserAbs(x:int, y:int):void
		{
			client.move(x, y);
		}
		
		public function getTopProp():int
		{
			if (client.currentUser.props && client.currentUser.props.length > 0) { 
				var prop:PalaceProp = PalaceProp(client.currentUser.props.getItemAt(client.currentUser.props.length-1));
				if (prop) {
					return prop.asset.id;
				}
			}
			return 0;
		}
		
		public function dropProp(x:int, y:int):void
		{
			if (client.currentUser.props && client.currentUser.props.length > 0) { 
				var prop:PalaceProp = PalaceProp(client.currentUser.props.getItemAt(client.currentUser.props.length-1));
				client.addLooseProp(prop.asset.id, 0, x, y);
				client.currentUser.removeProp(prop);
			}
		}
		
		public function doffProp():void
		{
			logResult("doffProp");
			if (client.currentUser.props && client.currentUser.props.length > 0) { 
				var prop:PalaceProp = PalaceProp(client.currentUser.props.getItemAt(client.currentUser.props.length-1));
				if (prop) {
					client.currentUser.removeProp(prop);
				}
			}
		}
		
		public function doffPropById(propId:int):void
		{
			var prop:PalaceProp = PalacePropStore.getInstance().getProp(null, propId, 0);
			client.currentUser.removeProp(prop);			
		}
		
		public function doffPropByName(propName:String):void
		{
			// TODO: Implement
			logResult("doffPropByName propName: " + propName);
		}
		
		public function naked():void
		{
			client.currentUser.naked();
		}
		
		public function getUserProp(index:int):int
		{
			var prop:PalaceProp = PalaceProp(client.currentUser.props.getItemAt(index));
			if (prop) {
				return prop.asset.id;
			}
			return 0;
		}
		
		public function getMouseX():int
		{
			return client.currentRoom.roomView.mouseX;
		}
		
		public function getMouseY():int
		{
			return client.currentRoom.roomView.mouseY;
		}
		
		public function moveUserRel(xBy:int, yBy:int):void
		{
			client.move(client.currentUser.x + xBy, client.currentUser.y + yBy);
		}
		
		public function getSpotState(spotId:int):int
		{
			var hotspot:PalaceHotspot = client.currentRoom.getHotspotById(spotId);
			if (hotspot) {
				return hotspot.state;
			}
			return 0;
		}
		
		public function chat(text:String):void
		{
			client.roomChat(text);
		}
		
		public function clearAlarms():void
		{
			scriptManager.abort();
		}
		
		public function getDoorIdByIndex(index:int):int
		{
			var room:PalaceCurrentRoom = client.currentRoom;
			var doors:Vector.<PalaceHotspot> = new Vector.<PalaceHotspot>();
			var hotspot:PalaceHotspot;
			for (var i:int = 0; i < room.hotSpots.length; i ++) {
				hotspot = PalaceHotspot(room.hotSpots.getItemAt(i));
				if (hotspot.isDoor) {
					doors.push(hotspot);
				}
			}
			hotspot = null;
			hotspot = doors[index];
			if (hotspot) {
				return hotspot.id;
			}
			return 0;
		}
		
		public function setSpotStateLocal(spotId:int, state:int):void
		{
			var room:PalaceCurrentRoom = client.currentRoom;
			var hotspot:PalaceHotspot = room.getHotspotById(spotId);
			if (hotspot) {
				hotspot.changeState(state);
			}
		}
		
		public function getWhoTarget():int
		{
			if (client.currentRoom.selectedUser) {
				return client.currentRoom.selectedUser.id;
			}
			return 0;
		}
		
		public function beep():void
		{
			logResult("beep");
		}
		
		public function getSpotDest(spotId:int):int
		{
			var hotspot:PalaceHotspot = client.currentRoom.getHotspotById(spotId);
			if (hotspot) {
				return hotspot.dest;
			}
			return 0;
		}
				
		public function doMacro(macro:int):void
		{
			logResult("doMacro macro: " + macro);
		}
		
		public function changeColor(colorNumber:int):void
		{
			client.setColor(colorNumber);
		}
		
		public function getSpotName(spotId:int):String
		{
			var hotspot:PalaceHotspot = client.currentRoom.getHotspotById(spotId);
			if (hotspot) {
				return hotspot.name;
			}
			return "";
		}
		
		public function getUserName(userId:int):String
		{
			var user:PalaceUser = client.currentRoom.getUserById(userId);
			if (user) {
				return user.name;
			}
			return "";
		}
		
		public function getSelfUserName():String
		{
			return client.currentUser.name;
		}
		
		public function getNumRoomUsers():int
		{
			return client.currentRoom.users.length;
		}
		
		public function getSelfUserId():int
		{
			return client.currentUser.id;
		}
		
		public function lock(spotId:int):void
		{
			client.lockDoor(client.currentRoom.id, spotId);
		}
		
		public function midiStop():void
		{
			logResult("midiStop");
		}
		
		public function gotoRoom(roomId:int):void
		{
			client.gotoRoom(roomId);
		}
		
		public function inSpot(spotId:int):Boolean
		{
			// TODO: Implement this hit testing
			logResult("inSpot spotId: " + spotId);
			return false;
		}
		
		public function sendGlobalMessage(message:String):void
		{
			client.globalMessage(message);
		}
		
		public function sendRoomMessage(message:String):void
		{
			client.roomMessage(message);
		}
		
		public function sendSusrMessage(message:String):void
		{
			client.superUserMessage(message);
		}
		
		public function sendLocalMsg(message:String):void
		{
			client.currentRoom.localMessage(message);
		}
		
		public function donPropById(propId:int):void
		{
			client.currentUser.wearProp(PalacePropStore.getInstance().getProp(null, propId, 0));
		}
		
		public function donPropByName(propName:String):void
		{
			// TODO: Implement
			logResult("donPropByName propName: " + propName);
		}
		
		public function setProps(propIds:Array):void
		{
			var props:Vector.<PalaceProp> = new Vector.<PalaceProp>;
			for each (var propId:int in propIds) {
				var prop:PalaceProp = PalacePropStore.getInstance().getProp(null, propId, 0);
				props.push(prop);
			}
			client.currentUser.setProps(props);
		}
		
		public function hasPropById(propId:int):Boolean
		{
			for each (var prop:PalaceProp in client.currentUser.props) {
				if (prop.asset.id == propId) {
					return true;
				}
			}
			return false;
		}
		
		public function hasPropByName(propName:String):Boolean
		{
			logResult("hasPropByName propName: " + propName);
			return false;
		}
		
		public function getRoomName():String
		{
			return client.currentRoom.name;
		}
		
		public function getServerName():String
		{
			return client.serverName;
		}
		
		public function isLocked(spotId:int):Boolean
		{
			var hotspot:PalaceHotspot = client.currentRoom.getHotspotById(spotId);
			if (hotspot &&
					(hotspot.type == PalaceHotspot.TYPE_LOCKABLE_DOOR ||
					 hotspot.type == PalaceHotspot.TYPE_SHUTABLE_DOOR))
			{
				return hotspot.state == PalaceHotspot.STATE_LOCKED;
			}
			return false;
		}
		
		public function setSpotState(spotId:int, state:int):void
		{
			client.setSpotState(client.currentRoom.id, spotId, state);
		}
		
		public function isGod():Boolean
		{
			return client.currentUser.isGod;
		}
		
		public function getNumUserProps():int
		{
			return client.currentUser.propCount;
		}
		
		public function statusMessage(message:String):void
		{
			client.currentRoom.statusMessage(message);
		}
		
		public function playSound(soundName:String):void
		{
			PalaceSoundPlayer.getInstance().playSound(soundName);
		}
		
		public function getPosX(userId:int):int
		{
			var user:PalaceUser = client.currentRoom.getUserById(userId);
			if (user) {
				return user.x;
			}
			return 0;
		}
		
		public function getPosY(userId:int):int
		{
			var user:PalaceUser = client.currentRoom.getUserById(userId);
			if (user) {
				return user.y;
			}
			return 0;
		}
		
		public function setPicOffset(spotId:int, x:int, y:int):void
		{
			// TODO: Implement this
			logResult("setPicOffset spotId: " + spotId + " x: " + x + " y: " + y);
		}
		
		public function killUser(userId:int):void
		{
			client.privateMessage("`kill", userId);
		}
		
		public function getSpotIdByIndex(spotIndex:int):int
		{
			var hotspot:PalaceHotspot = PalaceHotspot(client.currentRoom.hotSpots.getItemAt(spotIndex));
			if (hotspot) {
				return hotspot.id;
			}
			return 0;
		}
		
		public function setChatString(message:String):void
		{
			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			client.chatstr = message;
		}
		
		public function getNumSpots():int
		{
			return client.currentRoom.hotSpots.length;
		}
		
		public function unlock(spotId:int):void
		{
			client.unlockDoor(client.currentRoom.id, spotId);
		}
		
		public function setFace(faceId:int):void
		{
			client.setFace(faceId);
		}
		
		public function logMessage(message:String):void
		{
			client.currentRoom.logMessage(message);
		}
		
		public function sendPrivateMessage(message:String, userId:int):void
		{
			client.privateMessage(message, userId);
		}
		
		public function getPropIdByName(propName:String):int
		{
			// TODO: Implement this
			logResult("getPropIdByName propName: " + propName);
			return 0;
		}
		
		public function addLooseProp(propId:int, x:int, y:int):void
		{
			client.addLooseProp(propId, 0, x, y);
		}
		
		public function removeLooseProp(propIndex:int):void
		{
			client.deleteLooseProp(propIndex);
		}
		
		public function showLooseProps():void
		{
			logResult("showLooseProps");
			var string:String = "";
			for each (var prop:PalaceLooseProp in client.currentRoom.looseProps) {
				string += prop.id + " " + prop.x + " " + prop.y + " ADDLOOSEPROP\n";
			}
			if (string.length > 0) {
				client.currentRoom.logMessage(string);
			}
		}
		
		public function getUserByName(userName:String):int
		{
			var user:PalaceUser = client.currentRoom.getUserByName(userName);
			if (user) {
				return user.id;
			}
			return 0;
		}
		
		public function getRoomId():int
		{
			return client.currentRoom.id;
		}
		
		public function setScriptAlarm(tokenList:IptTokenList, spotId:int, futureTime:int):void {
			var context:PalaceIptExecutionContext = new PalaceIptExecutionContext(scriptManager);
			context.hotspotId = spotId;
			var alarm:IptAlarm = new IptAlarm(tokenList, scriptManager, futureTime, context);
			scriptManager.addAlarm(alarm);
		}
		
		public function moveSpot(spotId:int, xBy:int, yBy:int):void
		{
			// TODO: Implement
			logResult("moveSpot spotId: " + spotId + " xBy: " + xBy + " yBy: " + yBy);
		}
		
		public function getRoomUserIdByIndex(userIndex:int):int
		{
			var user:PalaceUser = client.currentRoom.getUserByIndex(userIndex);
			if (user) {
				return user.id;
			}
			return 0;
		}
		
		public function getChatString():String
		{
			return client.chatstr;
		}
	
		public function setSpotAlarm(spotId:int, futureTime:int):void
		{
			var hotspot:PalaceHotspot = client.currentRoom.getHotspotById(spotId);
			if (hotspot) {
				var tokenList:IptTokenList = hotspot.getEventHandler(IptEventHandler.TYPE_ALARM);
				if (tokenList) {
					setScriptAlarm(tokenList, hotspot.id, futureTime);
				}
			}
		}
		
		public function drawLineAbs(startX:int, startY:int, endX:int, endY:int):void {
			var drawRec:PalaceDrawRecord = new PalaceDrawRecord();
			drawRec.lineColor = lineColor;
			drawRec.lineAlpha = lineAlpha;
			drawRec.fillColor = fillColor;
			drawRec.fillAlpha = fillAlpha;
			drawRec.penSize = lineSize;
			drawRec.command = PalaceDrawRecord.CMD_PATH;
			drawRec.layer = drawLayer;
			drawRec.useFill = useFill;
			drawRec.isEllipse = false;
			
			// all points are relative to the one before them.
			drawRec.polygon.push(new Point(startX, startY)); // start point
			drawRec.polygon.push(new Point(endX-startX, endY-startY)); // end point
			
			setTimeout(function():void {
				client.sendDrawPacket(drawRec);
			}, 1);
			
			penPosition.x = endX;
			penPosition.y = endY;
		}
		
		public function drawLineRel(xBy:int, yBy:int):void {
			var drawRec:PalaceDrawRecord = new PalaceDrawRecord();
			drawRec.lineColor = lineColor;
			drawRec.lineAlpha = lineAlpha;
			drawRec.fillColor = fillColor;
			drawRec.fillAlpha = fillAlpha;
			drawRec.penSize = lineSize;
			drawRec.command = PalaceDrawRecord.CMD_PATH;
			drawRec.layer = drawLayer;
			drawRec.useFill = useFill;
			drawRec.isEllipse = false;
			
			// all points are relative to the one before them.
			drawRec.polygon.push(penPosition.clone()); // start point
			drawRec.polygon.push(new Point(xBy, yBy)); // end point
			
			setTimeout(function():void {
				client.sendDrawPacket(drawRec);
			}, 1);
			
			penPosition.x += xBy;
			penPosition.y += yBy;
		}
		
		public function movePenAbs(xTo:int, yTo:int):void {
			penPosition.x = xTo;
			penPosition.y = yTo;
		}
		
		public function movePenRel(xBy:int, yBy:int):void {
			penPosition.x += xBy;
			penPosition.y += yBy;
		}
		
		public function setPenColor(r:uint, g:uint, b:uint):void {
			fillColor = lineColor = DrawColorUtil.ARGBtoUint(255, r, g, b);
		}
		
		public function setPenSize(size:uint):void {
			lineSize = Math.min(9, Math.max(0, size));
		}
		
		public function paintBackLayer():void {
			drawLayer = PalaceDrawRecord.LAYER_BACK;
		}
		
		public function paintFrontLayer():void {
			drawLayer = PalaceDrawRecord.LAYER_FRONT;
		}
		
		public function paintUndo():void {
			var drawRec:PalaceDrawRecord = new PalaceDrawRecord();
			drawRec.command = PalaceDrawRecord.CMD_DELETE;
			setTimeout(function():void {
				client.sendDrawPacket(drawRec);
			}, 1);
		}
		
		public function paintClear():void {
			var drawRec:PalaceDrawRecord = new PalaceDrawRecord();
			drawRec.command = PalaceDrawRecord.CMD_DETONATE;
			setTimeout(function():void {
				client.sendDrawPacket(drawRec);
			}, 1);
		}
		
	}
}