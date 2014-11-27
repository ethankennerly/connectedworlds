package com.finegamedesign.connectedworlds
{
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    /**
     * Generate graphs by turtle, transforming, and concatenating.
     * The word "dot" is used synonymously with a vertex, except that it also has radius.
     * The word "connection" is used synonymously with an edge, except it also has a width.
     */
    internal final class GraphGen
    {
        internal static var dotRadius:int = // 24;
                                            // 32;
                                            // 40;
                                            60;
        private static var height:int = 480;
        private static var width:int = 640;
        private static var offscreen:int = -640;
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
            graphs.push(smileyFaceRandom());
            graphs.push(concat(triangle, reflectY(triangle)));
            graphs.push(pinwheel(triangle, 3));
            graphs.push(smileyFaceRandom());
            graphs.push(randomLeaf(2));
            graphs.push(randomFan(3));
            graphs.push(smileyFaceRandom());
            graphs.push(headRandom());
            graphs.push(randomFan(3));
            graphs.push(randomFan(5, 1));
            graphs.push(smileyFaceRandom());
            graphs.push(randomFan(5, 1));
            graphs.push(headRandom());
            graphs.push(unfoldQuarter(triangle));
            graphs.push(randomLeaf(3));
            graphs.push(headRandom());
            graphs.push(randomLeaf(4));
            graphs.push(pinwheel(triangle, 4));
        }

        /**
         * Add random distractors
         * 
         * cell:  15x15 pixels.
         * For each cell in space:  array cells, omitting edges that would be partially offscreen.
         * For each dot:  For each cell:  remove cells that are too near.
         * For each connection:  Remove cells that would overlap a connection.
         * Randomly select next cell.  Remove cells that are too near.
         * Randomly select position in cell.
         */
        internal static function addDots(graph:Object, count:int=1):Object
        {
            if (count <= 0) {
                return graph;
            }
            var added = Util.clone(graph);
            var cellPerDotRadius:int = 4;
            var spacePerCell:int = dotRadius / cellPerDotRadius;
            var cells:Array = [];
            var cellWidth:int = width / spacePerCell;
            var cellHeight:int = height / spacePerCell;
            var area:int = cellWidth * cellHeight;
            for (var index:int = 0; index < area; index++) {
                var row:int = index / cellWidth;
                if (cellPerDotRadius <= row && row < cellHeight - cellPerDotRadius) {
                    var column:int = index % cellWidth;
                    if (cellPerDotRadius <= column && column < cellWidth - cellPerDotRadius) {
                        cells.push(index);
                    }
                }
            }
            var dots:Array = added.dots;
            for each(var xy:Array in dots) {
                removeCellsNear(cells, xy[0], xy[1], spacePerCell);
            }
            var connections:Array = added.connections;
            for each(var ab:Array in connections) {
                var x0:int = dots[ab[0]][0];
                var y0:int = dots[ab[0]][1];
                var x1:int = dots[ab[1]][0];
                var y1:int = dots[ab[1]][1];
                var dx:int = (x1 - x0);
                var dy:int = (y1 - y0);
                var radians:Number = Math.atan2(dy, dx);
                var sx:Number = Math.cos(radians);
                var sy:Number = Math.sin(radians);
                var distance:Number = Math.pow(dx * dx + dy * dy, 0.5);
                for (var step:int = 0; step < distance; step += spacePerCell) {
                    var x:int = step * sx;
                    var y:int = step * sy;
                    removeCellsNear(cells, x, y, spacePerCell);
                }
            }
            for (var add:int = 0; add < count; add++) {
                if (1 <= cells.length) {
                    var cellIndex:int = cells.length * Math.random();
                    var cell:int = cells[cellIndex];
                    var dotColumn:int = cell % cellWidth;
                    var dotRow:int = cell / cellWidth;
                    var dotX:int = (Math.random() + dotColumn) * spacePerCell - 0.5 * width;
                    var dotY:int = (Math.random() + dotRow) * spacePerCell - 0.5 * height;
                    if (dotX < space.left || space.right < dotX
                    || dotY < space.top || space.bottom < dotY) {
                        throw new Error("Expected to fit " + dotX + "," + dotY);
                    }
                    dots.push([dotX, dotY]);
                    removeCellsNear(cells, dotX, dotY, spacePerCell);
                }
            }
            return added;
        }

        /**
         * @param   x   Expects in space coordinates.
         * @param   y   Expects in space coordinates.
         */
        private static function removeCellsNear(cells:Array, x:int, y:int, 
            spacePerCell:int):void
        {
            x += 0.5 * width;
            y += 0.5 * height;
            var marginRatio:int = // 1.5;
                                  // 1.75;
                                  2;
            var cellRadius:int = marginRatio * dotRadius / spacePerCell;
            var column:int = x / spacePerCell;
            var row:int = y / spacePerCell;
            var cellsWidth:int = width / spacePerCell;
            var centerIndex:int = column + row * cellsWidth;
            var radiusSquared:int = cellRadius * cellRadius;
            for (var down:int = -cellRadius; down <= cellRadius; down++) {
                for (var right:int = -cellRadius; right <= cellRadius; right++) {
                    if (down * down + right * right <= radiusSquared) {
                        var coordinate:int = column + right + (row + down) * cellsWidth;
                        var index:int = cells.indexOf(coordinate);
                        if (0 <= index) {
                            cells.splice(index, 1);
                        }
                    }
                }
            }
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
                if (null != graph.connections) {
                    for each(var connection:Array in graph.connections) {
                        for each(var dotIndex:int in connection) {
                            turtle.dot.apply(turtle, graph.dots[dotIndex]);
                        }
                        turtle.connect();
                    }
                }
                if (null != graph.dots) {
                    for each(var dot:Array in graph.dots) {
                        turtle.dot.apply(turtle, dot);
                    }
                }
            }
            return turtle.graph;
        }

        /**
         * @param   dotsLength  In case dots are at end.
         * @return  Indexes of disconnected dots.
         * Tutorial.  Pink X over distractor.  2014-08-29 face cheeks disconnected.  Samantha Yang expects to feel aware to trace lines.  Got confused.
         */
        internal static function findSingles(connections:Array, dotsLength:int):Array
        {
            var connecteds:Object = {};
            var index:int;
            for each(var connection:Array in connections) {
                for each(index in connection) {
                    connecteds[index.toString()] = true;
                }
            }
            var singles:Array = [];
            for (index = 0; index < dotsLength; index++) {
                if (!(index.toString() in connecteds)) {
                    singles.push(index);
                }
            }
            return singles;
        }

        /**
         * @param   removeDot   From the dots.  Both if neither is connected now.
         */
        internal static function disconnect(graph:Object, 
                                            count:int=1, 
                                            removeDot:Boolean=false):Object
        {
            var disconnected:Object = Util.clone(graph);
            if (null != graph.connections) {
                for (var disconnecting:int = 0; disconnecting < count; disconnecting++) {
                    var index:int = disconnected.connections.length * Math.random();
                    var connection:Array = disconnected.connections[index];
                    disconnected.connections.splice(index, 1);
                    if (removeDot) {
                        var singles:Array = findSingles(disconnected.connections, 
                                                        disconnected.dots.length);
                        for (var c:int = 0; c < connection.length; c++) {
                            if (0 <= singles.indexOf(connection[c])) {
                                var xy:Array = disconnected.dots[connection[c]];
                                xy[0] = offscreen;
                                xy[1] = offscreen;
                            }
                        }
                    }
                }
            }
            return disconnected;
        }

        /**
         * 2014-11-01 Jennifer Russ likes.
         */
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
         * @param   gap     How many not to display at end.
         * 2014-11-01 Jennifer Russ expects no pinwheels that resemble swastikas.
         */
        private static function pinwheel(graph:Object, count:int, gap:int=0):Object
        {
            var radians:Number = 2 * Math.PI / count;
            var rotating:Matrix = new Matrix();
            rotating.rotate(radians);
            var concatenated:Object = Util.clone(graph);
            var transformed:Object = graph;
            for (var i:int = 1; i < count - gap; i++) {
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
        private function randomFan(spokeCount:int, gap:int=0):Object
        {
            return pinwheel(randomSpoke(radius, spokeCount), spokeCount, gap);
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
            if (null != dots) {
                for (var d:int = 0; d < dots.length; d++) {
                    dots[d][xyIndex] *= -1;
                }
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

        /**
         * 2014-11-01 Smiley face.  Jennifer infers this is a reward for performance.
         */
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
            if (null != dots) {
                var point:Point = new Point(0, 0);
                for (var d:int = 0; d < dots.length; d++) {
                    point.x = dots[d][0];
                    point.y = dots[d][1];
                    point = matrix.transformPoint(point);
                    dots[d][0] = point.x;
                    dots[d][1] = point.y;
                }
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
         * @param   degree  0: x, 1: half turn, 2: flip y.  3+: disconnect, add dots.
         */
        internal static function vary(graph:Object, degree:int):Object
        {
            var varied:Object = graph;
            if (Math.random() < 0.5) {
                varied = reflectX(varied);
            }
            var halfTurns:int = 2 * Math.random();
            if (1 <= degree && 1 <= halfTurns) {
                varied = rotate(varied, halfTurns * Math.PI);
            }
            if (2 <= degree && Math.random() < 0.5) {
                varied = reflectY(varied);
            }
            if (3 <= degree) {
                var count:int = degree - 2;
                varied = disconnect(varied, count);
                varied = addDots(varied, 2 * count);
            }
            return varied;
        }

	    /**
         * Increment lines and dots of an image.
         * Backwards:  Remove one connection.  Remove that dot.
         * @param   graphs  Not modified.  Example:  1, 2, 2, 3.
         * @return  New graphs with introductions.  Example:  1, 1, 2, 1, 2, 1, 2, 3.
         * 2014-11-25 Faraz expects gradually introduce number of lines.
         * Trace. 3-year-old boy expects to feel competent.
         */
        internal static function introduce(graphs:Array):Array
        {
            var introduced:Array = [];
            for (var g:int = graphs.length - 1; 0 <= g; g--) {
                var reduced:Object = Util.clone(graphs[g]);
                introduced.unshift(reduced);
                while (2 <= reduced.connections.length) {
                    reduced = disconnect(reduced, 1, true);
                    introduced.unshift(reduced);
                }
            }
            return introduced;
        }
    }
}
