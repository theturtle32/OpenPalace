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
		
		private static const CRC_MAGIC:uint = 0xa95ade76;
		private static const MAGIC_LONG:uint = 0x9602c9bf;
		
		private static const CRCMASK:Array = [
			0xEBE19B94, 0x7604DE74, 0xE3F9D651, 0x604FD612, 0xE8897C2C, 0xADC40920, 0x37ECDFB7, 0x334989ED, 0x2834C33B, 0x8BD2FE15, 0xCBF001A7, 0xBD96B9D6, 0x315E2CE0, 0x4F167884, 0xA489B1B6, 0xA51C7A62,
			0x54622636, 0xBC016FC, 0x68DE2D22, 0x3C9D304C, 0x44FD06FB, 0xBBB3F772, 0xD637E099, 0x849AA9F9, 0x5F240988, 0xF8373BB7, 0x30379087, 0xC7722864, 0xB0A2A643, 0xE3316071, 0x956FED7C, 0x966F937D,
			0x9945AE16, 0xF0B237CE, 0x223479A0, 0xD8359782, 0x5AE1B89, 0xE3653292, 0xC34EEA0D, 0x2691DFC2, 0xE9145F51, 0xD9AA7F35, 0xC7C4344E, 0x4370EBA1, 0x1E43833E, 0x634BCF18, 0xC50E26B, 0x6492118,
			0xF78B8BFE, 0x5F2BB95C, 0xA3EB54A6, 0x1E15A2F0, 0x6CC01887, 0xDE4E7405, 0x1C1D7374, 0x85757FEB, 0xE372517E, 0x9B9979C7, 0xF37807E8, 0x18F97235, 0x645A149B, 0x9556C6CF, 0xF389119E, 0x1D6CBF85,
			0xA9760CE5, 0xA985C5FF, 0x5F4DB574, 0x13176CAC, 0x2F14AA85, 0xF520832C, 0xD21EE917, 0x6F307A5B, 0xC1FB01C6, 0x19415378, 0x797FA2C3, 0x24F42481, 0x4F652C30, 0x39BC02ED, 0x11EDA1D7, 0x8C79A136,
			0x6BD37A86, 0x80B354EE, 0xC424E066, 0xAAE16427, 0x6BD3BE12, 0x868D8E37, 0xD1D43C54, 0x4D62081F, 0x433056D7, 0xF2E4CB02, 0x43FC5A2, 0x9DA58CA4, 0x1ED63321, 0x20679F26, 0xB38A4758, 0x846419F7,
			0x6BDC6352, 0xABF2C24D, 0x40AC386C, 0x27588588, 0x5E1AB2E5, 0x76BDEAD4, 0x71444D32, 0x2FC6084, 0x92DB41FB, 0xEF86BAEB, 0xF7D8572A, 0xB75AEABF, 0x84DC5C93, 0xCBC13881, 0x641D6E73, 0xCB27A99,
			0xDED369A6, 0x617E5DFA, 0x248BD13E, 0xB8596D66, 0x9B36A9FA, 0x52EDAF1C, 0x3C659784, 0x146DF599, 0x109FCAE8, 0xC9ED4841, 0xBF593F49, 0xC94A6E73, 0x5AFA0D2F, 0xB2035002, 0xCAB31104, 0x7C4F5A82,
			0xEAC93638, 0x63FC5385, 0xDF0CAE06, 0x26E55BE3, 0x2921B9B8, 0xB80B3408, 0x917E137D, 0x127A48BC, 0xE031858A, 0x722213D7, 0x2DBC96FA, 0x5359F112, 0xAB256019, 0x6E2A756E, 0x4DC62F76, 0x268832DE,
			0x5980E578, 0xD338B668, 0xEEE2E4D7, 0x1FFF8FC6, 0x9B17ED10, 0xF3E6BE0F, 0xC1BA9D78, 0xBB8693C5, 0x24D57EC0, 0x5D640AED, 0xEE87979B, 0x96323E11, 0xCCBC1601, 0xE83F43B, 0x2C2F7495, 0x5F150B2A,
			0x710A77E2, 0x281B51DC, 0x2385D03C, 0x67239BFF, 0xA719E8F9, 0x21C3B9DE, 0x26489C22, 0xDE68989, 0xCA758F0D, 0x417E8CD2, 0x67ED61F8, 0xD15FC001, 0x3BA2F272, 0x57E2F7A9, 0xE723B883, 0x914E43E1,
			0x71AA5B97, 0xFCEB1BE1, 0x7FFA4FD9, 0x67A0B494, 0x5E1C741E, 0xC8C2A5E6, 0xE13BA068, 0x24525548, 0x397A9CF6, 0x3DDDD4D6, 0xB626234C, 0x39E7B04D, 0x36CA279F, 0x89AEA387, 0xCFE93789, 0x4E1761B,
			0x9D620EDC, 0x6E9DF1E7, 0x4A15DFA6, 0xD44641AC, 0x39796769, 0x6D062637, 0xF967AF35, 0xDDB4A233, 0x48407280, 0xA9F22E7E, 0xD9878F67, 0xA05B3BC1, 0xE8C9237A, 0x81CEC53E, 0x4BE53E70, 0x60308E5E,
			0xF03DE922, 0xA712AF7B, 0xBB6168B4, 0xCC6C15B5, 0x2F202775, 0x304527E3, 0xD32BC1E6, 0xBA958058, 0xA01F7214, 0xC6E8D190, 0xAB96F14B, 0x18669984, 0x4F93A385, 0x403B5B40, 0x580755F1, 0x59DE50E8,
			0xF746729F, 0xFF6F7D47, 0x8022EA34, 0xB24B0BCD, 0xF687A7CC, 0x7E95BAB3, 0x8DC1583D, 0xB443FE9, 0xE6E45618, 0x224D746F, 0xF30624BB, 0xB7427258, 0xC78E19BF, 0xD1EE98A6, 0x66BE7D3A, 0x791E342F,
			0x68CBAAB0, 0xBBB5355D, 0x8DDA9081, 0xDC2736DC, 0x573355AD, 0xC3FFEC65, 0xE97F0270, 0xC6A265E8, 0xD9D49152, 0x4BB35BDB, 0xA1C7BBE6, 0x15A3699A, 0xE69E1EB5, 0x7CDDA410, 0x488609DF, 0xD19678D3
		];
		
		public static function generate():RegistrationCode {
			var regcode:RegistrationCode = new RegistrationCode();
			var seed:uint = (new Date()).valueOf();
			regcode.crc = computeLicenseCRC(seed);
			regcode.counter = computeLicenseCounter(seed, regcode.crc);
			return regcode;
		}
		
		private static function computeLicenseCRC(seed:uint):uint {
			// Start by reversing the byte order of the seed
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.BIG_ENDIAN;
			ba.writeInt(seed);
			ba.position = 0;
			ba.endian = Endian.LITTLE_ENDIAN;
			seed = ba.readInt();

			var crc:uint = CRC_MAGIC;
			
			for (var i:int=0; i < 4; i++) {
				var currentByte:uint = seed & 0xff;
				crc = ((crc << 1) | (((crc & 0x80000000) == 0x0) ? 0x0 : 0x1)) ^ CRCMASK[currentByte];
				seed = seed >> 8;
			}
			
			return crc;
		}
		
		private static function computeLicenseCounter(seed:uint, crc:uint):uint {
			return (seed ^ MAGIC_LONG) ^ crc;
		}
		
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