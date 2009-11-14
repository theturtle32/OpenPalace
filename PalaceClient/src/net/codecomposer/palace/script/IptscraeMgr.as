package net.codecomposer.palace.script
{
	import flash.utils.Dictionary;
	
	import net.codecomposer.palace.rpc.PalaceClient;

	public class IptscraeMgr implements IScriptMgr
	{
		public var pStack:Array; //Stack
		public var tsp:Array; // Stack
		public var strTable:Array; // Vector.<String>?
		public var aryTable:Array; // Vector.<Vector>?  Vector.<Array>?
		public var vList:Dictionary;
		public var gList:Dictionary;
		public var tbuf:Vector.<uint>; // char tbuf[]
		public var scriptStr:String;
		public var so:int;
		public var si:int;
		
		public function sf_NETGOTO():void
		{
			if(pc.pc_GotoURL(popString()) != 0)
				forceAbort("script contains bad URL");
		}
		
		public function sf_SHELLCMD():void
		{
			pc.pc_LaunchApp(popString());
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
			var dp:int = 0;
			if(sc() == '{')
				so++;
			while(sc() != 0 && (sc() != '}' || nest > 0)) 
			{
				if(qFlag)
				{
					if(sc() == '\\')
					{
						tbuf[dp++] = sc();
						so++;
					} else
						if(sc() == '"')
							qFlag = false;
				} else
				{
					switch(sc())
					{
						case 34: // '"'
							qFlag = true;
							break;
						
						case 123: // '{'
							nest++;
							break;
						
						case 125: // '}'
							nest--;
							break;
					}
				}
				tbuf[dp++] = sc();
				so++;
			}
			if(sc() == '}')
				so++;
			var index:int = addToStringTable(new String(tbuf, 0, dp));
			pushAtom(3, index);
		}
		
		public function sf_DEF():void
		{
			var s1:IptAtom = popAtom();
			var v:IptVariable = getVariable(s1);
			var t:IptAtom = popAtom();
			assignVariable(v, t);
		}
		
		public function sf_ITOA():void
		{
			pushString(Integer.toString(popInt()));
		}
		
		public function newGlobal(variable:IptVariable):void
		
		{
			var data:Object;
			switch(variable.type)
			{
				case 3: // '\003'
				case 4: // '\004'
				data = getString(variable.value);
				break;
				
				case 6: // '\006'
				data = arrayToGlobal(variable.name, variable.value);
				break;
				
				case 5: // '\005'
				default:
				data = null;
				break;
			}
			var gv:IptGVariable = new IptGVariable(variable.name, variable.type, variable.value, variable.flags, data);
			gList.put(((IptVariable) (gv)).name, gv);
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
			if(a1.type != 2)
				invalidArg();
			return getVariable(getString(a1.value));
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
			pushInt(pc.pc_GetWhoChat());
		}
		
		public function sf_MIDILOOP():void
		{
			var name:String = popString();
			var loopNbr:int = popInt();
			pc.pc_MidiLoop(loopNbr, name);
		}
		
		public function sf_SELECT():void
		{
			pc.pc_SelectHotspot(popInt());
		}
		
		public function sf_NBRDOORS():void
		{
			pushInt(pc.pc_GetNbrDoors());
		}
		
		public function sf_ISGUEST():void
		{
			pushInt(pc.pc_IsGuest() ? 1 : 0);
		}
		
		public function forceAbort(msg:String):void
		{
			abortScriptCode = 5;
			throw new IptscraeException(msg);
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
			if(pStack.size() > 0)
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
			var dimLevel:int = popInt();
			pc.pc_DimRoom(dimLevel);
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
			pushInt(pc.pc_GetPosY());
		}
		
		public function sf_TICKS():void
		{
			// TODO: Implement
			// pushInt((int)((System.currentTimeMillis() / 17L) % 0x4f1a00L));
		}
		
		public function sf_ISWIZARD():void
		{
			pushInt(pc.pc_IsWizard() ? 1 : 0);
		}
		
		public function sf_SETPOS():void
		{
			var y:int = popInt();
			var x:int = popInt();
			pc.pc_MoveUserAbs(x, y);
		}
		
		public function sf_TOPPROP():void
		{
			pushInt(pc.pc_GetTopProp());
		}
		
		public function sf_DROPPROP():void
		{
			var y:int = popInt();
			var x:int = popInt();
			pc.pc_DropProp(x, y);
		}
		
		public function sf_REMOVEPROP():void
		{
			var a:IptAtom = popValue();
			if(a.type == 1)
				pc.pc_DoffProp(a.value);
			else
				pc.pc_DoffProp(getString(a.value));
		}
		
		public function sf_CLEARPROPS():void
		{
			pc.pc_Naked();
		}
		
		public function sf_USERPROP():void
		{
			pushInt(pc.pc_GetUserProp(popInt()));
		}
		
		public function sf_MOUSEPOS():void
		{
			pushInt(pc.pc_GetMouseX());
			pushInt(pc.pc_GetMouseY());
		}
		
		public function sf_MOVE():void
		{
			var yDelta:int = popInt();
			var xDelta:int = popInt();
			pc.pc_MoveUserRel(xDelta, yDelta);
		}
		
		public function sf_GETSPOTSTATE():void
		{
			pushInt(pc.pc_GetSpotState(popInt()));
		}
		
		public function sf_SAY():void
		{
			var atom:IptAtom = popValue();
			if(atom.type == 4 || atom.type == 3)
				pc.pc_Chat(getString(atom.value));
			else
				pc.pc_Chat(Integer.toString(atom.value));
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
						pc.pc_ClearAlarms();
					scriptRunning = false;
					if(pStack.size() > 0)
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
				pc.pc_ClearAlarms();
				scriptRunning = false;
				completeAbort(ie.getMessage());
				initInterpreter();
			}
			return retVal;
		}
		
		public function runScript():void
		{
			if(abortScriptCode != 0)
				return;
			var sc:uint; // char
			while((sc = sc()) != 0 && abortScriptCode == 0) 
				if(sc == ' ' || sc == '\t' || sc == '\r' || sc == '\n' || sc == ';')
					so++;
				else
					if(sc == '#')
						while((sc = sc()) != 0 && sc != '\r' && sc != '\n') 
							so++;
					else
						if(sc == '{')
							parseAtomList();
						else
							if(sc == '"')
							{
								parseStringLiteral();
							} else
							{
								if(sc == '}')
									return;
								if(sc == '[')
								{
									so++;
									pushAtom(5, 0);
								} else
									if(sc == ']')
									{
										so++;
										pushAtom(6, popArrayDef());
									} else
										if(sc == '!')
										{
											if(sc(1) == '=')
											{
												var a2:IptAtom = popAtom();
												var a1:IptAtom = popAtom();
												binaryOp('a', a1, a2);
												so++;
												so++;
											} else
											{
												var a1:IptAtom = popAtom();
												unaryOp('!', a1);
												so++;
											}
										} else
											if(sc == '=')
											{
												if(sc(1) == '=')
												{
													var a2:IptAtom = popAtom();
													var a1:IptAtom = popAtom();
													binaryOp('=', a1, a2);
													so++;
													so++;
												} else
												{
													var a2:IptAtom = popAtom();
													var a1:IptAtom = popAtom();
													var v:IptVariable = getVariable(a2);
													assignVariable(v, a1);
													so++;
												}
											} else
												if(sc == '+')
												{
													if(sc(1) == '+')
													{
														var a1:IptAtom = popAtom();
														unaryAssignment('+', a1);
														so++;
														so++;
													} else
														if(sc(1) == '=')
														{
															var a2:IptAtom = popAtom();
															var a1:IptAtom = popAtom();
															binaryAssignment('+', a1, a2);
															so++;
															so++;
														} else
														{
															var a2:IptAtom = popAtom();
															var a1:IptAtom = popAtom();
															binaryOp('+', a1, a2);
															so++;
														}
												} else
													if(sc == '-' && (sc(1) < '0' || sc(1) > '9'))
													{
														if(sc(1) == '-')
														{
															var a1:IptAtom = popAtom();
															unaryAssignment('-', a1);
															so++;
															so++;
														} else
															if(sc(1) == '=')
															{
																var a2:IptAtom = popAtom();
																var a1:IptAtom = popAtom();
																binaryAssignment('-', a1, a2);
																so++;
																so++;
															} else
															{
																var a2:IptAtom = popAtom();
																var a1:IptAtom = popAtom();
																binaryOp('-', a1, a2);
																so++;
															}
													} else
														if(sc == '<')
														{
															var oper:String = '<'; // char
															if(sc(1) == '>')
															{
																oper = 'a';
																so++;
															} else
																if(sc(1) == '=')
																{
																	oper = 'b';
																	so++;
																}
															var a2:IptAtom = popAtom();
															var a1:IptAtom = popAtom();
															binaryOp(oper, a1, a2);
															so++;
														} else
															if(sc == '>')
															{
																var oper:String = '>';
																if(sc(1) == '=')
																{
																	oper = 'c';
																	so++;
																}
																var a2:IptAtom = popAtom();
																var a1:IptAtom = popAtom();
																binaryOp(oper, a1, a2);
																so++;
															} else
																if(sc == '*' || sc == '/' || sc == '&' || sc == '%')
																{
																	var oper:String = sc;
																	var a2:IptAtom = popAtom();
																	var a1:IptAtom = popAtom();
																	if(sc(1) == '=')
																	{
																		binaryAssignment(oper, a1, a2);
																		so++;
																	} else
																	{
																		binaryOp(oper, a1, a2);
																	}
																	so++;
																} else
																	if(sc == '-' || sc >= '0' && sc <= '9')
																		parseNumber();
																	else
																		if(sc == '_' || sc >= 'a' && sc <= 'z' || sc >= 'A' && sc <= 'Z')
																			parseSymbol();
																		else
																			forceAbort((new StringBuilder("Unexpected character: '")).append((new Character(sc)).toString()).append("'").toString());
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
				case 6: // '\006'
					ary = getArray(a.value);
					break;
				
				case 2: // '\002'
					var vt:IptGVariable = getVariable(a);
					if(vt != null)
						if((vt.flags & 1) > 0)
						{
							gv = IptGVariable(gList[vt.name]);
							if(gv != null)
							{
								ary = Array(gv.data);
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
			if(idx >= 0 && idx < ary.size())
				if(isGlobal)
					ary.setElementAt(atomToGVariable((new StringBuilder(String.valueOf(idx))).append("_").append(((IptVariable) (gv)).name).toString(), atom), idx);
				else
					ary.setElementAt(atom, idx);
		}
		
		public function sf_DOORIDX():void
		{
			pushInt(pc.pc_GetDoorIdx(popInt()));
		}
		
		public function sf_FOREACH():void
		{
			var ary:Array = popArray();
			var atomList:IptAtom = popValue();
			if(atomList.type != 3)
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
			pc.pc_Delay(popInt());
		}
		
		public function stop():void
		{
			pc.pc_ClearAlarms();
			scriptRunning = false;
			completeAbort("application stopped");
			initInterpreter();
		}
		
		public function sf_SETSPOTSTATELOCAL():void
		{
			var id:int = popInt();
			var state:int = popInt();
			pc.pc_SetSpotStateLocal(id, state);
		}
		
		public function sf_GET():void
		{
			var idx:int = popInt();
			var a:IptAtom = popAtom();
			var ary:Array = null; // Vector
			var isGlobal:Boolean = false;
			switch(a.type)
			{
				case 6: // '\006'
					ary = getArray(a.value);
					break;
				
				case 2: // '\002'
					var vt:IptVariable = getVariable(a);
					if(vt != null)
						if((vt.flags & 1) > 0)
						{
							var gv:IptGVariable = IptGVariable(gList[vt.name]);
							if(gv != null)
							{
								ary = Array(gv.data); // Vector
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
			if(idx >= 0 && idx < ary.size())
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
			pushInt(pc.pc_GetWhoTarget());
		}
		
		public function sf_BREAK():void
		{
			abortScriptCode = 1;
		}
		
		public function sf_BEEP():void
		{
			pc.pc_Beep();
		}
		
		public function sf_SPOTDEST():void
		{
			pushInt(pc.pc_GetSpotDest(popInt()));
		}
		
		public function sf_LAUNCHAPP():void
		{
			pc.pc_LaunchApp(popString());
		}
		
		public function sf_MACRO():void
		{
			pc.pc_DoMacro(popInt());
		}
		
		public function sf_IF():void
		{
			var expResult:int = popInt();
			var s1:IptAtom = popAtom();
			if(expResult != 0)
			{
				atomToValue(s1);
				if(s1.type == 3)
					callSubroutine(s1.value);
			}
		}
		
		public function sf_SETCOLOR():void
		{
			pc.pc_ChangeColor(popInt());
		}
		
		public function sf_SPOTNAME():void
		{
			pushString(pc.pc_GetSpotName(popInt()));
		}
		
		public function sf_WHONAME():void
		{
			pushString(pc.pc_GetUserName(popInt()));
		}
		
		public function sf_USERNAME():void
		{
			pushString(pc.pc_GetUserName());
		}
		
		public function sf_STRTOATOM():void
		{
			pushAtom(3, addToStringTable(popString()));
		}
		
		public function sf_RANDOM():void
		{
			pushInt( int(Math.random() * Number(popInt())) );
		}
		
		public function sf_DUP():void
		
		{
			if(pStack.size() > 0)
			{
				var p1:IptAtom = IptAtom(pStack.peek());
				pushAtom(p1.cloneAtom());
			}
		}
		
		public function retrieveGlobal(variable:IptVariable):void
		{
			var gv:IptGVariable = IptGVariable(gList[variable.name]);
			if(gv != null)
			{
				variable.type = IptVariable(gv).type;
				variable.value = IptVariable(gv).value;
				variable.flags = IptVariable(gv).flags;
				switch(variable.type)
				{
					case 3: // '\003'
					case 4: // '\004'
						variable.value = addToStringTable(String(gv.data));
						break;
					
					case 6: // '\006'
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
				// TODO: Port
				//var vName = (new StringBuilder(String.valueOf(i))).append("_").append(arrayName).toString();
				var vName = "";
				gAry.addElement(atomToGVariable(vName, atom));
			}
			
			return gAry;
		}
		
		public function sf_LAUNCHEVENT():void
		{
			pc.pc_LaunchEvent(popString());
		}
		
		public function sf_LOADJAVA():void
		{
			pc.pc_LoadJava(popString());
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
			do
			{
				a = popValue();
				if(a.type != 5)
					ary.insertElementAt(a, 0);
			} while(pStack.size() > 0 && a.type != 5);
			return addToArrayTable(ary);
		}
		
		public function sf_NBRROOMUSERS():void
		
		{
			pushInt(pc.pc_GetNbrRoomUsers());
		}
		
		public function IptscraeMgr(pc:PalaceClient) // PalaceCommander
		{
			pStack = []; // Stack
			tsp = []; // Stack
			strTable = []; // Vector
			aryTable = []; // Vector
			vList = new Dictionary();
			gList = new Dictionary();
			tbuf = []; // new char[4086];
			scriptStr = "";
			so = 0;
			si = 0;
			scriptRunning = false;
			abortScriptCode = 0;
			//grepCompiler = new Perl5Compiler();
			//grepMatcher = new Perl5Matcher();
			//grepPattern = null;
			grepInput = "";
			this.pc = pc;
			pc.setScriptManager(this);
			initInterpreter();
		}
		
		public function sf_DATETIME():void
		{
			//TODO: Port
			//pushInt((int)(System.currentTimeMillis() / 1000L));
		}
		
		public function completeAbort(msg:String):void
		{
			if(mErrorHandler != null)
				mErrorHandler.reportError((new StringBuilder("Aborting script: ")).append(msg).toString(), 0);
			abortScriptCode = 5;
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
				case 3: // '\003'
				case 4: // '\004'
					val = addToStringTable(String(gVar.data));
					break;
				
				case 6: // '\006'
					val = globalToArray(gVar.data as Array);
					break;
			}
			return new IptAtom(type, val);
		}
		
		public function sf_WHOME():void
		{
			pushInt(pc.pc_GetUserID());
		}
		
		public function sf_LOCK():void
		{
			var id:int = popInt();
			pc.pc_Lock(id);
		}
		
		public function sf_MIDISTOP():void
		{
			pc.pc_MidiStop();
		}
		
		public function sf_GOTOROOM():void
		{
			var dest:int = popInt();
			pc.pc_GotoRoom(dest);
		}
		
		public function sf_INSPOT():void
		{
			pushInt(pc.pc_InSpot(popInt()) ? 1 : 0);
		}
		
		public function sf_GLOBALMSG():void
		{
			pc.pc_GlobalMsg(popString());
		}
		
		public function sf_ROOMMSG():void
		{
			pc.pc_RoomMsg(popString());
		}
		
		public function sf_SUSRMSG():void
		{
			pc.pc_SusrMsg(popString());
		}
		
		public function sf_LOCALMSG():void
		{
			pc.pc_LocalMsg(popString());
		}
		
		public function sf_DONPROP():void
		{
			var a:IptAtom = popValue();
			if(a.type == 1)
				pc.pc_DonProp(a.value);
			else
				pc.pc_DonProp(getString(a.value));
		}
		
		public function sf_SETPROPS():void
		{
			var ary:Array = popArray(); // Vector
			pc.pc_SetProps(ary);
		}
		
		public function sf_HASPROP():void
		{
			var a:IptAtom = popValue();
			if(a.type == 1)
				pushInt(pc.pc_HasProp(a.value) ? 1 : 0);
			else
				if(a.type == 4)
					pushInt(pc.pc_HasProp(getString(a.value)) ? 1 : 0);
				else
					pushInt(0);
		}
		
		public function sf_ROOMNAME():void
		{
			pushString(pc.pc_GetRoomName());
		}
		
		public function sf_ISLOCKED():void
		{
			pushInt(pc.pc_IsLocked(popInt()) ? 1 : 0);
		}
		
		public function sf_SETSPOTSTATE():void
		{
			var id:int = popInt();
			var state:int = popInt();
			pc.pc_SetSpotState(id, state);
		}
		
		public function sf_MIDIPLAY():void
		{
			pc.pc_MidiPlay(popString());
		}
		
		public function sf_DOFFPROP():void
		{
			pc.pc_DoffProp();
		}
		
		public function sf_ISGOD():void
		{
			pushInt(pc.pc_IsGod() ? 1 : 0);
		}
		
		public function parseStringLiteral():void
		{
			// TODO: Port
			var dp:int = 0;
			if(sc() == '"')
				so++;
			while(sc() != 0 && sc() != '"') 
				if(sc() == '\\')
				{
					so++;
					if(sc() == 'x')
					{
						var c:String = '\0'; // char
						so++;
						c = (char)(sc() >= '0' && sc() <= '9' ? sc() - 48 : sc() >= 'a' && sc() <= 'f' ? (10 + sc()) - 97 : sc() >= 'A' && sc() <= 'F' ? (10 + sc()) - 65 : 0);
						c <<= '\004';
						so++;
						c |= sc() >= '0' && sc() <= '9' ? (char)(sc() - 48) : sc() >= 'a' && sc() <= 'f' ? (char)((10 + sc()) - 97) : sc() >= 'A' && sc() <= 'F' ? (char)((10 + sc()) - 65) : '\0';
						so++;
						tbuf[dp++] = c;
					} else
					{
						tbuf[dp++] = sc();
						so++;
					}
				} else
				{
					tbuf[dp++] = sc();
					so++;
				}
			if(sc() == '"')
				so++;
			pushString(new String(tbuf, 0, dp));
		}
		
		public function sf_UPPERCASE():void
		{
			pushString(popString().toUpperCase());
		}
		
		public function sf_GREPSUB():void
		{
			var replaceStr:String = popString();
			var result:String = "";
			if(grepPattern != null)
			{
				replaceSubst = new Perl5Substitution(replaceStr);
				result = Util.substitute(grepMatcher, grepPattern, replaceSubst, grepInput, -1);
			}
			pushString(result);
		}
		
		public function sf_LENGTH():void
		{
			var a:IptAtom = popAtom();
			var ary:Array = null; // Vector
			var isGlobal:Boolean = false;
			switch(a.type)
			{
				case 6: // '\006'
					ary = getArray(a.value);
					break;
				
				case 2: // '\002'
					var vt:IptVariable = getVariable(a);
					if(vt != null)
						if((vt.flags & 1) > 0)
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
			if(ary == null)
				invalidArg();
			pushInt(ary.size());
		}
		
		public function globalToArray(gAry:Array):int // Vector
		{
			var lAry:Array = []; // Vector
			for(var i:int = 0; i < gAry.length; i++)
			{
				var gvar:IptGVariable = IptGVariable(gAry[i]);
				var atom:IptAtom = gVariableToAtom(gvar);
				lAry.addElement(atom);
			}
			
			return addToArrayTable(lAry);
		}
		
		public function atomToValue(atom:IptAtom):IptAtom
		
		{
			if(atom.type == 2)
			{
				var vt:IptVariable = getVariable(atom);
				if(vt != null)
				{
					if((vt.flags & 1) > 0)
						retrieveGlobal(vt);
					else
						if((vt.flags & 2) > 0)
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
		
		public function pushInt(v:int):void
		{
			pushAtom(1, v);
		}
		
		public function initInterpreter():void
		{
			scriptRunning = false;
			tsp.removeAllElements();
			pStack.removeAllElements();
			vList.clear();
			strTable.removeAllElements();
			aryTable.removeAllElements();
		}
		
		public function sf_NBRUSERPROPS():void
		
		{
			pushInt(pc.pc_GetNbrUserProps());
		}
		
		public function retrieveExternStringGlobalByName(variable:IptVariable ):void
		{
			if(variable.name.equals("CHATSTR"))
				retrieveExternStringGlobal(variable, 0);
		}
		
		public function sc():String // char
		{
			return sc(0);
		}
		
		public function scByOffset(offset:int):String // char
		{
			if(so + offset < 0 || so + offset >= scriptStr.length())
				return '\0';
			else
				return scriptStr.charAt(so + offset);
		}
		
		public function popAtomList():String
		{
			var a:IptAtom = popValue();
			if(a.type == 3)
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
			pc.pc_StatusMsg(statStr);
		}
		
		public function sf_SOUND():void
		{
			pc.pc_PlaySound(popString());
		}
		
		public function sf_POSX():void
		{
			pushInt(pc.pc_GetPosX());
		}
		
		public function parseNumber():void
		{
			var n:int = 0;
			var negFlag:Boolean = false;
			if(sc() == '-')
			{
				negFlag = true;
				so++;
			}
			while(sc() >= '0' && sc() <= '9') 
			{
				n *= 10;
				n += sc() - 48;
				so++;
			}
			if(negFlag)
				n = -n;
			pushInt(n);
		}
		
		public function parseSymbol():void
		
		{
			var dp:int = 0;
			var sc:String; // Char
			while((sc = sc()) >= 'a' && sc <= 'z' || sc >= 'A' && sc <= 'Z' || sc >= '0' && sc <= '9' || sc == '_') 
			{
				so++;
				if(Character.isLowerCase(sc))
					sc = Character.toUpperCase(sc);
				tbuf[dp++] = sc;
			}
			var token:String = new String(tbuf, 0, dp);
			if(token.equals("NOT"))
				sf_NOT();
			else
				if(token.equals("AND"))
					sf_AND();
				else
					if(token.equals("OR"))
						sf_OR();
					else
						if(token.equals("EXEC"))
							sf_EXEC();
						else
							if(token.equals("IF"))
								sf_IF();
							else
								if(token.equals("IFELSE"))
									sf_IFELSE();
								else
									if(token.equals("WHILE"))
										sf_WHILE();
									else
										if(token.equals("GLOBAL"))
											sf_GLOBAL();
										else
											if(token.equals("DEF"))
												sf_DEF();
											else
												if(token.equals("RETURN"))
													sf_RETURN();
												else
													if(token.equals("BREAK"))
														sf_BREAK();
													else
														if(token.equals("DUP"))
															sf_DUP();
														else
															if(token.equals("SWAP"))
																sf_SWAP();
															else
																if(token.equals("POP"))
																	sf_POP();
																else
																	if(token.equals("STRTOATOM"))
																		sf_STRTOATOM();
																	else
																		if(token.equals("SUBSTR"))
																			sf_SUBSTR();
																		else
																			if(token.equals("ITOA"))
																				sf_ITOA();
																			else
																				if(token.equals("ATOI"))
																					sf_ATOI();
																				else
																					if(token.equals("UPPERCASE"))
																						sf_UPPERCASE();
																					else
																						if(token.equals("LOWERCASE"))
																							sf_LOWERCASE();
																						else
																							if(token.equals("DELAY"))
																								sf_DELAY();
																							else
																								if(token.equals("RANDOM"))
																									sf_RANDOM();
																								else
																									if(token.equals("RND"))
																										sf_RANDOM();
																									else
																										if(token.equals("GREPSTR"))
																											sf_GREPSTR();
																										else
																											if(token.equals("GREPSUB"))
																												sf_GREPSUB();
																											else
																												if(token.equals("BEEP"))
																													sf_BEEP();
																												else
																													if(token.equals("DATETIME"))
																														sf_DATETIME();
																													else
																														if(token.equals("TICKS"))
																															sf_TICKS();
																														else
																															if(token.equals("SETALARM"))
																																sf_SETALARM();
																															else
																																if(token.equals("ALARMEXEC"))
																																	sf_ALARMEXEC();
																																else
																																	if(token.equals("GET"))
																																		sf_GET();
																																	else
																																		if(token.equals("PUT"))
																																			sf_PUT();
																																		else
																																			if(token.equals("ARRAY"))
																																				sf_ARRAY();
																																			else
																																				if(token.equals("FOREACH"))
																																					sf_FOREACH();
																																				else
																																					if(token.equals("LENGTH"))
																																						sf_LENGTH();
																																					else
																																						if(token.equals("LOGMSG"))
																																							sf_LOGMSG();
																																						else
																																							if(token.equals("GOTOROOM"))
																																								sf_GOTOROOM();
																																							else
																																								if(token.equals("LOCK"))
																																									sf_LOCK();
																																								else
																																									if(token.equals("SETPICLOC"))
																																										sf_SETPICLOC();
																																									else
																																										if(token.equals("SETLOC"))
																																											sf_SETLOC();
																																										else
																																											if(token.equals("SETSPOTSTATE"))
																																												sf_SETSPOTSTATE();
																																											else
																																												if(token.equals("SETSPOTSTATELOCAL"))
																																													sf_SETSPOTSTATELOCAL();
																																												else
																																													if(token.equals("GETSPOTSTATE"))
																																														sf_GETSPOTSTATE();
																																													else
																																														if(token.equals("ADDLOOSEPROP"))
																																															sf_ADDLOOSEPROP();
																																														else
																																															if(token.equals("TOPPROP"))
																																																sf_TOPPROP();
																																															else
																																																if(token.equals("DROPPROP"))
																																																	sf_DROPPROP();
																																																else
																																																	if(token.equals("DOFFPROP"))
																																																		sf_DOFFPROP();
																																																	else
																																																		if(token.equals("DONPROP"))
																																																			sf_DONPROP();
																																																		else
																																																			if(token.equals("REMOVEPROP"))
																																																				sf_REMOVEPROP();
																																																			else
																																																				if(token.equals("CLEARPROPS"))
																																																					sf_CLEARPROPS();
																																																				else
																																																					if(token.equals("NAKED"))
																																																						sf_CLEARPROPS();
																																																					else
																																																						if(token.equals("CLEARLOOSEPROPS"))
																																																							sf_CLEARLOOSEPROPS();
																																																						else
																																																							if(token.equals("SETCOLOR"))
																																																								sf_SETCOLOR();
																																																							else
																																																								if(token.equals("SETFACE"))
																																																									sf_SETFACE();
																																																								else
																																																									if(token.equals("UNLOCK"))
																																																										sf_UNLOCK();
																																																									else
																																																										if(token.equals("ISLOCKED"))
																																																											sf_ISLOCKED();
																																																										else
																																																											if(token.equals("GLOBALMSG"))
																																																												sf_GLOBALMSG();
																																																											else
																																																												if(token.equals("SAY"))
																																																													sf_SAY();
																																																												else
																																																													if(token.equals("ROOMMSG"))
																																																														sf_ROOMMSG();
																																																													else
																																																														if(token.equals("SUSRMSG"))
																																																															sf_SUSRMSG();
																																																														else
																																																															if(token.equals("LOCALMSG"))
																																																																sf_LOCALMSG();
																																																															else
																																																																if(token.equals("DEST"))
																																																																	sf_DEST();
																																																																else
																																																																	if(token.equals("ME"))
																																																																		sf_ME();
																																																																	else
																																																																		if(token.equals("ID"))
																																																																			sf_ME();
																																																																		else
																																																																			if(token.equals("LAUNCHAPP"))
																																																																				sf_LAUNCHAPP();
																																																																			else
																																																																				if(token.equals("SHELLCMD"))
																																																																					sf_SHELLCMD();
																																																																				else
																																																																					if(token.equals("KILLUSER"))
																																																																						sf_KILLUSER();
																																																																					else
																																																																						if(token.equals("NETGOTO"))
																																																																							sf_NETGOTO();
																																																																						else
																																																																							if(token.equals("GOTOURL"))
																																																																								sf_NETGOTO();
																																																																							else
																																																																								if(token.equals("MACRO"))
																																																																									sf_MACRO();
																																																																								else
																																																																									if(token.equals("MOVE"))
																																																																										sf_MOVE();
																																																																									else
																																																																										if(token.equals("SETPOS"))
																																																																											sf_SETPOS();
																																																																										else
																																																																											if(token.equals("INSPOT"))
																																																																												sf_INSPOT();
																																																																											else
																																																																												if(token.equals("SHOWLOOSEPROPS"))
																																																																													sf_SHOWLOOSEPROPS();
																																																																												else
																																																																													if(token.equals("SERVERNAME"))
																																																																														sf_SERVERNAME();
																																																																													else
																																																																														if(token.equals("USERNAME"))
																																																																															sf_USERNAME();
																																																																														else
																																																																															if(token.equals("SETPROPS"))
																																																																																sf_SETPROPS();
																																																																															else
																																																																																if(token.equals("SELECT"))
																																																																																	sf_SELECT();
																																																																																else
																																																																																	if(token.equals("NBRSPOTS"))
																																																																																		sf_NBRSPOTS();
																																																																																	else
																																																																																		if(token.equals("NBRDOORS"))
																																																																																			sf_NBRDOORS();
																																																																																		else
																																																																																			if(token.equals("DOORIDX"))
																																																																																				sf_DOORIDX();
																																																																																			else
																																																																																				if(token.equals("SPOTIDX"))
																																																																																					sf_SPOTIDX();
																																																																																				else
																																																																																					if(token.equals("WHOCHAT"))
																																																																																						sf_WHOCHAT();
																																																																																					else
																																																																																						if(token.equals("WHOME"))
																																																																																							sf_WHOME();
																																																																																						else
																																																																																							if(token.equals("POSX"))
																																																																																								sf_POSX();
																																																																																							else
																																																																																								if(token.equals("POSY"))
																																																																																									sf_POSY();
																																																																																								else
																																																																																									if(token.equals("PRIVATEMSG"))
																																																																																										sf_PRIVATEMSG();
																																																																																									else
																																																																																										if(token.equals("STATUSMSG"))
																																																																																											sf_STATUSMSG();
																																																																																										else
																																																																																											if(token.equals("SPOTDEST"))
																																																																																												sf_SPOTDEST();
																																																																																											else
																																																																																												if(token.equals("ISGUEST"))
																																																																																													sf_ISGUEST();
																																																																																												else
																																																																																													if(token.equals("ISWIZARD"))
																																																																																														sf_ISWIZARD();
																																																																																													else
																																																																																														if(token.equals("ISGOD"))
																																																																																															sf_ISGOD();
																																																																																														else
																																																																																															if(token.equals("DIMROOM"))
																																																																																																sf_DIMROOM();
																																																																																															else
																																																																																																if(token.equals("SPOTNAME"))
																																																																																																	sf_SPOTNAME();
																																																																																																else
																																																																																																	if(token.equals("SOUND"))
																																																																																																		sf_SOUND();
																																																																																																	else
																																																																																																		if(token.equals("MIDIPLAY"))
																																																																																																			sf_MIDIPLAY();
																																																																																																		else
																																																																																																			if(token.equals("MIDILOOP"))
																																																																																																				sf_MIDILOOP();
																																																																																																			else
																																																																																																				if(token.equals("MIDISTOP"))
																																																																																																					sf_MIDISTOP();
																																																																																																				else
																																																																																																					if(token.equals("HASPROP"))
																																																																																																						sf_HASPROP();
																																																																																																					else
																																																																																																						if(token.equals("NBRUSERPROPS"))
																																																																																																							sf_NBRUSERPROPS();
																																																																																																						else
																																																																																																							if(token.equals("USERPROP"))
																																																																																																								sf_USERPROP();
																																																																																																							else
																																																																																																								if(token.equals("USERID"))
																																																																																																									sf_USERID();
																																																																																																								else
																																																																																																									if(token.equals("WHOPOS"))
																																																																																																										sf_WHOPOS();
																																																																																																									else
																																																																																																										if(token.equals("NBRROOMUSERS"))
																																																																																																											sf_NBRROOMUSERS();
																																																																																																										else
																																																																																																											if(token.equals("ROOMUSER"))
																																																																																																												sf_ROOMUSER();
																																																																																																											else
																																																																																																												if(token.equals("MOUSEPOS"))
																																																																																																													sf_MOUSEPOS();
																																																																																																												else
																																																																																																													if(token.equals("SAYAT"))
																																																																																																														sf_SAYAT();
																																																																																																													else
																																																																																																														if(token.equals("WHONAME"))
																																																																																																															sf_WHONAME();
																																																																																																														else
																																																																																																															if(token.equals("WHOTARGET"))
																																																																																																																sf_WHOTARGET();
																																																																																																															else
																																																																																																																if(token.equals("ROOMNAME"))
																																																																																																																	sf_ROOMNAME();
																																																																																																																else
																																																																																																																	if(token.equals("ROOMID"))
																																																																																																																		sf_ROOMID();
																																																																																																																	else
																																																																																																																		if(token.equals("LAUNCHPPA"))
																																																																																																																			sf_LAUNCHPPA();
																																																																																																																		else
																																																																																																																			if(token.equals("LOADJAVA"))
																																																																																																																				sf_LOADJAVA();
																																																																																																																			else
																																																																																																																				if(token.equals("TALKPPA"))
																																																																																																																					sf_TALKPPA();
																																																																																																																				else
																																																																																																																					if(token.equals("LAUNCHEVENT"))
																																																																																																																						sf_LAUNCHEVENT();
																																																																																																																					else
																																																																																																																						pushAtom(2, addToStringTable(token));
		}
		
		public function sf_SETPICLOC():void
		
		{
			var id:int = popInt();
			var y:int = popInt();
			var x:int = popInt();
			pc.pc_SetPicOffset(id, x, y);
		}
		
		public function sf_KILLUSER():void
		{
			var userID:int = popInt();
			pc.pc_KillUser(userID);
		}
		
		public function sf_SPOTIDX():void
		{
			pushInt(pc.pc_GetSpotIdx(popInt()));
		}
		
		public function updateExternStringGlobal(variable:IptVariable):void
		{
			if(variable.name.equals("CHATSTR"))
				pc.pc_SetChatString(getString(variable.value));
			else
				return;
		}
		
		public function assignVariable(variable:IptVariable , atom:IptAtom ):void
		
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
				case 3: // '\003'
				case 4: // '\004'
					data = getString(atom.value);
					break;
				
				case 6: // '\006'
					data = arrayToGlobal(vName, atom.value);
					break;
				
				case 5: // '\005'
				default:
					data = null;
					break;
			}
			return new IptGVariable(vName, atom.type, atom.value, flags, data);
		}
		
		public function addToStringTable(s:String):int
		{
			var size:int = strTable.size();
			var n:int;
			for(n = 0; n < size; n++)
			{
				var ts:String = String(strTable[n]);
				if(ts.equals(s))
					return n;
			}
			
			strTable.addElement(s);
			return n;
		}
		
		public function addToArrayTable(v:Array):int // Vector
		{
			var n:int = aryTable.length;
			aryTable.addElement(v);
			return n;
		}
		
		public function binaryOp(opType:String, a1:IptAtom, a2:IptAtom):void // char opType
		
		{
			var result:int = 0;
			var resultType:int = 1;
			atomToValue(a1);
			atomToValue(a2);
			switch(opType)
			{
				default:
					break;
				
				case 61: // '='
					if(a1.type == 1 && a2.type == 1)
					{
						result = a1.value == a2.value ? 1 : 0;
						break;
					}
					if(a1.type == 4 && a2.type == 4)
						result = getString(a1.value).equalsIgnoreCase(getString(a2.value)) ? 1 : 0;
					else
						result = 0;
					break;
				
				case 43: // '+'
					if(a1.type == 1 && a2.type == 1)
					{
						result = a1.value + a2.value;
						break;
					}
					if(a1.type == 4 && a2.type == 4)
					{
						result = addToStringTable((new StringBuilder(String.valueOf(getString(a1.value)))).append(getString(a2.value)).toString());
						resultType = 4;
					} else
					{
						result = 0;
					}
					break;
				
				case 45: // '-'
					result = a1.value - a2.value;
					break;
				
				case 42: // '*'
					result = a1.value * a2.value;
					break;
				
				case 47: // '/'
					result = a2.value == 0 ? 0 : a1.value / a2.value;
					break;
				
				case 37: // '%'
					result = a2.value == 0 ? 0 : a1.value % a2.value;
					break;
				
				case 60: // '<'
					result = a1.value < a2.value ? 1 : 0;
					break;
				
				case 62: // '>'
					result = a1.value > a2.value ? 1 : 0;
					break;
				
				case 98: // 'b'
					result = a1.value <= a2.value ? 1 : 0;
					break;
				
				case 99: // 'c'
					result = a1.value >= a2.value ? 1 : 0;
					break;
				
				case 97: // 'a'
					result = a1.value != a2.value ? 1 : 0;
					break;
				
				case 38: // '&'
					if(a1.type == 4 && a2.type == 4)
					{
						result = addToStringTable((new StringBuilder(String.valueOf(getString(a1.value)))).append(getString(a2.value)).toString());
						resultType = 4;
					} else
					{
						result = 0;
					}
					break;
			}
			pushAtom(resultType, result);
		}
		
		public function unaryOp(opType:String, a1:IptAtom):void
		{
			var result:int = 0;
			var resultType:int = 1;
			atomToValue(a1);
			switch(opType)
			{
				case 33: // '!'
					result = a1.value > 0 ? 0 : 1;
					break;
			}
			pushAtom(resultType, result);
		}
		
		public function globalizeVariable(variable:IptVariable ):void
		{
			variable.flags |= 1;
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
			pushInt(pc.pc_GetNbrSpots());
		}
		
		public function unaryAssignment(opType:String, a1:IptAtom):void // char opType
		{
			var v1:IptAtom = new IptAtom(a1.type, a1.value);
			atomToValue(v1);
			var v:IptVariable = getVariable(a1);
			switch(opType)
			{
				case 43: // '+'
					assignVariable(v, v1.type, v1.value + 1);
					break;
				
				case 45: // '-'
					assignVariable(v, v1.type, v1.value - 1);
					break;
			}
		}
		
		public function binaryAssignment(opType:String, n1:IptAtom, a1:IptAtom):void // char opType
		{
			atomToValue(n1);
			var v1:IptAtom = new IptAtom(a1.type, a1.value);
			atomToValue(v1);
			var v:IptVariable = getVariable(a1);
			switch(opType)
			{
				case 43: // '+'
					assignVariable(v, v1.type, v1.value + n1.value);
					break;
				
				case 45: // '-'
					assignVariable(v, v1.type, v1.value - n1.value);
					break;
				
				case 42: // '*'
					assignVariable(v, v1.type, v1.value * n1.value);
					break;
				
				case 47: // '/'
					assignVariable(v, v1.type, n1.value == 0 ? 0 : v1.value / n1.value);
					break;
				
				case 37: // '%'
					assignVariable(v, v1.type, n1.value == 0 ? 0 : v1.value % n1.value);
					break;
				
				case 38: // '&'
					assignVariable(v, 4, addToStringTable((new StringBuilder(String.valueOf(getString(v1.value)))).append(getString(n1.value)).toString()));
					break;
			}
		}
		
		public function pushString(s:String):void
		{
			pushAtom(4, addToStringTable(s));
		}
		
		public function popString():String
		{
			var a:IptAtom = popValue();
			if(a.type == 4)
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
			if(index >= 0 && index < strTable.length)
				return String(strTable[index]);
			else
			return "";
		}
		
		public function sf_GLOBAL():void
		
		{
			var s1:IptAtom = popAtom();
			var v:IptVariable = getVariable(s1);
			globalizeVariable(v);
		}
		
		public function sf_UNLOCK():void
		{
			var id:int = popInt();
			pc.pc_Unlock(id);
		}
		
		public function sf_SAYAT():void
		{
			var y:int = popInt();
			var x:int = popInt();
			var chatStr:String = popString();
			// TODO: Port
			//pc.pc_Chat((new StringBuilder("@")).append(x).append(",").append(y).append(" ").append(chatStr).toString());
		}
		
		public function popArray():Array // Vector
		{
			var a:IptAtom = popValue();
			if(a.type == 6)
			{
				return getArray(a.value);
			} else
			{
				invalidArg();
				return null;
			}
		}
		
		public function getArray(index:int) // Vector
		{
			if(index >= 0 && index < aryTable.length)
			{
				return aryTable[index] as Array;
				//return (Vector)(Vector)aryTable.elementAt(index);
			} else
			{
				forceAbort("Internal Error: Bad Array Reference");
				return null;
			}
		}
		
		public function sf_SETFACE():void
		{
			pc.pc_ChangeFace(popInt());
		}
		
		public function callSubroutine(index:int):void
		{
			if(abortScriptCode != 0)
				return;
			if(tsp.size() >= 16)
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
			if(atom.type == 4 || atom.type == 3)
				pc.pc_LogMessage(getString(atom.value));
			else
				pc.pc_LogMessage(Integer.toString(atom.value));
		}
		
		public function sf_PRIVATEMSG():void
		{
			var whoID:int = popInt();
			var chatStr:String = popString();
			pc.pc_PrivateMsg(whoID, chatStr);
		}
		
		public function sf_ADDLOOSEPROP():void
		{
			var y:int = popInt();
			var x:int = popInt();
			var id:int = 0;
			var p:IptAtom = popValue();
			if(p.type == 1)
				id = p.value;
			else
				if(p.type == 4)
					id = pc.pc_GetPropIDByName(getString(p.value));
			if(id != 0)
				pc.pc_AddLooseProp(id, x, y);
		}
		
		public function sf_CLEARLOOSEPROPS():void
		{
			pc.pc_DelLooseProp(-1);
		}
		
		public function sf_SHOWLOOSEPROPS():void
		{
			pc.pc_ShowLooseProps();
		}
		
		public function sf_WHOPOS():void
		{
			var a:IptAtom = popValue();
			var x:int = 0;
			var y:int = 0;
			var id:int = 0;
			if(a.type == 4)
				id = pc.pc_GetUserByName(getString(a.value));
			else
				if(a.type == 1)
					id = a.value;
			if(id != 0)
			{
				x = pc.pc_GetPosX(a.value);
				y = pc.pc_GetPosY(a.value);
			}
			pushInt(x);
			pushInt(y);
		}
		
		public function sf_ROOMID():void
		
		{
			pushInt(pc.pc_GetRoomID());
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
			pc.pc_LaunchPPA(popString());
		}
		
		public function sf_TALKPPA():void
		{
			pc.pc_TalkPPA(popString());
		}
		
		public function sf_ME():void
		{
			pushInt(pc.pc_GetCurSpotID());
		}
		
		public function sf_ALARMEXEC():void
		{
			var futureTime:int = popInt();
			var aList:String = popAtomList();
			pc.pc_SetScriptAlarm(aList, pc.pc_GetCurSpotID(), futureTime);
		}
		
		public function newVariable(sym:String):IptVariable
		{
			var vp:IptVariable = new IptVariable(sym, 1, 0, 0);
			if(sym.equals("CHATSTR"))
			{
				vp.flags |= 2;
				retrieveExternStringGlobal(vp, 0);
			}
			vList.put(sym, vp);
			return vp;
		}
		
		public function doScript(script:String):int
		{
			return runMessageScript(script);
		}
		
		public function sf_USERID():void
		{
			pushInt(pc.pc_GetUserID());
		}
		
		public function sf_SETLOC():void
		{
			var id:int = popInt();
			var y:int = popInt();
			var x:int = popInt();
			pc.pc_SetLoc(id, x, y);
		}
		
		public function sf_ROOMUSER():void
		{
			pushInt(pc.pc_GetRoomUser(popInt()));
		}
		
		public function retrieveExternStringGlobal(variable:IptVariable, index:int):void
		{
			var s:String = "";
			if(index == 0)
				s = pc.pc_GetChatString();
			variable.value = addToStringTable(s);
			variable.type = 4;
		}
		
		public function sf_NOT():void
		{
			pushInt(popInt() > 0 ? 0 : 1);
		}
		
		public function sf_DEST():void
		
		{
			pushInt(pc.pc_GetSpotDest());
		}
		
		public function invalidArg():void
		
		{
			forceAbort("Invalid argument");
		}
		
		public function sf_GREPSTR():void
		
		{
			var pat:String = popString();
			var grepInput:String = popString();
			try
			{
				grepPattern = grepCompiler.compile(pat);
			}
			catch(e:Error)
			{
				grepPattern = null;
				forceAbort("Bad GREPSTR Pattern");
			}
			pushInt(grepMatcher.contains(grepInput, grepPattern) ? 1 : 0);
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
				if(e1.type == 3)
				{
					callSubroutine(e1.value);
					expResult = popInt();
				} else
				{
					expResult = e1.value;
				}
				if(expResult != 0 && s1.type == 3)
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
				v = Integer.parseInt(popString());
			}
			catch(nfe:Error)
			{
				v = 0;
			}
			pushInt(v);
		}
		
		public function sf_SETALARM():void
		{
			var spotId:int;
			var futureTime:int;
			var spotID:int = popInt();
			var futureTime:int = popInt();
			if(spotID == 0)
				spotID = pc.pc_GetCurSpotID();
			pc.pc_SetSpotAlarm(spotID, futureTime);
		}
		
		public function sf_RETURN():void
		{
			abortScriptCode = 2;
		}
		
		public function sf_SERVERNAME():void
		{
			pushString(pc.pc_GetServerName());
		}
		
		public function sf_AND():void
		{
			pushInt(popInt() > 0 && popInt() > 0 ? 1 : 0);
		}
		
		public function sf_ARRAY():void
		{
			var idx:int = popInt();
			if(idx >= 0)
			{
				var ary:Array = []; //Vector ary = new Vector(idx);
				for(var n:int = 0; n < idx; n++)
				{
					ary.addElement(new IptAtom(1, 0));
					pushAtom(6, addToArrayTable(ary));
				}
				
			} else
			{
				pushAtom(1, 0);
			}
		}

	}
}