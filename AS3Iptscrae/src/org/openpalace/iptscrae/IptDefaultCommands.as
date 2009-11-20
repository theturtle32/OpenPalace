package org.openpalace.iptscrae
{
	import org.openpalace.iptscrae.command.*;
	import org.openpalace.iptscrae.command.operator.*;

	public final class IptDefaultCommands
	{
		public static const commands:Object = {
			"_TRACE": TRACECommand,
			"ALARMEXEC": ALARMEXECCommand,
			"AND": LogicalAndOperator,
			"ARRAY": ARRAYCommand,
			"ATOI": ATOICommand,
			"BEEP": BEEPCommand,
			"BREAK": BREAKCommand,
			"DATETIME": DATETIMECommand,
			"DEF": AssignOperator,
			"DUP": DUPCommand,
			"EXEC": EXECCommand,
			"EXIT": EXITCommand,
			"FOREACH": FOREACHCommand,
			"GET": GETCommand,
			"GLOBAL": GLOBALCommand,
			"GREPSTR": GREPSTRCommand,
			"GREPSUB": GREPSUBCommand,
			"IF": IFCommand,
			"IFELSE": IFELSECommand,
			"IPTVERSION": IPTVERSIONCommand,
			"ITOA": ITOACommand,
			"LENGTH": LENGTHCommand,
			"LOWERCASE": LOWERCASECommand,
			"NOT": LogicalNotOperator,
			"OR": LogicalOrOperator,
			"OVER": OVERCommand,
			"PICK": PICKCommand,
			"PUT": PUTCommand,
			"RETURN": RETURNCommand,
			"STACKDEPTH": STACKDEPTHCommand,
			"STRLEN": STRLENCommand,
			"STRTOATOM": STRTOATOMCommand,
			"SWAP": SWAPCommand,
			"TICKS": TICKSCommand,
			"TOPTYPE": TOPTYPECommand,
			"UPPERCASE": UPPERCASECommand,
			"VARTYPE": VARTYPECommand,
			"WHILE": WHILECommand,
			"!": LogicalNotOperator,
			"!=": InequalityOperator,
			"<>": InequalityOperator,
			"+": AdditionOperator,
			"++": UnaryIncrementOperator,
			"+=": AdditionAssignmentOperator,
			"-": SubtractionOperator,
			"--": UnaryDecrementOperator,
			"-=": SubtractionAssignmentOperator,
			"*": MultiplicationOperator,
			"*=": MultiplicationAssignmentOperator,
			"/": DivisionOperator,
			"/=": DivisionAssignmentOperator,
			"%": ModuloOperator,
			"%=": ModuloAssignmentOperator,
			"&": ConcatOperator,
			"&=": ConcatAssignmentOperator,
			"=": AssignOperator,
			"==": EqualityOperator,
			"<": LessThanOperator,
			"<=": LessThanOrEqualToOperator,
			">": GreaterThanOperator,
			">=": GreaterThanOrEqualToOperator
		}
	}
}