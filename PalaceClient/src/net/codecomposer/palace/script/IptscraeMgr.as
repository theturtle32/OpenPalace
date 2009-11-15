package net.codecomposer.palace.script
{
	import flash.utils.Dictionary;

	public class IptscraeMgr implements IScriptMgr
	{
		public var pStack:Vector.<IptAtom>; //Stack
		public var tsp:Array; // Stack
		public var strTable:Vector.<String>; // Vector.<String>?
		public var aryTable:Vector.<Array>; // Vector.<Vector>?  Vector.<Array>?
		public var vList:Dictionary;
		public var gList:Dictionary;
		public var scriptStr:String;
		public var so:int;
		public var si:int;
		public var pc:IPalaceController;
		public var abortScriptCode:Number = NaN;
		public var scriptRunning:Boolean = false;
		public var grepPattern:RegExp;
		public var grepMatchData:Array;
		public var mErrorHandler:PalaceErrorHandler = new PalaceErrorHandler();
		private var tokenTest:RegExp = /^[a-zA-Z0-9_]{1}$/;
		
		public function sf_NETGOTO():void
		{
			pc.gotoURL(popString());
		}
		
		public function sf_SHELLCMD():void
		{
			// Unsupported
			popString();
		}
		
		public function sf_EXEC():void
		{
			var a1:IptAtom = popValue();
			if(a1.type == 3)
				callSubroutine(a1.value);
		}
		
		public function parseAtomList():void
		{
			var nest:int = 0;
			var qFlag:Boolean = false;
			var atomListString:String = "";
			if(currentChar() == '{')
				so++;
			while(currentChar() != null && (currentChar() != '}' || nest > 0)) 
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
			if(currentChar() == '}')
				so++;
			var index:int = addToStringTable(atomListString);
			pushNewAtom(IptAtom.TYPE_ATOMLIST, index);
		}
		
		public function sf_DEF():void
		{
			var s1:IptAtom = popAtom();
			var v:IptVariable = getVariableByAtom(s1);
			var t:IptAtom = popAtom();
			assignVariable(v, t);
		}
		
		public function sf_ITOA():void
		{
			pushString(popInt().toString());
		}
		
		public function newGlobal(variable:IptVariable):void
		
		{
			var data:Object;
			switch(variable.type)
			{
				case IptAtom.TYPE_ATOMLIST: // '\003'
				case IptAtom.TYPE_STRING: // '\004'
					data = getString(variable.value);
					break;
				case IptAtom.TYPE_ARRAY: // '\006'
					data = arrayToGlobal(variable.name, variable.value);
				break;
				case IptAtom.TYPE_ARRAY_MARK: // '\005'
				default:
					data = null;
					break;
			}
			var gv:IptGVariable = new IptGVariable(variable.name, variable.type, variable.value, variable.flags, data);
			gList[gv.name] = gv;
		}
		
		public function updateGlobal(variable:IptVariable):void 
		{
			var gv:IptGVariable = IptGVariable(gList[variable.name]);
			if(gv != null)
			{
				gv.type = variable.type;
				gv.value = variable.value;
				gv.flags = variable.flags;
				if(variable.type == 3 || variable.type == 4)
					gv.data = getString(variable.value);
				else
				if(variable.type == 6)
					gv.data = arrayToGlobal(variable.name, variable.value);
				else
					gv.data = null;
			} else
			{
				newGlobal(variable);
			}
		}
		
		public function sf_OR():void
		{
			pushInt(popInt() > 0 || popInt() > 0 ? 1 : 0);
		}
		
		public function getVariableByAtom(a1:IptAtom):IptVariable
		{
			if(a1.type != IptAtom.TYPE_VARIABLE)
				invalidArg();
			return getVariableByString(getString(a1.value));
		}
		
		public function getVariableByString(sym:String):IptVariable
		{
			var iv:IptVariable = IptVariable(vList[sym]);
			if(iv == null && (iv = newVariable(sym)) == null)
				forceAbort("Internal Error");
			return iv;
		}
		
		public function sf_WHOCHAT():void
		{
			pushInt(pc.getWhoChat());
		}
		
		public function sf_MIDILOOP():void
		{
			var name:String = popString();
			var loopNbr:int = popInt();
			pc.midiLoop(loopNbr, name);
		}
		
		public function sf_SELECT():void
		{
			pc.selectHotSpot(popInt());
		}
		
		public function sf_NBRDOORS():void
		{
			pushInt(pc.getNumDoors());
		}
		
		public function sf_ISGUEST():void
		{
			pushInt(pc.isGuest() ? 1 : 0);
		}
		
		public function forceAbort(msg:String):void
		{
			abortScriptCode = 5;
			throw new IptscraeError(msg);
		}
		
		public function pushNewAtom(type:int, value:int):void
		{
			pushAtom(new IptAtom(type, value));
		}
		
		public function pushAtom(atom:IptAtom):void
		{
			pStack.push(atom);
		}
		
		public function popAtom():IptAtom
		{
			if(pStack.length > 0)
			{
				return IptAtom(pStack.pop());
			} else
			{
				forceAbort("Missing argument");
				return null;
			}
		}
		
		public function sf_DIMROOM():void
		{
			pc.dimRoom(popInt());
		}
		
		public function popInt():int
		{
			var a:IptAtom = popValue();
			if(a.type == 1)
			{
				return a.value;
			} else
			{
				invalidArg();
				return 0;
			}
		}
		
		public function sf_POSY():void
		{
			pushInt(pc.getSelfPosY());
		}
		
		public function sf_TICKS():void
		{
			var date:Date = new Date();
			pushInt(int(date.valueOf() / Number(17) % 0x4F1A00));
			// pushInt((int)((System.currentTimeMillis() / 17L) % 0x4f1a00L));
		}
		
		public function sf_ISWIZARD():void
		{
			pushInt(pc.isWizard() ? 1 : 0);
		}
		
		public function sf_SETPOS():void
		{
			var y:int = popInt();
			var x:int = popInt();
			pc.moveUserAbs(x, y);
		}
		
		public function sf_TOPPROP():void
		{
			pushInt(pc.getTopProp());
		}
		
		public function sf_DROPPROP():void
		{
			var y:int = popInt();
			var x:int = popInt();
			pc.dropProp(x, y);
		}
		
		public function sf_REMOVEPROP():void
		{
			var a:IptAtom = popValue();
			if(a.type == 1) // int?
				pc.doffPropById(int(a.value));
			else
				pc.doffPropByName(getString(a.value));
		}
		
		public function sf_CLEARPROPS():void
		{
			pc.naked();
		}
		
		public function sf_USERPROP():void
		{
			pushInt(pc.getUserProp(popInt()));
		}
		
		public function sf_MOUSEPOS():void
		{
			pushInt(pc.getMouseX());
			pushInt(pc.getMouseY());
		}
		
		public function sf_MOVE():void
		{
			var yDelta:int = popInt();
			var xDelta:int = popInt();
			pc.moveUserRel(xDelta, yDelta);
		}
		
		public function sf_GETSPOTSTATE():void
		{
			pushInt(pc.getSpotState(popInt()));
		}
		
		public function sf_SAY():void
		{
			// this is too permissive.  Should force ITOA for integers
//			var atom:IptAtom = popValue();
//			if(atom.type == 4 || atom.type == 3)
//				pc.chat(getString(atom.value));
//			else
//				pc.chat(int(atom.value).toString());
			pc.chat(popString());
		}
		
		public function runMessageScript(msg:String):int
		{
			var index:int = addToStringTable(msg);
			var retVal:int = 0;
			try
			{
				if(!scriptRunning)
				{
					si = index;
					so = 0;
					scriptStr = getString(index);
					scriptRunning = true;
					abortScriptCode = 0;
					runScript();
					if(abortScriptCode >= 4)
						pc.clearAlarms();
					scriptRunning = false;
					if(pStack.length > 0)
					{
						var atom:IptAtom = popValue();
						if(atom.type == 1)
							retVal = atom.value;
					}
					initInterpreter();
				} else
				{
					callSubroutine(index);
				}
			}
			catch(ie:IptscraeError)
			{
				pc.clearAlarms();
				scriptRunning = false;
				completeAbort(ie.message);
				initInterpreter();
			}
			catch(e:Error) {
				pc.clearAlarms();
				scriptRunning = false;
				completeAbort(e.message);
				initInterpreter();
			}
			return retVal;
		}
		
		public function runScript():void
		{
			if(abortScriptCode != 0)
				return;
			var char:String; // char
			var oper:String;
			var a1:IptAtom;
			var a2:IptAtom;
			var v:IptVariable;
			while((char = currentChar()) != null && abortScriptCode == 0) { 
				
				if(char == " " || char == "\t" || char == "\r" || char == "\n") { // || char == "'"
					so++;
				}
				
				else if(char == '#' || char == ";") {
					while((char = currentChar()) != null && char != '\r' && char != '\n') {
						so++;
					}
				}
				
				else if(char == '{') {
					parseAtomList();
				}
				
				else if(char == '"') {
					parseStringLiteral();
				}
				
				else {
					if(char == '}') {
						return;
					}
					if(char == '[') {
						so++;
						pushNewAtom(IptAtom.TYPE_ARRAY_MARK, 0);
					} else
					if(char == ']') {
						so++;
						pushNewAtom(IptAtom.TYPE_ARRAY, popArrayDef());
					}
					else if(char == '!') {
						if(sc(1) == '=') {
							a2 = popAtom();
							a1 = popAtom();
							binaryOp('a', a1, a2);
								so++;
								so++;
						}
						else {
							a1 = popAtom();
							unaryOp('!', a1);
							so++;
						}
					}
					else if(char == '=') {
						if(sc(1) == '=') {
							a2 = popAtom();
							a1 = popAtom();
							binaryOp('=', a1, a2);
							so++;
							so++;
						}
						else {
							a2 = popAtom();
							a1 = popAtom();
							v = getVariableByAtom(a2);
							assignVariable(v, a1);
							so++;
						}
					}
					else if(char == '+') {
						if(sc(1) == '+') {
							a1 = popAtom();
							unaryAssignment('+', a1);
							so++;
							so++;
						}
						else if(sc(1) == '=') {
							a2 = popAtom();
							a1 = popAtom();
							binaryAssignment('+', a1, a2);
							so++;
							so++;
						}
						else {
							a2 = popAtom();
							a1 = popAtom();
							binaryOp('+', a1, a2);
							so++;
						}
					}
					else if(char == '-' && (sc(1) < '0' || sc(1) > '9')) {
						if(sc(1) == '-') {
							a1 = popAtom();
							unaryAssignment('-', a1);
							so++;
							so++;
						}
						else if(sc(1) == '=') {
							a2 = popAtom();
							a1 = popAtom();
							binaryAssignment('-', a1, a2);
							so++;
							so++;
						}
						else {
							a2 = popAtom();
							a1 = popAtom();
							binaryOp('-', a1, a2);
							so++;
						}
					}
					else if(char == '<') {
						oper = '<'; // char
						if(sc(1) == '>') {
							oper = 'a';
							so++;
						}
						else if(sc(1) == '=') {
							oper = 'b';
							so++;
						}
						a2 = popAtom();
						a1 = popAtom();
						binaryOp(oper, a1, a2);
						so++;
					}
					else if(char == '>') {
						oper = '>';
						if(sc(1) == '=')
						{
							oper = 'c';
							so++;
						}
						a2 = popAtom();
						a1 = popAtom();
						binaryOp(oper, a1, a2);
						so++;
					}
					else if(char == '*' || char == '/' || char == '&' || char == '%') {
						oper = char;
						a2 = popAtom();
						a1 = popAtom();
						if(sc(1) == '=') {
							binaryAssignment(oper, a1, a2);
							so++;
						}
						else {
							binaryOp(oper, a1, a2);
						}
						so++;
					}
					else if(char == '-' || char >= '0' && char <= '9') {
						parseNumber();
					}
					else if(char == '_' || char >= 'a' && char <= 'z' || char >= 'A' && char <= 'Z') {
						parseSymbol();
					}
					else {
						forceAbort("Unexpected character: '" + char + "'");
					}
				}
			}
		}
		
		public function sf_PUT():void
		{
			var idx:int = popInt();
			var a:IptAtom = popAtom();
			var ary:Array = null;
			var atom:IptAtom = popValue();
			var isGlobal:Boolean = false;
			var gv:IptGVariable = null;
		
			switch(a.type)
			{
				case IptAtom.TYPE_ARRAY: // '\006'
					ary = getArray(a.value);
					break;
				
				case IptAtom.TYPE_VARIABLE: // '\002'
					var vt:IptVariable = getVariableByAtom(a);
					if(vt != null)
						if((vt.flags & 1) > 0)
						{
							gv = IptGVariable(gList[vt.name]);
							if(gv != null)
							{
								ary = gv.data as Array;
								isGlobal = true;
							}
						} else
						{
							ary = getArray(vt.value);
						}
					break;
			}
			if(ary == null)
				invalidArg();
			if(idx >= 0 && idx < ary.length) {
				if(isGlobal) {
					ary[idx] = atomToGVariable(idx.toString() + "_" + gv.name, atom);
				}
				else {
					ary[idx] = atom;
				}
			}
		}
		
		public function sf_DOORIDX():void
		{
			pushInt(pc.getDoorIdByIndex(popInt()));
		}
		
		public function sf_FOREACH():void
		{
			var ary:Array = popArray();
			var atomList:IptAtom = popValue();
			if(atomList.type != IptAtom.TYPE_ATOMLIST)
				return;
			for(var i:int = 0; i < ary.length && abortScriptCode == 0; i++)
			{
				pushAtom(IptAtom(ary[i]).cloneAtom());
				callSubroutine(atomList.value);
			}
			
			if(abortScriptCode == 1)
				abortScriptCode = 0;
		}
		
		public function sf_DELAY():void
		{
			// should never be implemented
			//pc.pc_Delay(popInt());
		}
		
		public function stop():void
		{
			pc.clearAlarms();
			scriptRunning = false;
			completeAbort("application stopped");
			initInterpreter();
		}
		
		public function sf_SETSPOTSTATELOCAL():void
		{
			var id:int = popInt();
			var state:int = popInt();
			pc.setSpotStateLocal(id, state);
		}
		
		public function sf_GET():void
		{
			var idx:int = popInt();
			var a:IptAtom = popAtom();
			var ary:Array = null; // Vector
			var isGlobal:Boolean = false;
			switch(a.type)
			{
				case IptAtom.TYPE_ARRAY: // '\006' Array
					ary = getArray(a.value);
					break;
				
				case IptAtom.TYPE_VARIABLE: // '\002'  Atom?
					var vt:IptVariable = getVariableByAtom(a);
					if(vt != null)
						if((vt.flags & IptVariable.FLAG_GLOBAL) > 0)
						{
							var gv:IptGVariable = IptGVariable(gList[vt.name]);
							if(gv != null)
							{
								ary = gv.data as Array; // Vector
								isGlobal = true;
							}
						} else
						{
							ary = getArray(vt.value);
						}
					break;
			}
			if(ary == null)
				invalidArg();
			if(idx >= 0 && idx < ary.length)
			{
				if(isGlobal)
					pushAtom(gVariableToAtom(IptGVariable(ary[idx])));
				else
					pushAtom(IptAtom(ary[idx]).cloneAtom());
			} else
			{
				pushInt(0);
			}
		}
		
		public function sf_WHOTARGET():void
		{
			pushInt(pc.getWhoTarget());
		}
		
		public function sf_BREAK():void
		{
			abortScriptCode = 1;
		}
		
		public function sf_BEEP():void
		{
			pc.beep();
		}
		
		public function sf_SPOTDEST():void
		{
			pushInt(pc.getSpotDest(popInt()));
		}
		
		public function sf_LAUNCHAPP():void
		{
			pc.launchApp(popString());
		}
		
		public function sf_MACRO():void
		{
			pc.doMacro(popInt());
		}
		
		public function sf_IF():void
		{
			var expResult:int = popInt();
			var s1:IptAtom = popAtom();
			if(expResult != 0)
			{
				atomToValue(s1);
				if(s1.type == IptAtom.TYPE_ATOMLIST) // 3 -- Atomlist?
					callSubroutine(s1.value);
			}
		}
		
		public function sf_SETCOLOR():void
		{
			pc.changeColor(popInt());
		}
		
		public function sf_SPOTNAME():void
		{
			pushString(pc.getSpotName(popInt()));
		}
		
		public function sf_WHONAME():void
		{
			pushString(pc.getUserName(popInt()));
		}
		
		public function sf_USERNAME():void
		{
			pushString(pc.getSelfUserName());
		}
		
		public function sf_STRTOATOM():void
		{
			pushNewAtom(IptAtom.TYPE_ATOMLIST, addToStringTable(popString()));
		}
		
		public function sf_RANDOM():void
		{
			pushInt( int(Math.random() * Number(popInt())) );
		}
		
		public function sf_DUP():void
		
		{
			if(pStack.length > 0)
			{
				var p1:IptAtom = IptAtom(pStack[pStack.length-1]);
				pushAtom(p1.cloneAtom());
			}
		}
		
		public function retrieveGlobal(variable:IptVariable):void
		{
			var gv:IptGVariable = IptGVariable(gList[variable.name]);
			if(gv != null)
			{
				variable.type = gv.type;
				variable.value = gv.value;
				variable.flags = gv.flags;
				switch(variable.type)
				{
					case IptAtom.TYPE_ATOMLIST: // '\003'
					case IptAtom.TYPE_STRING: // '\004'
						variable.value = addToStringTable(String(gv.data));
						break;
					
					case IptAtom.TYPE_ARRAY: // '\006'
						variable.value = globalToArray(gv.data as Array);
					break;
				}
			}
		}
		
		public function arrayToGlobal(arrayName:String, aIdx:int):Array // Vector
		{
			var lAry:Array = getArray(aIdx); // Vector
			var gAry:Array = new Array(); // Vector
			for(var i:int = 0; i < lAry.length; i++)
			{
				var atom:IptAtom = IptAtom(lAry[i]);
				gAry.push(atomToGVariable(i.toString + "_" + arrayName, atom));
			}
			
			return gAry;
		}
		
		public function sf_LAUNCHEVENT():void
		{
			// PalacePresents: not supported, ever.
			popString();
		}
		
		public function sf_LOADJAVA():void
		{
			// LOADJAVA?  InstantPalace didn't even support this.
			popString();
		}
		
		public function sf_IFELSE():void
		{
			var expResult:int = popInt();
			var se1:IptAtom = popAtom();
			var s1:IptAtom = popAtom();
			if(expResult != 0)
			{
				atomToValue(s1);
				if(s1.type == 3)
					callSubroutine(s1.value);
			} else
			{
				atomToValue(se1);
				if(se1.type == 3)
					callSubroutine(se1.value);
			}
		}
		
		public function popArrayDef():int
		{
			var ary:Array = []; // Vector
			var a:IptAtom;
			do {
				a = popValue();
				if (a.type != IptAtom.TYPE_ARRAY_MARK) {
					ary.unshift(a);
				}
			}
			while (pStack.length > 0 && a.type != IptAtom.TYPE_ARRAY_MARK);
			
			return addToArrayTable(ary);
		}
		
		public function sf_NBRROOMUSERS():void
		
		{
			pushInt(pc.getNumRoomUsers());
		}
		
		public function IptscraeMgr(pc:IPalaceController) // PalaceCommander
		{
			pStack = new Vector.<IptAtom>(); // Stack
			tsp = []; // Stack
			strTable = new Vector.<String>(); // Vector
			aryTable = new Vector.<Array>(); // Vector
			vList = new Dictionary();
			gList = new Dictionary();
			scriptStr = "";
			so = 0;
			si = 0;
			scriptRunning = false;
			abortScriptCode = 0;
			//grepCompiler = new Perl5Compiler();
			//grepMatcher = new Perl5Matcher();
			//grepPattern = null;
			grepPattern = null;
			this.pc = pc;
			pc.setScriptManager(this);
			initInterpreter();
		}
		
		public function sf_DATETIME():void
		{
			var date:Date = new Date();
			pushInt(int(date.valueOf() / 1000));
		}
		
		public function completeAbort(msg:String):void
		{
			var message:String = ""
			if(mErrorHandler != null) {
				message = "Aborting script: " + msg;
				mErrorHandler.reportError(message, PalaceErrorHandler.LEVEL_INFO);
			}
			abortScriptCode = 5;
			pc.logError(message);
		}
		
		public function sf_SUBSTR():void
		{
			var frag:String = popString().toUpperCase();
			var whole:String = popString().toUpperCase();
			pushInt(whole.indexOf(frag) != -1 ? 1 : 0);
		}
		
		public function gVariableToAtom(gVar:IptGVariable):IptAtom
		{
			var type:int = gVar.type;
			var val:int = gVar.value;
			switch(gVar.type)
			{
				case IptAtom.TYPE_ATOMLIST: // '\003'
				case IptAtom.TYPE_STRING: // '\004'
					val = addToStringTable(String(gVar.data));
					break;
				
				case IptAtom.TYPE_ARRAY: // '\006'
					val = globalToArray(gVar.data as Array);
					break;
			}
			return new IptAtom(type, val);
		}
		
		public function sf_WHOME():void
		{
			pushInt(pc.getSelfUserId());
		}
		
		public function sf_LOCK():void
		{
			pc.lock(popInt());
		}
		
		public function sf_MIDISTOP():void
		{
			pc.midiStop();
		}
		
		public function sf_GOTOROOM():void
		{
			pc.gotoRoom(popInt());
		}
		
		public function sf_INSPOT():void
		{
			pushInt(pc.inSpot(popInt()) ? 1 : 0);
		}
		
		public function sf_GLOBALMSG():void
		{
			pc.sendGlobalMessage(popString());
		}
		
		public function sf_ROOMMSG():void
		{
			pc.sendRoomMessage(popString());
		}
		
		public function sf_SUSRMSG():void
		{
			pc.sendSusrMessage(popString());
		}
		
		public function sf_LOCALMSG():void
		{
			pc.sendLocalMsg(popString());
		}
		
		public function sf_DONPROP():void
		{
			var a:IptAtom = popValue();
			if(a.type == IptAtom.TYPE_INTEGER) // 0x01
				pc.donPropById(a.value);
			else
				pc.donPropByName(getString(a.value));
		}
		
		public function sf_SETPROPS():void
		{
			pc.setProps(popArray());
		}
		
		public function sf_HASPROP():void
		{
			var a:IptAtom = popValue();
			if(a.type == IptAtom.TYPE_INTEGER)
				pushInt(pc.hasPropById(int(a.value)) ? 1 : 0);
			else
				if(a.type == IptAtom.TYPE_STRING)
					pushInt(pc.hasPropByName(getString(a.value)) ? 1 : 0);
				else
					pushInt(0);
		}
		
		public function sf_ROOMNAME():void
		{
			pushString(pc.getRoomName());
		}
		
		public function sf_ISLOCKED():void
		{
			pushInt(pc.isLocked(popInt()) ? 1 : 0);
		}
		
		public function sf_SETSPOTSTATE():void
		{
			var id:int = popInt();
			var state:int = popInt();
			pc.setSpotState(id, state);
		}
		
		public function sf_MIDIPLAY():void
		{
			pc.midiPlay(popString());
		}
		
		public function sf_DOFFPROP():void
		{
			pc.doffProp();
		}
		
		public function sf_ISGOD():void
		{
			pushInt(pc.isGod() ? 1 : 0);
		}
		
		private var hexNumberTest:RegExp = /^[0-9a-fA-F]{1}$/;
		
		public function parseStringLiteral():void
		{
			var result:String = "";
			
			var dp:int = 0;
			if(currentChar() == '"') {
				so++;
			}
			while(currentChar() != null && currentChar() != '"') { 
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
						result += String.fromCharCode(hexNumChars);
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
			pushString(result);
		}
		
		public function sf_UPPERCASE():void
		{
			pushString(popString().toUpperCase());
		}
		
		public function sf_GREPSTR():void
			
		{
			var pattern:String = popString();
			var stringToSearch:String = popString();
			try
			{
				grepPattern = new RegExp(pattern);
			}
			catch(e:Error)
			{
				grepPattern = null;
				forceAbort("Bad GREPSTR Pattern");
			}
			
			grepMatchData = stringToSearch.match(grepPattern);
			
			pushInt( (grepMatchData == null) ? 0 : 1 );
		}
		
		public function sf_GREPSUB():void
		{
			var result:String = popString();

			if (grepMatchData) {
				for (var i:int = 0; i < grepMatchData.length; i++) {
					var regexp:RegExp = new RegExp("\\$" + i.toString(), "g");
					result = result.replace(regexp, grepMatchData[i]); 
				}
			}

			pushString(result);
		}
		
		public function sf_LENGTH():void
		{
			var a:IptAtom = popAtom();
			var ary:Array = null;
			var isGlobal:Boolean = false;
			switch(a.type)
			{
				case IptAtom.TYPE_ARRAY:
					ary = getArray(a.value);
					break;
				
				case IptAtom.TYPE_VARIABLE:
					var vt:IptVariable = getVariableByAtom(a);
					if(vt != null)
						if((vt.flags & IptVariable.FLAG_GLOBAL) > 0)
						{
							var gv:IptGVariable = IptGVariable(gList[vt.name]);
							if(gv != null)
							{
								ary = gv.data as Array;
								isGlobal = true;
							}
						} else
						{
							ary = getArray(vt.value);
						}
					break;
			}
			if(ary == null) {
				invalidArg();
			}
			pushInt(ary.length);
		}
		
		public function globalToArray(gAry:Array):int // Vector
		{
			var lAry:Array = []; // Vector
			for(var i:int = 0; i < gAry.length; i++)
			{
				var gvar:IptGVariable = IptGVariable(gAry[i]);
				var atom:IptAtom = gVariableToAtom(gvar);
				lAry.push(atom);
			}
			
			return addToArrayTable(lAry);
		}
		
		public function atomToValue(atom:IptAtom):IptAtom
		
		{
			if(atom.type == IptAtom.TYPE_VARIABLE)
			{
				var vt:IptVariable = getVariableByAtom(atom);
				if(vt != null)
				{
					if((vt.flags & IptVariable.FLAG_GLOBAL) > 0)
						retrieveGlobal(vt);
					else if((vt.flags & IptVariable.FLAG_SPECIAL_VARIABLE) > 0)
						retrieveExternStringGlobalByName(vt);
					atom.type = vt.type;
					atom.value = vt.value;
				}
			}
			return atom;
		}
		
		public function popValue():IptAtom
		{
			return atomToValue(popAtom());
		}
		
		public function pushInt(value:int):void
		{
			pushNewAtom(IptAtom.TYPE_INTEGER, value);
		}
		
		public function initInterpreter():void
		{
			scriptRunning = false;
			tsp = [];
			pStack = new Vector.<IptAtom>();
			vList = new Dictionary();
			strTable = new Vector.<String>();
			aryTable = new Vector.<Array>();
		}
		
		public function sf_NBRUSERPROPS():void
		{
			pushInt(pc.getNumUserProps());
		}
		
		public function retrieveExternStringGlobalByName(variable:IptVariable):void
		{
			if(variable.name == "CHATSTR")
				retrieveExternStringGlobal(variable, 0);
		}
		
		public function currentChar():String { 
			return sc(0);
		}
		
		public function sc(offset:int):String
		{
			var pos:int = so + offset;
			if(pos < 0 || pos >= scriptStr.length)
				return null;
			else
				return scriptStr.charAt(pos);
		}
		
		public function popAtomList():String
		{
			var a:IptAtom = popValue();
			if(a.type == IptAtom.TYPE_ATOMLIST)
			{
				return getString(a.value);
			} else
			{
				invalidArg();
				return null;
			}
		}
		
		public function sf_STATUSMSG():void
		{
			var statStr:String = popString();
			pc.statusMessage(statStr);
		}
		
		public function sf_SOUND():void
		{
			pc.playSound(popString());
		}
		
		public function sf_POSX():void
		{
			pushInt(pc.getSelfPosX());
		}
		
		public function parseNumber():void
		{
			var numString:String = "";
			
			if(currentChar() == "-")
			{
				numString += "-";
				so++;
			}
			
			while(currentChar() >= '0' && currentChar() <= '9')
			{
				numString += currentChar();
				so++;
			}
			
			pushInt(parseInt(numString));
		}
		
		public function parseSymbol():void
		
		{
			var dp:int = 0;
			var sc:String = currentChar(); // Char
			var token:String = "";
			
			//while(sc != null && ((sc >= 'a' && sc <= 'z') || (sc >= 'A' && sc <= 'Z') || (sc >= '0' && sc <= '9') || sc == '_'))
			while(tokenTest.test(sc = currentChar()))
			{
				token += sc.toUpperCase();
				so++;
				sc = currentChar()
			}
			
			switch (token) {
				case "NOT":
					sf_NOT();
					break;
				case "AND":
					sf_AND();
					break;
				case "OR":
					sf_OR();
					break;
				case "EXEC":
					sf_EXEC();
					break;
				case "IF":
					sf_IF();
					break;
				case "IFELSE":
					sf_IFELSE();
					break;
				case "WHILE":
					sf_WHILE();
					break;
				case "GLOBAL":
					sf_GLOBAL();
					break;
				case "DEF":
					sf_DEF();
					break;
				case "RETURN":
					sf_RETURN();
					break;
				case "BREAK":
					sf_BREAK();
					break;
				case "DUP":
					sf_DUP();
					break;
				case "SWAP":
					sf_SWAP();
					break;
				case "POP":
					sf_POP();
					break;
				case "STRTOATOM":
					sf_STRTOATOM();
					break;
				case "SUBSTR":
					sf_SUBSTR();
					break;
				case "ITOA":
					sf_ITOA();
					break;
				case "ATOI":
					sf_ATOI();
					break;
				case "UPPERCASE":
					sf_UPPERCASE();
					break;
				case "LOWERCASE":
					sf_LOWERCASE();
					break;
				case "DELAY":
					sf_DELAY();
					break;
				case "RANDOM":
					sf_RANDOM();
					break;
				case "RND":
					sf_RANDOM();
					break;
				case "GREPSTR":
					sf_GREPSTR();
					break;
				case "GREPSUB":
					sf_GREPSUB();
					break;
				case "BEEP":
					sf_BEEP();
					break;
				case "DATETIME":
					sf_DATETIME();
					break;
				case "TICKS":
					sf_TICKS();
					break;
				case "SETALARM":
					sf_SETALARM();
					break;
				case "ALARMEXEC":
					sf_ALARMEXEC();
					break;
				case "GET":
					sf_GET();
					break;
				case "PUT":
					sf_PUT();
					break;
				case "ARRAY":
					sf_ARRAY();
					break;
				case "FOREACH":
					sf_FOREACH();
					break;
				case "LENGTH":
					sf_LENGTH();
					break;
				case "LOGMSG":
					sf_LOGMSG();
					break;
				case "GOTOROOM":
					sf_GOTOROOM();
					break;
				case "LOCK":
					sf_LOCK();
					break;
				case "SETPICLOC":
					sf_SETPICLOC();
					break;
				case "SETLOC":
					sf_SETLOC();
					break;
				case "SETSPOTSTATE":
					sf_SETSPOTSTATE();
					break;
				case "SETSPOTSTATELOCAL":
					sf_SETSPOTSTATELOCAL();
					break;
				case "GETSPOTSTATE":
					sf_GETSPOTSTATE();
					break;
				case "ADDLOOSEPROP":
					sf_ADDLOOSEPROP();
					break;
				case "TOPPROP":
					sf_TOPPROP();
					break;
				case "DROPPROP":
					sf_DROPPROP();
					break;
				case "DOFFPROP":
					sf_DOFFPROP();
					break;
				case "DONPROP":
					sf_DONPROP();
					break;
				case "REMOVEPROP":
					sf_REMOVEPROP();
					break;
				case "CLEARPROPS":
					sf_CLEARPROPS();
					break;
				case "NAKED":
					sf_CLEARPROPS();
					break;
				case "CLEARLOOSEPROPS":
					sf_CLEARLOOSEPROPS();
					break;
				case "SETCOLOR":
					sf_SETCOLOR();
					break;
				case "SETFACE":
					sf_SETFACE();
					break;
				case "UNLOCK":
					sf_UNLOCK();
					break;
				case "ISLOCKED":
					sf_ISLOCKED();
					break;
				case "GLOBALMSG":
					sf_GLOBALMSG();
					break;
				case "SAY":
					sf_SAY();
					break;
				case "ROOMMSG":
					sf_ROOMMSG();
					break;
				case "SUSRMSG":
					sf_SUSRMSG();
					break;
				case "LOCALMSG":
					sf_LOCALMSG();
					break;
				case "DEST":
					sf_DEST();
					break;
				case "ME":
					sf_ME();
					break;
				case "ID":
					sf_ME();
					break;
				case "LAUNCHAPP":
					sf_LAUNCHAPP();
					break;
				case "SHELLCMD":
					sf_SHELLCMD();
					break;
				case "KILLUSER":
					sf_KILLUSER();
					break;
				case "NETGOTO":
					sf_NETGOTO();
					break;
				case "GOTOURL":
					sf_NETGOTO();
					break;
				case "MACRO":
					sf_MACRO();
					break;
				case "MOVE":
					sf_MOVE();
					break;
				case "SETPOS":
					sf_SETPOS();
					break;
				case "INSPOT":
					sf_INSPOT();
					break;
				case "SHOWLOOSEPROPS":
					sf_SHOWLOOSEPROPS();
					break;
				case "SERVERNAME":
					sf_SERVERNAME();
					break;
				case "USERNAME":
					sf_USERNAME();
					break;
				case "SETPROPS":
					sf_SETPROPS();
					break;
				case "SELECT":
					sf_SELECT();
					break;
				case "NBRSPOTS":
					sf_NBRSPOTS();
					break;
				case "NBRDOORS":
					sf_NBRDOORS();
					break;
				case "DOORIDX":
					sf_DOORIDX();
					break;
				case "SPOTIDX":
					sf_SPOTIDX();
					break;
				case "WHOCHAT":
					sf_WHOCHAT();
					break;
				case "WHOME":
					sf_WHOME();
					break;
				case "POSX":
					sf_POSX();
					break;
				case "POSY":
					sf_POSY();
					break;
				case "PRIVATEMSG":
					sf_PRIVATEMSG();
					break;
				case "STATUSMSG":
					sf_STATUSMSG();
					break;
				case "SPOTDEST":
					sf_SPOTDEST();
					break;
				case "ISGUEST":
					sf_ISGUEST();
					break;
				case "ISWIZARD":
					sf_ISWIZARD();
					break;
				case "ISGOD":
					sf_ISGOD();
					break;
				case "DIMROOM":
					sf_DIMROOM();
					break;
				case "SPOTNAME":
					sf_SPOTNAME();
					break;
				case "SOUND":
					sf_SOUND();
					break;
				case "MIDIPLAY":
					sf_MIDIPLAY();
					break;
				case "MIDILOOP":
					sf_MIDILOOP();
					break;
				case "MIDISTOP":
					sf_MIDISTOP();
					break;
				case "HASPROP":
					sf_HASPROP();
					break;
				case "NBRUSERPROPS":
					sf_NBRUSERPROPS();
					break;
				case "USERPROP":
					sf_USERPROP();
					break;
				case "USERID":
					sf_USERID();
					break;
				case "WHOPOS":
					sf_WHOPOS();
					break;
				case "NBRROOMUSERS":
					sf_NBRROOMUSERS();
					break;
				case "ROOMUSER":
					sf_ROOMUSER();
					break;
				case "MOUSEPOS":
					sf_MOUSEPOS();
					break;
				case "SAYAT":
					sf_SAYAT();
					break;
				case "WHONAME":
					sf_WHONAME();
					break;
				case "WHOTARGET":
					sf_WHOTARGET();
					break;
				case "ROOMNAME":
					sf_ROOMNAME();
					break;
				case "ROOMID":
					sf_ROOMID();
					break;
				case "CLIENTTYPE":
					sf_CLIENTTYPE();
				case "LAUNCHPPA":
					sf_LAUNCHPPA();
					break;
				case "LOADJAVA":
					sf_LOADJAVA();
					break;
				case "TALKPPA":
					sf_TALKPPA();
					break;
				case "LAUNCHEVENT":
					sf_LAUNCHEVENT();
					break;
				default:
					pushNewAtom(IptAtom.TYPE_VARIABLE, addToStringTable(token));
			}
		}
		
		public function sf_CLIENTTYPE():void {
			pushString("OPENPALACE");
		}
		
		public function sf_SETPICLOC():void
		
		{
			var id:int = popInt();
			var y:int = popInt();
			var x:int = popInt();
			pc.setPicOffset(id, x, y);
		}
		
		public function sf_KILLUSER():void
		{
			var userID:int = popInt();
			pc.killUser(userID);
		}
		
		public function sf_SPOTIDX():void
		{
			pushInt(pc.getSpotIdByIndex(popInt()));
		}
		
		public function updateExternStringGlobal(variable:IptVariable):void
		{
			if(variable.name == "CHATSTR")
				pc.setChatString(getString(variable.value));
			else
				return;
		}
		
		public function assignVariable(variable:IptVariable, atom:IptAtom):void
		
		{
			atomToValue(atom);
			variable.type = atom.type;
			variable.value = atom.value;
			if((variable.flags & 1) > 0)
				updateGlobal(variable);
			else
			if((variable.flags & 2) > 0)
				updateExternStringGlobal(variable);
		}
		
		public function atomToGVariable(vName:String, atom:IptAtom):IptGVariable
		{
			var flags:int = 0;
			var data:Object;
			switch(atom.type)
			{
				case IptAtom.TYPE_ATOMLIST: // '\003'
				case IptAtom.TYPE_STRING: // '\004'  String
					data = getString(atom.value);
					break;
				
				case IptAtom.TYPE_ARRAY: // '\006'  Array
					data = arrayToGlobal(vName, atom.value);
					break;
				
				case 5: // '\005'  Unknown type??
				default:
					data = null;
					break;
			}
			return new IptGVariable(vName, atom.type, atom.value, flags, data);
		}
		
		public function addToStringTable(s:String):int
		{
			var size:int = strTable.length;
			var n:int;
			for(n = 0; n < size; n++)
			{
				var ts:String = strTable[n];
				if(ts == s)
					return n;
			}
			
			strTable.push(s);
			return n;
		}
		
		public function addToArrayTable(v:Array):int // Vector
		{
			var n:int = aryTable.length;
			aryTable.push(v);
			return n;
		}
		
		public function binaryOp(opType:String, a1:IptAtom, a2:IptAtom):void // char opType
		
		{
			var result:int = 0;
			var resultType:int = IptAtom.TYPE_INTEGER;
			atomToValue(a1);
			atomToValue(a2);
			switch(opType)
			{
				default:
					break;
				
				case "=": // '=' 61
					if(a1.type == IptAtom.TYPE_INTEGER && a2.type == IptAtom.TYPE_INTEGER)
					{
						result = a1.value == a2.value ? 1 : 0;
						break;
					}
					if(a1.type == IptAtom.TYPE_STRING && a2.type == IptAtom.TYPE_STRING)
						result = (getString(a1.value).toLocaleLowerCase() == getString(a2.value).toLocaleLowerCase()) ? 1 : 0;
					else
						result = 0;
					break;
				
				case "+": // '+' 43
					if(a1.type == IptAtom.TYPE_INTEGER && a2.type == IptAtom.TYPE_INTEGER)
					{
						result = a1.value + a2.value;
						break;
					}
					if(a1.type == IptAtom.TYPE_STRING && a2.type == IptAtom.TYPE_STRING)
					{
						result = addToStringTable(getString(a1.value) + getString(a2.value));
						resultType = IptAtom.TYPE_STRING;
					} else
					{
						result = 0;
					}
					break;
				
				case "-": // '-' 45
					result = a1.value - a2.value;
					break;
				
				case "*": // '*' 42
					result = a1.value * a2.value;
					break;
				
				case "/": // '/' 47
					result = a2.value == 0 ? 0 : Math.floor(a1.value / a2.value);
					break;
				
				case "%": // '%' 37
					result = a2.value == 0 ? 0 : int(a1.value % a2.value);
					break;
				
				case "<": // '<' 60
					result = a1.value < a2.value ? 1 : 0;
					break;
				
				case ">": // '>' 62
					result = a1.value > a2.value ? 1 : 0;
					break;
				
				case "b": // 'b' 98 (<=)
					result = a1.value <= a2.value ? 1 : 0;
					break;
				
				case "c": // 'c' 99 (>=)
					result = a1.value >= a2.value ? 1 : 0;
					break;
				
				case "a": // 'a' 97 (!=)
					result = a1.value != a2.value ? 1 : 0;
					break;
				
				case 38: // '&'
					if(a1.type == IptAtom.TYPE_STRING && a2.type == IptAtom.TYPE_STRING)
					{
						result = addToStringTable(getString(a1.value) + getString(a2.value));
						resultType = IptAtom.TYPE_STRING;
					} else
					{
						result = 0;
					}
					break;
			}
			pushNewAtom(resultType, result);
		}
		
		public function unaryOp(opType:String, a1:IptAtom):void
		{
			var result:int = 0;
			var resultType:int = IptAtom.TYPE_INTEGER;
			atomToValue(a1);
			
			if (opType == "!") {
				result = a1.value > 0 ? 0 : 1;
			}
			
			pushNewAtom(resultType, result);
		}
		
		public function globalizeVariable(variable:IptVariable ):void
		{
			variable.flags |= IptVariable.FLAG_GLOBAL;
		}
		
		public function assignVariableNewAtom(variable:IptVariable, type:int, value:int):void
		{
			assignVariable(variable, new IptAtom(type, value));
		}
		
		public function sf_POP():void
		{
			popAtom();
		}
		
		public function sf_NBRSPOTS():void
		{
			pushInt(pc.getNumSpots());
		}
		
		public function unaryAssignment(opType:String, a1:IptAtom):void // char opType
		{
			var v1:IptAtom = new IptAtom(a1.type, a1.value);
			atomToValue(v1);
			var v:IptVariable = getVariableByAtom(a1);
			switch(opType)
			{
				case "+": // '+'
					assignVariableNewAtom(v, v1.type, v1.value + 1);
					break;
				
				case "-": // '-'
					assignVariableNewAtom(v, v1.type, v1.value - 1);
					break;
			}
		}
		
		public function binaryAssignment(opType:String, n1:IptAtom, a1:IptAtom):void // char opType
		{
			atomToValue(n1);
			var v1:IptAtom = new IptAtom(a1.type, a1.value);
			atomToValue(v1);
			var v:IptVariable = getVariableByAtom(a1);
			switch(opType)
			{
				case "+": // '+'
					assignVariableNewAtom(v, v1.type, v1.value + n1.value);
					break;
				
				case "-": // '-'
					assignVariableNewAtom(v, v1.type, v1.value - n1.value);
					break;
				
				case "*": // '*'
					assignVariableNewAtom(v, v1.type, v1.value * n1.value);
					break;
				
				case "/": // '/'
					assignVariableNewAtom(v, v1.type, n1.value == 0 ? 0 : v1.value / n1.value);
					break;
				
				case "%": // '%'
					assignVariableNewAtom(v, v1.type, n1.value == 0 ? 0 : v1.value % n1.value);
					break;
				
				case "&": // '&'
					assignVariableNewAtom(v, 4, addToStringTable(getString(v1.value) + getString(n1.value)));
					break;
			}
		}
		
		public function pushString(s:String):void
		{
			pushNewAtom(4, addToStringTable(s));
		}
		
		public function popString():String
		{
			var a:IptAtom = popValue();
			if(a.type == IptAtom.TYPE_STRING)
			{
				return getString(a.value);
			} else
			{
				invalidArg();
				return null;
			}
		}
		
		public function getString(index:int):String
		{
			if (index >= 0 && index < strTable.length)
				return strTable[index];
			else
				return "";
		}
		
		public function sf_GLOBAL():void
		{
			var s1:IptAtom = popAtom();
			var v:IptVariable = getVariableByAtom(s1);
			globalizeVariable(v);
		}
		
		public function sf_UNLOCK():void
		{
			pc.unlock(popInt());
		}
		
		public function sf_SAYAT():void
		{
			var y:int = popInt();
			var x:int = popInt();
			var chatStr:String = popString();
			
			pc.chat("@" + x + "," + y + " " + chatStr);
		}
		
		public function popArray():Array // Vector
		{
			var a:IptAtom = popValue();
			if(a.type == IptAtom.TYPE_ARRAY)
			{
				return getArray(a.value);
			} else
			{
				invalidArg();
				return null;
			}
		}
		
		public function getArray(index:int):Array // Vector
		{
			if(index >= 0 && index < aryTable.length)
			{
				return aryTable[index];
			}
			else {
				forceAbort("Internal Error: Bad Array Reference");
				return null;
			}
		}
		
		public function sf_SETFACE():void
		{
			pc.setFace(popInt());
		}
		
		public function callSubroutine(index:int):void
		{
			if(abortScriptCode != 0)
				return;
			if(tsp.length >= 16)
				return;
			tsp.push(new IptFrame(si, so));
			si = index;
			so = 0;
			scriptStr = getString(index);
			runScript();
			var iFrame:IptFrame = IptFrame(tsp.pop());
			so = iFrame.offset;
			si = iFrame.index;
			scriptStr = getString(si);
			if(abortScriptCode == 2)
				abortScriptCode = 0;
		}
		
		public function sf_LOGMSG():void
		{
			var atom:IptAtom = popValue();
			if(atom.type == IptAtom.TYPE_STRING || atom.type == IptAtom.TYPE_ATOMLIST)
				pc.logMessage(getString(atom.value));
			else
				pc.logMessage(int(atom.value).toString());
		}
		
		public function sf_PRIVATEMSG():void
		{
			var whoID:int = popInt();
			var chatStr:String = popString();
			pc.sendPrivateMessage(chatStr, whoID);
		}
		
		public function sf_ADDLOOSEPROP():void
		{
			var y:int = popInt();
			var x:int = popInt();
			var id:int = 0;
			var p:IptAtom = popValue();
			if(p.type == IptAtom.TYPE_INTEGER)
				id = p.value;
			else
				if(p.type == IptAtom.TYPE_STRING)
					id = pc.getPropIdByName(getString(p.value));
			if(id != 0)
				pc.addLooseProp(id, x, y);
		}
		
		public function sf_CLEARLOOSEPROPS():void
		{
			pc.removeLooseProp(-1);
		}
		
		public function sf_SHOWLOOSEPROPS():void
		{
			pc.showLooseProps();
		}
		
		public function sf_WHOPOS():void
		{
			var a:IptAtom = popValue();
			var x:int = 0;
			var y:int = 0;
			var id:int = 0;
			if(a.type == IptAtom.TYPE_STRING)
				id = pc.getUserByName(getString(a.value));
			else
				if(a.type == IptAtom.TYPE_INTEGER)
					id = a.value;
			if(id != 0)
			{
				x = pc.getPosX(a.value);
				y = pc.getPosY(a.value);
			}
			pushInt(x);
			pushInt(y);
		}
		
		public function sf_ROOMID():void
		
		{
			pushInt(pc.getRoomId());
		}
		
		public function sf_SWAP():void
		
		{
			var p2:IptAtom = popAtom();
			var p1:IptAtom = popAtom();
			pushAtom(p2);
			pushAtom(p1);
		}
		
		public function sf_LAUNCHPPA():void
		{
			// No PalacePresents Support
			popString();
		}
		
		public function sf_TALKPPA():void
		{
			// No PalacePresents Support
			popString();
		}
		
		public function sf_ME():void
		{
			pushInt(pc.getCurrentSpotId());
		}
		
		public function sf_ALARMEXEC():void
		{
			var futureTime:int = popInt();
			var aList:String = popAtomList();
			pc.setScriptAlarm(aList, pc.getCurrentSpotId(), futureTime);
		}
		
		public function newVariable(sym:String):IptVariable
		{
			var vp:IptVariable = new IptVariable(sym, 1, 0, 0);
			if(sym == "CHATSTR")
			{
				vp.flags |= IptVariable.FLAG_SPECIAL_VARIABLE;
				retrieveExternStringGlobal(vp, 0);
			}
			vList[sym] = vp;
			return vp;
		}
		
		public function doScript(script:String):int
		{
			return runMessageScript(script);
		}
		
		public function sf_USERID():void
		{
			pushInt(pc.getSelfUserId());
		}
		
		public function sf_SETLOC():void
		{
			var id:int = popInt();
			var y:int = popInt();
			var x:int = popInt();
			pc.moveSpot(id, x, y);
		}
		
		public function sf_ROOMUSER():void
		{
			pushInt(pc.getRoomUserIdByIndex(popInt()));
		}
		
		public function retrieveExternStringGlobal(variable:IptVariable, index:int):void
		{
			var s:String = "";
			if(index == 0)
				s = pc.getChatString();
			variable.value = addToStringTable(s);
			variable.type = 4;
		}
		
		public function sf_NOT():void
		{
			pushInt(popInt() > 0 ? 0 : 1);
		}
		
		public function sf_DEST():void
		
		{
			pushInt(pc.getCurSpotDest());
		}
		
		public function invalidArg():void
		
		{
			forceAbort("Invalid argument");
		}
		
		public function sf_LOWERCASE():void
		
		{
			pushString(popString().toLowerCase());
		}
		
		public function sf_WHILE():void
		
		{
			var e1:IptAtom = popValue();
			var s1:IptAtom = popValue();
			var expResult:int;
			do
			{
				if(e1.type == IptAtom.TYPE_ATOMLIST)
				{
					callSubroutine(e1.value);
					expResult = popInt();
				} else
				{
					expResult = e1.value;
				}
				if(expResult != 0 && s1.type == IptAtom.TYPE_ATOMLIST)
					callSubroutine(s1.value);
			} while(expResult != 0 && abortScriptCode == 0);
			if(abortScriptCode == 1)
				abortScriptCode = 0;
		}
		
		public function sf_ATOI():void
		{
			var v:int;
			try
			{
				v = parseInt(popString());
			}
			catch(nfe:Error)
			{
				v = 0;
			}
			pushInt(v);
		}
		
		public function sf_SETALARM():void
		{
			var spotID:int = popInt();
			var futureTime:int = popInt();
			if(spotID == 0)
				spotID = pc.getCurrentSpotId();
			pc.setSpotAlarm(spotID, futureTime);
		}
		
		public function sf_RETURN():void
		{
			abortScriptCode = 2;
		}
		
		public function sf_SERVERNAME():void
		{
			pushString(pc.getServerName());
		}
		
		public function sf_AND():void
		{
			pushInt( (popInt() > 0 && popInt() > 0) ? 1 : 0 );
		}
		
		public function sf_ARRAY():void
		{
			var idx:int = popInt();
			if(idx >= 0)
			{
				var ary:Array = []; //Vector ary = new Vector(idx);
				for(var n:int = 0; n < idx; n++)
				{
					ary.push(new IptAtom(IptAtom.TYPE_INTEGER, 0));
					pushNewAtom(IptAtom.TYPE_ARRAY, addToArrayTable(ary));
				}
				
			} else
			{
				pushNewAtom(IptAtom.TYPE_INTEGER, 0);
			}
		}

	}
}