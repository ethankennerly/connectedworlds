package com.finegamedesign.connectedworlds
{
    public class Model
    {
        internal var connections:Array;
        internal var connecting:Array;
        internal var inTrial:Boolean = false;
        /**
         * Answer expects connections are numerically sorted.
         */
        internal var levels:Array = [
            // {connections: [[0, 0]], dots: [[0, 0]]},
            {connections: [[0, 1]], 
             dots: [[-160, 0], [160, 0]]},
            {connections: [[0, 1], [0, 2], [1, 2]], 
             dots: [[-160, 120], [0, -120], [160, 120]]}
        ];
        internal var level:int = 0;
        internal var dots:Array;

        internal function populate():void
        {
            connecting = [];
            var params:Object = levels[level];
            for (var prop:String in params) {
                this[prop] = Util.clone(params[prop]);
            }
        }

        internal function cancel():void
        {
            connecting = [];
        }

        internal function answer(x:int, y:int):Boolean
        {
            var correct:Boolean = false;
            if (complete) {
                correct = true;
            }
            var dotIndex:int = -1;
            for (var d:int = 0; d < dots.length; d++) {
                var dot:Array = dots[d];
                if (x == dot[0] && y == dot[1]) {
                    dotIndex = d;
                    break;
                }
            }
            if (dotIndex <= -1) {
                throw new Error("Expected dot at " + x + ", " + y);
            }
            if (connecting.length <= 0) {
                connecting.push(dotIndex);
            }
            connecting.push(dotIndex);
            connecting.sort(Array.NUMERIC);
            for (var c:int = connections.length - 1; 0 <= c; c--) {
                var connection:Array = connections[c];
                if (connecting[0] == connection[0] && connecting[1] == connection[1]) {
                    connections.splice(c, 1);
                    correct = true;
                }
            }
            if (connecting[0] == connecting[1]) {
                correct = true;
            }
            connecting = [dotIndex];
            trace("Model.answer: " + correct + " x " + x + " y " + y + " connecting " + connecting);
            return correct;
        }

        internal function get only():Boolean
        {
            return 0 == level && connecting.length <= 0;
        }

        internal function get complete():Boolean
        {
            return connections.length <= 0;
        }

        internal function clear():void
        {
        }

        internal function levelUp():void
        {
            level = (level + 1) % levels.length;
        }
    }
}
