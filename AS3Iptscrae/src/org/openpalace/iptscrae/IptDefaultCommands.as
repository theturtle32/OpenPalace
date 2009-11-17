package org.openpalace.iptscrae
{
	import org.openpalace.iptscrae.command.*;
	import org.openpalace.iptscrae.command.operator.*;

	public final class IptDefaultCommands
	{
		public static const commands:Object = {
			"AS3TRACE": AS3TRACECommand,
			"ATOI": ATOICommand,
			"BREAK": BREAKCommand,
			"EXEC": EXECCommand,
			"FOREACH": FOREACHCommand,
			"GET": GETCommand,
			"GLOBAL": GLOBALCommand,
			"IF": IFCommand,
			"IFELSE": IFELSECommand,
			"ITOA": ITOACommand,
			"PUT": PUTCommand,
			"RETURN": RETURNCommand,
			"WHILE": WHILECommand,
			"+": PlusOperator,
			"++": UnaryIncrementOperator,
			"+=": PlusAssignOperator,
			"-": MinusOperator,
			"&": ConcatOperator,
			"=": AssignOperator,
			"<": LessThanOperator
		}
	}
}