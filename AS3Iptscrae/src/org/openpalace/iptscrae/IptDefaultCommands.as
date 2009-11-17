package org.openpalace.iptscrae
{
	import org.openpalace.iptscrae.command.*;
	import org.openpalace.iptscrae.command.operator.*;

	public final class IptDefaultCommands
	{
		public static const commands:Object = {
			"AS3TRACE": AS3TRACECommand,
			"ATOI": ATOICommand,
			"EXEC": EXECCommand,
			"FOREACH": FOREACHCommand,
			"GLOBAL": GLOBALCommand,
			"ITOA": ITOACommand,
			"WHILE": WHILECommand,
			"+": PlusOperator,
			"-": MinusOperator,
			"&": ConcatOperator,
			"=": AssignOperator,
			"<": LessThanOperator
		}
	}
}