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

package net.codecomposer.palace.util
{
	public class DrawColorUtil
	{
		public static function ARGBtoUint(alpha:uint, red:uint, green:uint, blue:uint):uint {
			var color:uint = 0x00000000;
			color = color | alpha << 24;
			color = color | red << 16;
			color = color | green << 8;
			color = color | blue;
			return color;
		}
	}
}