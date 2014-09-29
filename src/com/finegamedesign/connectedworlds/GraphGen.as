package com.finegamedesign.connectedworlds
{
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    /**
     * Generate graphs.
     */
    internal final class GraphGen
    {
        internal static var dotRadius:int = // 24;
                                            // 32;
                                            // 40;
                                            60;
        private static var height:int = 480;
        private static var width:int = 640;
        private static var space:Rectangle = new Rectangle(-0.5 * width - dotRadius, 
                                                           -0.5 * height - dotRadius, 
                                                           width - dotRadius * 2, 
                                                           height - dotRadius * 2);
        internal var graphs:Array = [];
        private var radius:int = Math.min(space.width, space.height) * 0.5;

        public function GraphGen()
        {
            var triangle:Object = specifyTriangle();
            graphs.push(triangle);
            graphs.push(reflectY(triangle));
            graphs.push(concat(triangle, reflectY(triangle)));
            graphs.push(pinwheel(triangle, 3));
            graphs.push(pinwheel(triangle, 4));
            graphs.push(unfoldQuarter(triangle));
            graphs.push(randomFan(randomInt(3, 4)));
            graphs.push(randomFan(randomInt(3, 4)));
            graphs.push(randomFan(4));
            graphs.push(randomFan(4));
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

        internal static function randomSpoke(radius:int, spokeCount:int):Object
        {
            var turtle:Turtle = new Turtle();
            turtle.dot(0, 0);
            var stepCount:int = 2;
            var spokeRadians:Number = 0.5 - spokeCount * 0.05;
            for (var step:int = 0; step < stepCount; step++) {
                var radians:Number = (Math.random() * spokeRadians + 0.5 * spokeRadians) * Math.PI;
                turtle.rotate(radians);
                var distance:int = 1.25 * radius * (Math.random() * 0.1 + 0.9) / stepCount;
                turtle.forward(distance);
            }
            var graph:Object = turtle.graph;
            if (Math.random() < 0.5) {
                graph = reflectX(graph);
            }
            return graph;
        }

        internal function randomInt(min:int, max:int):int
        {
            return Math.random() * (max - min + 1) + min;
        }

        /**
         * With 5 or more spokes, the dots are too close together.
         */
        internal function randomFan(spokeCount:int):Object
        {
            return pinwheel(randomSpoke(radius, spokeCount), spokeCount);
        }

        internal static function reflect(graph:Object, xyIndex:int):Object
        {
            var reflected:Object = Util.clone(graph);
            var dots:Array = reflected.dots;
            for (var d:int = 0; d < dots.length; d++) {
                dots[d][xyIndex] *= -1;
            }
            return reflected;
        }

        internal static function reflectX(graph:Object):Object
        {
            return reflect(graph, 0);
        }

        internal static function reflectY(graph:Object):Object
        {
            return reflect(graph, 1);
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

        /**
         * Reflect vertically, then horizontally.
         */
        internal static function unfoldQuarter(graph:Object):Object
        {
            var concatenated:Object = concat(graph, reflectY(graph));
            concatenated = concat(concatenated, reflectX(concatenated));
            return concatenated;
        }
    }
}
