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
			"BREAK": BREAKCommand,
			"EXEC": EXECCommand,
			"FOREACH": FOREACHCommand,
			"GET": GETCommand,
			"GLOBAL": GLOBALCommand,
			"IF": IFCommand,
			"IFELSE": IFELSECommand,
			"ITOA": ITOACommand,
			"LENGTH": LENGTHCommand,
			"NOT": LogicalNotOperator,
			"OR": LogicalOrOperator,
			"PUT": PUTCommand,
			"RETURN": RETURNCommand,
			"STRLEN": STRLENCommand,
			"STRTOATOM": STRTOATOMCommand,
			"TOPTYPE": TOPTYPECommand,
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