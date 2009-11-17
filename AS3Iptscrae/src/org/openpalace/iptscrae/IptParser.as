package org.openpalace.iptscrae
{
	public class IptParser
	{
		private var commandList:Object;
		
		public function IptParser(commandList:Object = null) {
			if (commandList == null) {
				commandList = {};
			}
			this.commandList = commandList;
		}
		
		public function addCommand(commandName:String, commandClass:Class):void {
			commandList[commandName.toUpperCase()] = commandClass;
		}
		
		public function removeCommand(commandName:String):void {
			delete commandList[commandName.toUpperCase()];
		}
		
		public function tokenize(script:String):IptTokenList {
			var tokenList:IptTokenList = new IptTokenList();
			return tokenList;
		}
	}
}