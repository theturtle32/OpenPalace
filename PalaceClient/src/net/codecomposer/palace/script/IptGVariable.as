package net.codecomposer.palace.script
{
	public class IptGVariable extends IptVariable
	{
		public var data:Object;
		
		public function IptGVariable(name:String=null, type:int=0, value:int=0, flags:int=0, data:Object = null)
		{
			super(name, type, value, flags);
			this.data = data;
		}
	}
}