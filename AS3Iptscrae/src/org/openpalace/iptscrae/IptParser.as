package org.openpalace.iptscrae
{
	import org.openpalace.iptscrae.command.IptCommand;
	import org.openpalace.iptscrae.token.ArrayMarkToken;
	import org.openpalace.iptscrae.token.ArrayToken;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.IptToken;
	import org.openpalace.iptscrae.token.IptTokenList;
	import org.openpalace.iptscrae.token.StringToken;
	import org.openpalace.iptscrae.token.VariableToken;

	public class IptParser
	{
		private var manager:IptManager;
		private var commandList:Object;
		private var script:String;
		private var so:uint;
		
		private var hexNumberTest:RegExp = /^[0-9a-fA-F]{1}$/;
		private var tokenTest:RegExp = /^[a-zA-Z0-9_]{1}$/;
		
		public function IptParser(manager:IptManager, commandList:Object = null) {
			this.manager = manager;
			
			if (commandList == null) {
				this.commandList = {};
				addDefaultCommands();
			}
			else {
				this.commandList = commandList;
			}
		}
		
		public function getCommand(commandName:String):IptCommand {
			return commandList[commandName.toUpperCase()];
		}
		
		public function addDefaultCommands():void {
			for (var commandName:String in IptDefaultCommands.commands) {
				addCommand(commandName, IptDefaultCommands.commands[commandName]);
			}
		}
		
		public function addCommand(commandName:String, commandClass:Class):void {
			var ucCommandName:String = commandName.toUpperCase();
			if (commandList[ucCommandName] != null) {
				throw new IptError("Cannot add command. Command " + ucCommandName + " already defined.");
			}
			commandList[commandName.toUpperCase()] = new commandClass();
		}
		
		public function removeCommand(commandName:String):void {
			var ucCommandName:String = commandName.toUpperCase();
			if (commandList[ucCommandName] == null) {
				throw new IptError("Cannot remove command. Command " + ucCommandName + " doesn't exist.");
			}
			delete commandList[commandName.toUpperCase()];
		}
		
		public function currentChar():String { 
			return sc(0);
		}
		
		public function sc(offset:int):String
		{
			var pos:int = so + offset;
			if(pos < 0 || pos >= script.length)
				return null;
			else
				return script.charAt(pos);
		}
		
		public function tokenize(script:String):IptTokenList {
			this.script = script;
			so = 0;
			var tokenList:IptTokenList = new IptTokenList();
			var char:String;
			var arrayDepth:int = 0;
			
			while((char = currentChar()) != null && char.charCodeAt(0) != 0) { 
				
				if(char == " " || char == "\t" || char == "\r" || char == "\n") { // || char == "'"
					so++;
				}
					
				else if(char == '#' || char == ";") {
					while((char = currentChar()) != null && char != '\r' && char != '\n') {
						so++;
					}
				}
					
				else if(char == '{') {
					tokenList.addToken(parseAtomList());
				}
					
				else if(char == '"') {
					tokenList.addToken(parseStringLiteral());
				}
					
				else {
					if(char == '}') {
						throw new IptError("Parse error: unexpected '}' encountered at character offset " + so + ".");
					}
					if(char == '[') {
						so ++;
						arrayDepth ++;
						tokenList.addToken(new ArrayMarkToken());
					}
					else if(char == ']') {
						arrayDepth --;
						if (arrayDepth < 0) {
							throw new IptError("Parse error: encountered a ']' without a matching '['.  Character offset " + so + ".");
						}
						so ++;
						tokenList.addToken(popArrayDef(tokenList));
						//pushNewAtom(IptAtom.TYPE_ARRAY, popArrayDef());
					}
					else if(char == '!') {
						if (arrayDepth > 0) {
							throw new IptError("Cannot use operator inside an array at character " + so + ".");
						} 
						if(sc(1) == '=') {
							tokenList.addToken(getCommand("!="));
							so += 2;
						}
						else {
							tokenList.addToken(getCommand("!"));
							so ++;
						}
					}
					else if(char == '=') {
						if (arrayDepth > 0) {
							throw new IptError("Parse error: Cannot use operator inside an array at character " + so + ".");
						} 
						if(sc(1) == '=') {
							tokenList.addToken(getCommand("=="));
							so += 2;
						}
						else {
							tokenList.addToken(getCommand("="));
							so ++;
						}
					}
					else if(char == '+') {
						if (arrayDepth > 0) {
							throw new IptError("Parse error: Cannot use operator inside an array at character " + so + ".");
						} 
						if(sc(1) == '+') {
							tokenList.addToken(getCommand("++"));
							so += 2;
						}
						else if(sc(1) == '=') {
							tokenList.addToken(getCommand("+="));
							so += 2;
						}
						else {
							tokenList.addToken(getCommand("+"));
							so ++;
						}
					}
					else if(char == '-' && (sc(1) < '0' || sc(1) > '9')) {
						if (arrayDepth > 0) {
							throw new IptError("Parse error: Cannot use operator inside an array at character " + so + ".");
						} 
						if(sc(1) == '-') {
							tokenList.addToken(getCommand("--"));
							so += 2;
						}
						else if(sc(1) == '=') {
							tokenList.addToken(getCommand("-="));
							so += 2;
						}
						else {
							tokenList.addToken(getCommand("-"));
							so++;
						}
					}
					else if(char == '<') {
						if (arrayDepth > 0) {
							throw new IptError("Parse error: Cannot use operator inside an array at character " + so + ".");
						} 
						if (sc(1) == '>') {
							tokenList.addToken(getCommand("<>"));
							so += 2;
						}
						else if (sc(1) == '=') {
							tokenList.addToken(getCommand("<="));
							so += 2;
						}
						else {
							tokenList.addToken(getCommand("<"));
							so ++;
						}
					}
					else if(char == '>') {
						if (arrayDepth > 0) {
							throw new IptError("Parse error: Cannot use operator inside an array at character " + so + ".");
						} 
						if (sc(1) == "=") {
							tokenList.addToken(getCommand(">="));
							so += 2;
						}
						else {
							tokenList.addToken(getCommand(">"));
							so ++;
						}
					}
					else if(char == '*' || char == '/' || char == '&' || char == '%') {
						if (arrayDepth > 0) {
							throw new IptError("Parse error: Cannot use operator inside an array at character " + so + ".");
						}
						var operator:String = char;
						if (sc(1) == '=') {
							operator += "=";
							so ++;
						}
						tokenList.addToken(getCommand(operator));
						so++;
					}
					else if(char == '-' || char >= '0' && char <= '9') {
						tokenList.addToken(parseNumber());
					}
					else if(char == '_' || char >= 'a' && char <= 'z' || char >= 'A' && char <= 'Z') {
						tokenList.addToken(parseSymbol());
					}
					else {
						throw new IptError("Parse error: Unexpected character at character offset " + so + ", charcode: " + char.charCodeAt(0) + " -- '" + char + "'");
					}
				}
			}
			
			return tokenList;
		}
		
		private function parseAtomList():IptTokenList {
			var nest:int = 0;
			var qFlag:Boolean = false;
			var atomListString:String = "";
			if(currentChar() == '{') {
				so++;
			}
			while(currentChar() != null && currentChar().charCodeAt(0) != 0 && (currentChar() != '}' || nest > 0)) 
			{
				if(qFlag)
				{
					if(currentChar() == '\\')
					{
						atomListString += currentChar();
						so++;
					} else
						if(currentChar() == '"')
							qFlag = false;
				} else
				{
					switch(currentChar())
					{
						case "\"": // '"'
							qFlag = true;
							break;
						
						case "{": // '{'
							nest++;
							break;
						
						case "}": // '}'
							nest--;
							break;
					}
				}
				atomListString += currentChar();
				so++;
			}
			if(currentChar() == '}') {
				so++;
			}
			
			// save context before we parse something else
			var savedSo:uint = so;
			var savedScript:String = script;
			
			// parse inner script block
			var tokenList:IptTokenList = tokenize(atomListString);
			
			// restore parsing context back to the outer script
			script = savedScript;
			so = savedSo;
			
			return tokenList;
		}
		
		private function parseNumber():IntegerToken {
			var numString:String = "";
			var char:String;
			
			if(currentChar() == "-")
			{
				numString += "-";
				so++;
			}
			
			char = currentChar();
			while(char != null && char >= '0' && char <= '9')
			{
				numString += char;
				so++;
				char = currentChar();
			}
			
			return new IntegerToken(parseInt(numString));
		}
		
		private function parseStringLiteral():StringToken {
			var result:String = "";
			
			var dp:int = 0;
			if(currentChar() == '"') {
				so++;
			}
			while(currentChar() != null && currentChar().charCodeAt(0) != 0 && currentChar() != '"') { 
				if(currentChar() == '\\') {
					so++;
					if(currentChar() == 'x')
					{
						var hexNumChars:String = "0x";
						so++;
						while (hexNumberTest.test(currentChar())) {
							hexNumChars += currentChar();
							so ++;
						}
						
						result += String.fromCharCode(parseInt(hexNumChars));
					} else
					{
						result += currentChar();
						so++;
					}
				} else
				{
					result += currentChar();
					so++;
				}
			}
			if(currentChar() == '"') {
				so++;
			}
			return new StringToken(result);
		}
		
		private function popArrayDef(tokenList:IptTokenList):ArrayToken	{
			var array:ArrayToken = new ArrayToken();
			
			while ( tokenList.length > 0 ) {
				var token:IptToken = tokenList.popToken();
				if (!(token is ArrayMarkToken)) {
					array.data.unshift(token);
				}
				else {
					break;
				}
			}
			
			return array;
		}
		
		public function parseSymbol():IptCommand {
			var dp:int = 0;
			var sc:String = currentChar();
			var token:String = "";
			
			//while(sc != null && ((sc >= 'a' && sc <= 'z') || (sc >= 'A' && sc <= 'Z') || (sc >= '0' && sc <= '9') || sc == '_'))
			while(tokenTest.test(sc = currentChar()) && currentChar().charCodeAt(0) != 0)
			{
				token += sc.toUpperCase();
				so++;
				sc = currentChar()
			}
			
			var command:IptCommand = getCommand(token);
			if (command) {
				return command;
			}
			
			return new VariableToken(token);
		}
	}
}