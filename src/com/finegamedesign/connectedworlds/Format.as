package com.finegamedesign.connectedworlds
{
    /**
     * End.  Connect digits of connections per minute.
     * 2014-08-24 End.  Kerry at The MADE expects to score.
     */
    internal final class Format
    {
        private static var graphs:Array;

        /**
         * Digits as dots to connect.
         */
        internal static function wholeNumber(wholeNumber:int):Object
        {
            if (null == graphs) {
                include "Digits.as"
            }
            var digitGraphs:Array = [];
            var radix:int = 10;
            for (var remainder:int = wholeNumber; 0 < remainder;
                    remainder /= radix) {
                var digit:int = remainder % 10;
                digitGraphs.unshift(graphs[digit]);
            }
            return concat(digitGraphs);
        }

        /**
         * @param   graphsLeftToRight   Horizontally arranged objects of left to right.  
         * @param   spacing     Horizontal space between each graph.
         * @param   yScale  Flatten original coordinates.  I accidentally placed the dots too high.
         * @return  Dots and connections centered.  
         */
        private static function concat(graphsLeftToRight:Array, 
                spacing:int = // 60, 
                              80,
                yScale:Number=0.9):Object
        {
            var concatenated:Object = {'connections': [], 'dots': []};
            var connectionOffset:int = 0;
            var d:int;
            var dots:Array;
            var xMin:int = int.MAX_VALUE;
            var xMax:int = int.MIN_VALUE;
            var xOffset:int = 0;
            var length:int;
            var x:int;
            for (var g:int = 0; g < graphsLeftToRight.length; g++) {
                dots = graphsLeftToRight[g].dots;
                length = dots.length;
                var dxMin:int = int.MAX_VALUE;
                for (d = 0; d < length; d++) {
                    x = dots[d][0];
                    if (x < dxMin) {
                        dxMin = x;
                    }
                }
                xOffset -= dxMin;
                for (d = 0; d < length; d++) {
                    var dot:Array = dots[d].concat();
                    dot[0] += xOffset;
                    dot[1] = int(dot[1] * yScale);
                    x = dot[0];
                    if (x < xMin) {
                        xMin = x;
                    }
                    if (xMax < x) {
                        xMax = x;
                    }
                    concatenated.dots.push(dot);
                }
                var connections:Array = graphsLeftToRight[g].connections;
                for (var c:int = 0; c < connections.length; c++) {
                    var connection:Array = connections[c].concat();
                    connection[0] += connectionOffset;
                    connection[1] += connectionOffset;
                    concatenated.connections.push(connection);
                }
                connectionOffset += dots.length;
                xOffset = xMax + spacing;
            }
            // Horizontally center
            xOffset = (xMin + xMax) / -2;
            dots = concatenated.dots;
            length = dots.length;
            for (d = 0; d < length; d++) {
                dots[d][0] += xOffset;
            }
            return concatenated;
        }
    }
}
