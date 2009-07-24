/*
This file is part of OpenPalace.

OpenPalace is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

OpenPalace is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenPalace.  If not, see <http://www.gnu.org/licenses/>.
*/

package net.codecomposer.palace.model
{
	import flash.utils.ByteArray;
	
	public class PalaceAsset
	{
		public var id:int;
		public var crc:uint;
		public var guid:String;
		public var temporaryIdentifier:String;
		public var imageDataURL:String;
		public var type:int;
		public var name:String;
		public var flags:uint;
		public var blockSize:int;
		public var blockCount:int;
		public var blockOffset:int;
		public var blockNumber:int;
		public var data:Array;
		
		public function PalaceAsset()
		{
		}

	}
}