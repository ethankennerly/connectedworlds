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
         * Turtle only concatenates unique dots and connections.
         */
        internal static function concat(graphA:Object, graphB:Object):Object
        {
            var turtle:Turtle = new Turtle();
            for each(var graph:Object in [graphA, graphB]) {
                for each(var connection:Array in graph.connections) {
                    for each(var dotIndex:int in connection) {
                        turtle.dot.apply(turtle, graph.dots[dotIndex]);
                    }
                    turtle.connect();
                }
                for each(var dot:Array in graph.dots) {
                    turtle.dot.apply(turtle, dot);
                }
            }
            return turtle.graph;
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
