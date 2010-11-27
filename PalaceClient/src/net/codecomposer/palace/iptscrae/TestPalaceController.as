package net.codecomposer.palace.iptscrae
{
	import net.codecomposer.palace.model.PalaceHotspot;
	
	import org.openpalace.iptscrae.IptTokenList;

	public class TestPalaceController implements IPalaceController
	{
		
		[Bindable]
		public var output:String;
		
		private var chatstr:String = "Test Chat String";
		
		public function TestPalaceController()
		{
			output = "";
		}
		
		public function logError(message:String):void {
			logResult(message);
		}
		
		private function logResult(value:String):void {
			output += value + "\n";
			trace(value);
		}
		
		public function triggerHotspotEvent(hotspot:PalaceHotspot, eventType:String):Boolean {
			return true;
		}
		
		public function gotoURL(url:String):void
		{
			logResult("gotoURL" + url);
		}
		
		public function launchApp(app:String):void
		{
			logResult("launchApp: " + app);
		}
		
		public function getWhoChat():int
		{
			logResult("getWhoChat");
			return 0;
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
			logResult("selectHotSpot spotId: " + spotId);
		}
		
		public function getNumDoors():int
		{
			logResult("getNumDoors");
			return 0;
		}
		
		public function isGuest():Boolean
		{
			logResult("isGuest")
			return true;
		}
		
		public function dimRoom(dimLevel:int):void
		{
			logResult("dimRoom dimLevel: " + dimLevel);
		}
		
		public function getSelfPosY():int
		{
			logResult("getSelfPosY");
			return 10;
		}
		
		public function getSelfPosX():int
		{
			logResult("getSelfPosX");
			return 20;
		}
		
		public function isWizard():Boolean
		{
			logResult("isWizard");
			return false;
		}
		
		public function moveUserAbs(x:int, y:int):void
		{
			logResult("moveUserAbs x: " + x + " y: " + y);
		}
		
		public function getTopProp():int
		{
			logResult("getTopProp");
			return 0;
		}
		
		public function dropProp(x:int, y:int):void
		{
			logResult("dropProp x: " + x + " y: " + y);
		}
		
		public function doffProp():void
		{
			logResult("doffProp");
		}
		
		public function doffPropById(propId:int):void
		{
			logResult("doffPropById propId: " + propId);
		}
		
		public function doffPropByName(propName:String):void
		{
			logResult("doffPropByName propName: " + propName);
		}
		
		public function naked():void
		{
			logResult("naked");
		}
		
		public function getUserProp(index:int):int
		{
			logResult("getUserProp index: " + index);
			return 0;
		}
		
		public function getMouseX():int
		{
			logResult("getMouseX");
			return 0;
		}
		
		public function getMouseY():int
		{
			logResult("getMouseY");
			return 0;
		}
		
		public function moveUserRel(xBy:int, yBy:int):void
		{
			logResult("moveUserRel x: " + xBy + " y: " + yBy);
		}
		
		public function getSpotState(spotId:int):int
		{
			logResult("getSpotState spotId: " + spotId);
			return 0;
		}
		
		public function chat(text:String):void
		{
			logResult("chat text: " + text);
		}
		
		public function clearAlarms():void
		{
			logResult("clearAlarms");
		}
		
		public function getDoorIdByIndex(index:int):int
		{
			logResult("getDoorIdByIndex index: " + index);
			return 0;
		}
		
		public function setSpotStateLocal(spotId:int, state:int):void
		{
			logResult("setSpotStateLocal spotId: " + spotId + " state: " + state);
		}
		
		public function getWhoTarget():int
		{
			logResult("getWhoTarget");
			return 0;
		}
		
		public function beep():void
		{
			logResult("beep");
		}
		
		public function getSpotDest(spotId:int):int
		{
			logResult("getSpotDest spotId: " + spotId);
			return 0;
		}
		
		public function getCurSpotDest():int
		{
			logResult("getCurSpotDest");
			return 0;
		}
		
		public function doMacro(macro:int):void
		{
			logResult("doMacro macro: " + macro);
		}
		
		public function changeColor(colorNumber:int):void
		{
			logResult("changeColor colorNumber: " + colorNumber);
		}
		
		public function getSpotName(spotId:int):String
		{
			logResult("getSpotName spotId: " + spotId);
			return "Test Spot Name";
		}
		
		public function getUserName(userId:int):String
		{
			logResult("getUserName userId: " + userId);
			return "Test User Name";
		}
		
		public function getSelfUserName():String
		{
			logResult("getSelfUserName");
			return "Test Self User Name";
		}
		
		public function getNumRoomUsers():int
		{
			logResult("getNumRoomUsers");
			return 25;
		}
		
		public function getSelfUserId():int
		{
			logResult("getSelfUserId");
			return 35;
		}
		
		public function lock(spotId:int):void
		{
			logResult("lock spotId:" + spotId);
		}
		
		public function midiStop():void
		{
			logResult("midiStop");
		}
		
		public function gotoRoom(roomId:int):void
		{
			logResult("gotoRoom roomId: " + roomId);
		}
		
		public function inSpot(spotId:int):Boolean
		{
			logResult("inSpot spotId: " + spotId);
			return false;
		}
		
		public function sendGlobalMessage(message:String):void
		{
			logResult("sendGlobalMessage message: " + message);
		}
		
		public function sendRoomMessage(message:String):void
		{
			logResult("sendRoomMessage message: " + message);
		}
		
		public function sendSusrMessage(message:String):void
		{
			logResult("sendSusrMessage message: " + message);
		}
		
		public function sendLocalMsg(message:String):void
		{
			logResult("sendLocalMsg message: " + message);
		}
		
		public function donPropById(propId:int):void
		{
			logResult("donPropById propId: " + propId);
		}
		
		public function donPropByName(propName:String):void
		{
			logResult("donPropByName propName: " + propName);
		}
		
		public function setProps(propIds:Array):void
		{
			logResult("setProps propIds: " + propIds.join(", "));
		}
		
		public function hasPropById(propId:int):Boolean
		{
			logResult("hasPropById propId: " + propId);
			return false;
		}
		
		public function hasPropByName(propName:String):Boolean
		{
			logResult("hasPropByName propName: " + propName);
			return false;
		}
		
		public function getRoomName():String
		{
			logResult("getRoomName");
			return "Test Room Name";
		}
		
		public function getServerName():String
		{
			logResult("getServerName");
			return "My Test Server Name";
		}
		
		public function isLocked(spotId:int):Boolean
		{
			logResult("isLocked spotId: " + spotId);
			return false;
		}
		
		public function setSpotState(spotId:int, state:int):void
		{
			logResult("setSpotState spotId: " + spotId + " state: " + state);
		}
		
		public function isGod():Boolean
		{
			logResult("isGod");
			return false;
		}
		
		public function getNumUserProps():int
		{
			logResult("getNumUserProps");
			return 0;
		}
		
		public function statusMessage(message:String):void
		{
			logResult("statusMessage message: " + message);
		}
		
		public function playSound(soundName:String):void
		{
			logResult("playSound soundName: " + soundName);
		}
		
		public function getPosX(userId:int):int
		{
			logResult("getPosX userId: " + userId);
			return 40;
		}
		
		public function getPosY(userId:int):int
		{
			logResult("getPosY userId: " + userId);
			return 50;
		}
		
		public function setPicOffset(spotId:int, x:int, y:int):void
		{
			logResult("setPicOffset spotId: " + spotId + " x: " + x + " y: " + y);
		}
		
		public function killUser(userId:int):void
		{
			logResult("killUser userId: " + userId);
		}
		
		public function getSpotIdByIndex(spotIndex:int):int
		{
			logResult("getSpotIdByIndex spotIndex: " + spotIndex);
			return 0;
		}
		
		public function setChatString(message:String):void
		{
			logResult("setChatString message: " + message);
			chatstr = message;
		}
		
		public function getNumSpots():int
		{
			logResult("getNumSpots");
			return 0;
		}
		
		public function unlock(spotId:int):void
		{
			logResult("unlock spotId: " + spotId);
		}
		
		public function setFace(faceId:int):void
		{
			logResult("setFace faceId: " + faceId);
		}
		
		public function logMessage(message:String):void
		{
			logResult("logMessage message: " + message);
		}
		
		public function sendPrivateMessage(message:String, userId:int):void
		{
			logResult("sendPrivateMessage message: " + message + " userId: " + userId);
		}
		
		public function getPropIdByName(propName:String):int
		{
			logResult("getPropIdByName propName: " + propName);
			return 123456789;
		}
		
		public function addLooseProp(propId:int, x:int, y:int):void
		{
			logResult("addLooseProp propId: " + propId + " x: " + x + " y: " + y);
		}
		
		public function removeLooseProp(propIndex:int):void
		{
			logResult("removeLooseProp propIndex: " + propIndex);
		}
		
		public function showLooseProps():void
		{
			logResult("showLooseProps");
		}
		
		public function getUserByName(userName:String):int
		{
			logResult("getUserByName userName: " + userName);
			return 55;
		}
		
		public function getRoomId():int
		{
			logResult("getRoomId");
			return 86;
		}
		
		public function getCurrentSpotId():int
		{
			logResult("getCurrentSpotId")
			return 2;
		}
		
		public function setScriptAlarm(tokenList:IptTokenList, spotId:int, futureTime:int):void
		{
			logResult("setScriptAlarm spotId: " + spotId + " futureTime: " + futureTime);
		}
		
		public function moveSpot(spotId:int, xBy:int, yBy:int):void
		{
			logResult("moveSpot spotId: " + spotId + " xBy: " + xBy + " yBy: " + yBy);
		}
		
		public function getRoomUserIdByIndex(userIndex:int):int
		{
			logResult("getRoomUserIdByIndex userIndex: " + userIndex);
			return 65;
		}
		
		public function getChatString():String
		{
			logResult("getChatString");
			return chatstr;
		}
		
		public function getSelfSpotDest():int
		{
			logResult("getSelfSpotDest");
			return 87;
		}
		
		public function setSpotAlarm(spotId:int, futureTime:int):void
		{
			logResult("setSpotAlarm spotId: " + spotId + " futureTime: " + futureTime);
		}
	}
}