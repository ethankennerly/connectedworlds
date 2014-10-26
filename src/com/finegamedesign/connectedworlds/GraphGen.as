package com.finegamedesign.connectedworlds
{
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    /**
     * Generate graphs by turtle, transforming, and concatenating.
     */
    internal final class GraphGen
    {
        internal static var dotRadius:int = // 24;
                                            // 32;
                                            // 40;
                                            60;
        private static var height:int = 480;
        private static var width:int = 640;
        private static var space:Rectangle = new Rectangle(-0.5 * width + dotRadius, 
                                                           -0.5 * height + dotRadius, 
                                                           width - dotRadius * 2, 
                                                           height - dotRadius * 2);
        internal var graphs:Array = [];
        private var radius:int = Math.min(space.width, space.height) * 0.5;

        public function GraphGen()
        {
            var triangle:Object = specifyTriangle();
            graphs.push(triangle);
            graphs.push(smileyFace());
            graphs.push(reflectY(triangle));
            graphs.push(concat(triangle, reflectY(triangle)));
            graphs.push(pinwheel(triangle, 3));
            graphs.push(smileyFaceRandom());
            graphs.push(pinwheel(triangle, 4));
            graphs.push(unfoldQuarter(triangle));
            graphs.push(smileyFaceRandom());
            graphs.push(randomFan(randomInt(3, 4)));
            graphs.push(headRandom());
            graphs.push(randomFan(randomInt(3, 4)));
            graphs.push(randomFan(4));
            graphs.push(smileyFaceRandom());
            graphs.push(randomFan(4));
            graphs.push(randomLeaf(2));
            graphs.push(headRandom());
            graphs.push(randomLeaf(3));
            graphs.push(randomLeaf(4));
            graphs.push(smileyFaceRandom());
            graphs.push(headRandom());
        }

        /**
         * Turtle only concatenates unique dots and connections.
         */
        private static function concat(graphA:Object, graphB:Object):Object
        {
            var turtle:Turtle = new Turtle();
            for each(var graph:Object in [graphA, graphB]) {
                if (null == graph) {
                    continue;
                }
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

        internal static function disconnect(graph:Object, count:int=1):Object
        {
            var disconnected:Object = Util.clone(graph);
            for (var disconnecting:int = 0; disconnecting < count; disconnecting++) {
                var index:int = disconnected.connections.length * Math.random();
                disconnected.connections.splice(index, 1);
            }
            return disconnected;
        }

        private static function headRandom():Object
        {
            var turtle:Turtle = new Turtle();
            turtle.space = space;
            var points:int = 5 + jitter(2);
            for (var r:int = 0; r < points; r++) {
                var distance:Number = 160 + jitter(40);
                var radians:Number = (r + 0.5) * -Math.PI / points - 0.5 * Math.PI;
                var x:int = distance * Math.cos(radians);
                var y:int = distance * Math.sin(radians);
                var draw:Function = 0 == r ? turtle.dot : turtle.lineTo;
                draw(x, y);
            }
            var previous:int = turtle.graph.dots.length - 1;
            turtle.dot(-40 + jitter(20), -20 + jitter(40));
            turtle.graph = concat(turtle.graph, reflectX(turtle.graph));
            var index:int = turtle.graph.dots.length - 2;
            turtle.connect(0, previous + 2);
            turtle.connect(previous, index);
            turtle.graph = rotate(turtle.graph, jitter(0.25 * Math.PI));
            return turtle.graph;
        }

        /**
         * Rotate about origin proportional to count.
         * @param   count   1 or less does nothing.
         */
        private static function pinwheel(graph:Object, count:int):Object
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

        private function randomInt(min:int, max:int):int
        {
            return Math.random() * (max - min + 1) + min;
        }

        /**
         * @param   spokeCount  With 5 or more spokes, the dots are too close together.
         */
        private function randomFan(spokeCount:int):Object
        {
            return pinwheel(randomSpoke(radius, spokeCount), spokeCount);
        }

        /**
         * @param   spokeCount  With 5 or more spokes, the dots are too close together.
         */
        private function randomLeaf(spokeCount:int):Object
        {
            var spokeRadians:Number = 0.75 - spokeCount * 0.05;
            var radians:Number = Math.random() * spokeRadians + -0.5 * Math.PI + 0.5 * spokeRadians;
            var turtle:Turtle = new Turtle();
            turtle.dot(0, 0);
            turtle.directionRadians = radians;
            turtle.forward(space.height / 2 * (Math.random() * 0.2 + 0.8));
            var spoke:Object = turtle.graph;
            var distance:int = space.width / Math.max(1, spokeCount + 1);
            var max:int = 0.5 * spokeCount * distance;
            var min:int = -max + 0.5 * distance;
            var half:Object = null;
            for (var offset:int = min; offset <= max; offset += distance) {
                var translating:Matrix = new Matrix();
                translating.translate(offset, 0);
                var translated:Object = transform(spoke, translating);
                half = concat(half, translated);
            }
            var graph:Object = concat(half, reflectY(half));
            if (Math.random() < 0.5) {
                graph = reflectX(graph);
            }
            return graph;
        }

        private static function randomSpoke(radius:int, spokeCount:int):Object
        {
            var turtle:Turtle = new Turtle();
            turtle.dot(0, 0);
            var stepCount:int = 2;
            var spokeRadians:Number = 0.5 - spokeCount * 0.05;
            for (var step:int = 0; step < stepCount; step++) {
                var distance:int = 1.25 * radius * (Math.random() * 0.1 + 0.9) / stepCount;
                turtle.forward(distance);
                var radians:Number = (Math.random() * spokeRadians + 0.5 * spokeRadians) * Math.PI;
                turtle.rotate(radians);
            }
            var graph:Object = turtle.graph;
            if (Math.random() < 0.5) {
                graph = reflectX(graph);
            }
            return graph;
        }

        private static function reflect(graph:Object, xyIndex:int):Object
        {
            var reflected:Object = Util.clone(graph);
            var dots:Array = reflected.dots;
            for (var d:int = 0; d < dots.length; d++) {
                dots[d][xyIndex] *= -1;
            }
            return reflected;
        }

        private static function reflectX(graph:Object):Object
        {
            return reflect(graph, 0);
        }

        private static function reflectY(graph:Object):Object
        {
            return reflect(graph, 1);
        }

        /**
         * Matrix rotates about origin.
         */
        private static function rotate(graph:Object, radians:Number):Object
        {
            var rotating:Matrix = new Matrix();
            rotating.rotate(radians);
            return transform(graph, rotating);
        }

        private static function smileyFace():Object
        {
            var turtle:Turtle = new Turtle();
            turtle.dot(-100, -160);
            turtle.rotate(0.5 * Math.PI);
            turtle.forward(160);
            turtle.dot(-200, 40);
            turtle.rotate(-0.25 * Math.PI);
            turtle.forward(160);
            var previous:int = turtle.graph.dots.length - 1;
            turtle.graph = concat(turtle.graph, reflectX(turtle.graph));
            var index:int = turtle.graph.dots.length - 1;
            turtle.connect(previous, index);
            return turtle.graph;
        }

        private static function jitter(arc:Number):Number
        {
            return 2 * arc * Math.random() - arc;
        }

        private static function smileyFaceRandom():Object
        {
            var turtle:Turtle = new Turtle();
            turtle.space = space;
            turtle.dot(-120 + jitter(40), -160 + jitter(40));
            turtle.rotate(0.5 * Math.PI + jitter(0.25 * Math.PI));
            turtle.forward(100 + jitter(20));
            turtle.dot(-160 + jitter(40), 80 + jitter(40));
            turtle.directionRadians = 0.325 * Math.PI + jitter(0.25 * Math.PI);
            turtle.forward(120 + jitter(40));
            var previous:int = turtle.graph.dots.length - 1;
            turtle.graph = concat(turtle.graph, reflectX(turtle.graph));
            var index:int = turtle.graph.dots.length - 1;
            turtle.connect(previous, index);
            if (Math.random() < 0.5) {
                turtle.dot(0, 0 + jitter(40));
            }
            turtle.graph = rotate(turtle.graph, jitter(0.25 * Math.PI));
            return turtle.graph;
        }

        private static function specifyTriangle():Object
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

        private static function transform(graph:Object, matrix:Matrix):Object
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
        private static function unfoldQuarter(graph:Object):Object
        {
            var concatenated:Object = concat(graph, reflectY(graph));
            concatenated = concat(concatenated, reflectX(concatenated));
            return concatenated;
        }

        /**
         * Randomly reflect or rotate.
         */
        internal static function vary(graph:Object, level:int):Object
        {
            var varied:Object = graph;
            if (Math.random() < 0.5) {
                varied = reflectX(varied);
            }
            var halfTurns:int = 2 * Math.random();
            if (10 <= level && 1 <= halfTurns) {
                varied = rotate(varied, halfTurns * Math.PI);
            }
            if (20 <= level && Math.random() < 0.5) {
                varied = reflectY(varied);
            }
            if (40 <= level) {
                var count:int = Math.min(2, (level - 20) / 20);
                varied = disconnect(varied, count);
            }
            return varied;
        }
    }
}
