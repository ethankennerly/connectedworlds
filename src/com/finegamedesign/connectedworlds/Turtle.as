package com.finegamedesign.connectedworlds
{
    /**
     * Abstract turtle for making coordinates of graphs.
     * Does no drawing.
     *
     * Related to:
     * https://github.com/mohlendo/lsystem/blob/master/lsystem/src/main/flex/lsystem/rendering/Turtle.as
     */
    internal final class Turtle
    {
        internal var directionRadians:Number = 0.0;
        internal var graph:Object = {"connections": [],
            "dots": []}
        internal var x:int = 0;
        internal var y:int = 0;
        private var connections:Object = {};
        private var dots:Object = {};

        public function Turtle()
        {
        }

        /**
         * Model expects each connection is sorted.
         * Connections are bidirectional, so only store once.
         */
        internal function connect():int
        {
            var connection :Array = [dots.previous, dots.index];
            connection.sort(Array.NUMERIC);
            var connectionIndex:int = push("connections", connection[0], connection[1]);
            return connectionIndex;
        }

        internal function dot(x:int, y:int):int
        {
            this.x = x;
            this.y = y;
            return push("dots", x, y);
        }

        internal function forward(distance:Number):int
        {
            x += distance * Math.cos(directionRadians);
            y += distance * Math.sin(directionRadians);
            dot(x, y);
            return connect();
        }

        /**
         * @param   container    Push new dot or connection if not already there.  
         * @return  index.
         */
        private function push(container:String, x:int, y:int):int
        {
            var xy:String = x.toString() + "," + y.toString();
            if (!(xy in this[container])) {
                this[container][xy] = graph[container].length;
                graph[container].push([x, y]);
                // trace("Turtle.push: " + container + ": " + xy);
            }
            this[container].previous = this[container].index;
            this[container].index = this[container][xy];
            return this[container].index;
        }

        internal function rotate(radians:Number):void
        {
            directionRadians += radians;
        }
    }
}
