package com.finegamedesign.connectedworlds
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    public class View
    {
        internal var dots:Array;
        internal var model:Model;
        internal var screen:Screen;

        public function View(parent:DisplayObjectContainer)
        {
            screen = new Screen();
            parent.addChild(screen);
        }

        internal function populate(model:Model):void
        {
            dots = [];
            this.model = model;
            for each(var xy:Array in model.dots) {
                trace("View.populate: " + xy);
                var dot:DotClip = new StarClip();
                dot.x = xy[0];
                dot.y = xy[1];
                screen.canvas.addChild(dot);
                dots.push(dot);
            }
        }

        internal function dotAt(x:Number, y:Number):DotClip
        {
            var at:DotClip;
            for each(var dot:DotClip in dots) {
                if (near(dot.x - x, dot.y - y)) {
                    // trace("View.dotAt: x " + x + " y " + y + " dot " + dot.x + ", " + dot.y);
                    at = dot;
                    break;
                }
            }
            return at;
        }

        private function near(dx:Number, dy:Number):Boolean
        {
            var radius:Number = 40;
            var radiusSquared:Number = radius * radius;
            return (dx * dx + dy * dy) <= radiusSquared;
        }

        internal function clear():void
        {
        }
    }
}
