package events
{
	import flash.events.Event;
	
	public class PluginEvent extends Event
	{	
		static public const PluginChange:String="PluginChange";
		public function PluginEvent(type:String="PluginChange", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}