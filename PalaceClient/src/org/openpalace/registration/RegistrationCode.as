package org.openpalace.registration
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class RegistrationCode
	{
		public var counter:uint;
		public var crc:uint;
		
		// Test code: 9YAT-C8MM-GJVZL
		
		private static var codeAsc:Array = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".split(''); 
		private static var alphaTest:RegExp = /[a-zA-Z]/;		
		
		public static function fromString(regCode:String):RegistrationCode {
			var code:String = regCode.toUpperCase();
			code = code.replace(/[^ABCDEFGHJKLMNPQRSTUVWXYZ23456789]/g, "");
			var nbrBits:int = 64;
			var sn:int = 0;
			var oCnt:int = 0;
			var mask:int = 0x0080;
			var charIndex:int = 0;
			var s:ByteArray = new ByteArray();
			var temp:uint = 0;
			var savedPosition:int = 0;
			s.endian = Endian.BIG_ENDIAN;
			s.writeInt(0);
			s.writeInt(0);
			savedPosition = s.position = 0;
			var instance:RegistrationCode = new RegistrationCode();
			while (nbrBits--) {
				if (oCnt == 0) {
					sn = convertAsciiToCode(code.charAt(charIndex++));
					oCnt = 5;
				}
				if (sn & 0x10) {
					s.position = savedPosition;
					temp = s.readUnsignedByte(); // char
					temp |= mask;
					temp &= 0xFF;
					s.position = savedPosition;
					s.writeByte(temp);
				}
				sn <<= 1;
				sn &= 0xFFFF; // Force to short
				--oCnt;
				mask >>= 1;
				mask &= 0xFFFF; // Force to short
				if (mask == 0) {
					mask = 0x80;
					++savedPosition;
					s.position = savedPosition;
					s.writeByte(0);
				}
			}
			s.position = 0;
			instance.crc = s.readUnsignedInt();
			instance.counter = s.readUnsignedInt();
			return instance;
		}
		
		private static function convertAsciiToCode(char:String):int {
			char = char.toUpperCase();
			return codeAsc.indexOf(char);
		}
	}
}