package
{
	public class BertAtom
	{
		public var value:Object;
		public function BertAtom(value:Object)
		{
			this.value = value;
		}
		
		public function toString():String {
			return value.toString();
		};
	}
}