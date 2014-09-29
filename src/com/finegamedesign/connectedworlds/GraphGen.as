package com.finegamedesign.connectedworlds
{
    import flash.geom.Matrix;
    import flash.geom.Point;

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
            graphs.push(pinwheel(triangle, 3));
            graphs.push(pinwheel(triangle, 4));
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

        /**
         * Rotate about origin proportional to count.
         * @param   count   1 or less does nothing.
         */
        internal static function pinwheel(graph:Object, count:int):Object
        {
            var radians:Number = 2 * Math.PI / count;
            var rotating:Matrix = new Matrix();
            rotating.rotate(radians);
            var concatenated:Object = Util.clone(graph);
            var transformed:Object = graph;
            for (var i:int = 1; i < count; i++) {
                transformed = transform(transformed, rotating);
                concatenated = concat(concatenated, transformed);
            }
            return concatenated;
        }

        /**
         * Matrix rotates about origin.
         */
        internal static function rotate(graph:Object, radians:Number):Object
        {
            var rotating:Matrix = new Matrix();
            rotating.rotate(radians);
            return transform(graph, rotating);
        }

        internal static function transform(graph:Object, matrix:Matrix):Object
        {
            var transformed:Object = Util.clone(graph);
            var dots:Array = transformed.dots;
            var point:Point = new Point(0, 0);
            for (var d:int = 0; d < dots.length; d++) {
                point.x = dots[d][0];
                point.y = dots[d][1];
                point = matrix.transformPoint(point);
                dots[d][0] = point.x;
                dots[d][1] = point.y;
            }
            return transformed;
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
