package net.codecomposer.palace.message
{
	import flash.utils.ByteArray;

	public interface IPalaceServerMessage
	{
		function read(data:ByteArray, referenceId:int):void;
		function write():ByteArray;
	}
}