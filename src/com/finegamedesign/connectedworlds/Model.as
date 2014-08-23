package com.finegamedesign.connectedworlds
{
    public class Model
    {
        internal var inTrial:Boolean = false;
        internal var levels:Array = [
            {dots: [[0, 0]]}
        ];
        internal var level:int = 1;
        internal var dots:Array;

        public function Model()
        {
        }

        internal function populate():void
        {
            var params:Object = levels[level - 1];
            for (var prop:String in params) {
                this[prop] = params[prop];
            }
        }

        internal function answer():Boolean
        {
            return true;
        }

        internal function clear():void
        {
        }

        internal function update():int
        {
            return win();
        }

        /**
         * TODO: If connecting, continue.  If all connected, win.  If an unspecified connection, lose.
         * @return  0 continue, 1: win, -1: lose.
         */
        private function win():int
        {
            var winning:int = 0;
            return winning;
        }
    }
}
