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
            graphs.push(triangle());
        }

        internal static function triangle():Object
        {
            var turtle:Turtle = new Turtle();
            turtle.dot(-100, -100);
            turtle.forward(200);
            turtle.rotate(0.75 * Math.PI);
            turtle.forward(200 * Math.sqrt(2));
            turtle.rotate(0.75 * Math.PI);
            turtle.forward(200);
            return turtle.graph;
        }
    }
}
