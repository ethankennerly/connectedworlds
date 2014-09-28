package com.finegamedesign.connectedworlds
{
    /**
     * Generate graphs.
     */
    internal final class GraphGen
    {
        internal var graphs:Array = [];

        public function GraphGen()
        {
            var triangle:Object = specifyTriangle();
            graphs.push(triangle);
            graphs.push(reflectY(triangle));
            graphs.push(concat(triangle, reflectY(triangle)));
        }

        /**
         * TODO: Prevent duplicate dots and connections.
         */
        internal static function concat(graphA:Object, graphB:Object):Object
        {
            var concatenated:Object = Util.clone(graphA);
            var cloneB:Object = Util.clone(graphB);
            var connectionCountA:int = concatenated.connections.length;
            concatenated.dots = concatenated.dots.concat(cloneB.dots);
            var connections:Array = cloneB.connections;
            for (var c:int = 0; c < connections.length; c++) {
                connections[c][0] += connectionCountA;
                connections[c][1] += connectionCountA;
            }
            concatenated.connections = concatenated.connections.concat(cloneB.connections);
            return concatenated;
        }

        internal static function reflectY(graph:Object):Object
        {
            var reflected:Object = Util.clone(graph);
            var dots:Array = reflected.dots;
            for (var d:int = 0; d < dots.length; d++) {
                dots[d][1] *= -1;
            }
            return reflected;
        }

        internal static function specifyTriangle():Object
        {
            var turtle:Turtle = new Turtle();
            turtle.dot(-150, 0);
            turtle.forward(150);
            turtle.rotate(-0.75 * Math.PI);
            turtle.forward(150 * Math.sqrt(2));
            turtle.rotate(-0.75 * Math.PI);
            turtle.forward(150);
            return turtle.graph;
        }
    }
}
