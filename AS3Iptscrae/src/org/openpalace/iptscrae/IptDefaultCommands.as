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
			"_BREAKPOINT": BREAKPOINTCommand,
			"COSINE": COSINECommand,
			"DATETIME": DATETIMECommand,
			"DELAY": DELAYCommand,
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
			"RANDOM": RANDOMCommand,
			"RETURN": RETURNCommand,
			"SINE": SINECommand,
			"STACKDEPTH": STACKDEPTHCommand,
			"STRLEN": STRLENCommand,
			"STRTOATOM": STRTOATOMCommand,
			"SUBSTRING": SUBSTRINGCommand,
			"SWAP": SWAPCommand,
			"TANGENT": TANGENTCommand,
			"TICKS": TICKSCommand,
			"TOPTYPE": TOPTYPECommand,
			"TRACESTACK": TRACESTACKCommand,
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