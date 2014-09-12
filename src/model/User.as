package model
{
	public class User
	{
		private var _username:String;
		private var _name:String;
		private var _uid:String;

        private var _auth:String;

		
		public function User()
		{
		}


        [Bindable]
        public function get username():String {
            return _username;
        }

        public function set username(value:String):void {
            _username = value;
        }

        [Bindable]
        public function get name():String {
            return _name;
        }

        public function set name(value:String):void {
            _name = value;
        }

        public function get uid():String {
            return _uid;
        }

        public function set uid(value:String):void {
            _uid = value;
        }

        public function get auth():String {
            return _auth;
        }

        public function set auth(value:String):void {
            _auth = value;
        }
    }
}