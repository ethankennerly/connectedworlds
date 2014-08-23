package com.finegamedesign.connectedworlds
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    public class View
    {
        internal var dots:Array;
        internal var lines:Sprite;
        internal var model:Model;
        internal var screen:Screen;
        private var previousDot:DotClip;

        public function View(parent:DisplayObjectContainer)
        {
            screen = new Screen();
            parent.addChild(screen);
            lines = new Sprite();
        }

        internal function populate(model:Model):void
        {
            dots = [];
            this.model = model;
            for each(var xy:Array in model.dots) {
                trace("View.populate: " + xy);
                var dot:DotClip = new StarClip();
                dot.x = int(Math.round(xy[0]));
                dot.y = int(Math.round(xy[1]));
                screen.canvas.addChild(dot);
                dots.push(dot);
            }
            drawLines(lines);
            screen.canvas.addChild(lines);
        }

        private function drawLines(lines:Sprite):void
        {
            lines.visible = true;
            lines.graphics.clear();
            lines.graphics.lineStyle(8.0, 0x65FFFF);
            for each(var ij:Array in model.connections) {
                var xy0:Array = model.dots[ij[0]];
                var xy1:Array = model.dots[ij[1]];
                lines.graphics.moveTo(xy0[0], xy0[1]);
                lines.graphics.lineTo(xy1[0], xy1[1]);
            }
        }

        internal function newDotAt(x:Number, y:Number):DotClip
        {
            var at:DotClip;
            for each(var dot:DotClip in dots) {
                if (near(dot.x - x, dot.y - y)) {
                    // trace("View.dotAt: x " + x + " y " + y + " dot " + dot.x + ", " + dot.y);
                    if (dot != previousDot) {
                        at = dot;
                        previousDot = dot;
                    }
                    break;
                }
            }
            return at;
        }

        internal function cancel():void
        {
            previousDot = null;
        }

        private function near(dx:Number, dy:Number):Boolean
        {
            var radius:Number = 40;
            var radiusSquared:Number = radius * radius;
            return ((dx * dx + dy * dy) <= radiusSquared);
        }

        internal function clear():void
        {
            for each(var dot:DotClip in dots) {
                remove(dot);
            }
            lines.graphics.clear();

            /*
            for (var c:int = screen.canvas.numChildren - 1; 
                    0 <= c; c--) {
                screen.canvas.removeChild(
                    screen.canvas.getChildAt(c));
            }
             */
        }

        private function remove(dot:DisplayObject):void
        {
            if (dot.parent && dot.parent.contains(dot)) {
                dot.parent.removeChild(dot);
            }
        }
    }
}
