package com.finegamedesign.connectedworlds
{
    import flash.net.SharedObject;

    public class Shared
    {
        private static function get share():SharedObject
        {
            return SharedObject.getLocal("session", "/dotdot");
        }

        internal static function get level():int
        {
            var level:int = 0;
            try {
                var shared:SharedObject = share;
                if (shared && shared.data && shared.data.level) {
                    level = shared.data.level;
                }
            }
            catch (err:Error) {
            }
            return level;
        }

        internal static function set level(value:int):void
        {
            try {
                var shared:SharedObject = share;
                shared.data.level = value;
                shared.flush();
            }
            catch (err:Error) {
            }
        }
    }
}
