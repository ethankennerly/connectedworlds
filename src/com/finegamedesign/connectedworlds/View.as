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
        internal var model:Model;
        internal var screen:Screen;
        private var lines:Sprite;
        private var connection:Sprite;
        private var lineThickness:Number = 8.0;
        private var lineColor:Number = 0x006699;
        private var previousDot:DotClip;
        private var progress:Sprite;
        private var progressColor:Number = 0xCCFFFF;
        private var tutorClip:TutorClip;

        public function View(parent:DisplayObjectContainer)
        {
            screen = new Screen();
            parent.addChild(screen);
            lines = new Sprite();
            progress = new Sprite();
            connection = new Sprite();
            tutorClip = new TutorClip();
            tutorClip.gotoAndStop(1);
            screen.canvas.addChild(lines);
            screen.canvas.addChild(connection);
            screen.canvas.addChild(progress);
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
            remove(tutorClip);
        }

        internal function clearLines():void
        {
            lines.graphics.clear();
        }

        private function drawLines(lines:Sprite):void
        {
            lines.graphics.clear();
            lines.graphics.lineStyle(lineThickness, lineColor);
            for each(var ij:Array in model.connections) {
                var xy0:Array = model.dots[ij[0]];
                var xy1:Array = model.dots[ij[1]];
                lines.graphics.moveTo(xy0[0], xy0[1]);
                lines.graphics.lineTo(xy1[0], xy1[1]);
            }
        }

        internal function drawConnection(fromDotIndex:int, toDotIndex:int):void
        {
            if (fromDotIndex <= -1 || toDotIndex <= -1) {
                return;
            }
            connection.graphics.lineStyle(lineThickness, lineColor);
            var xy0:Array = model.dots[fromDotIndex];
            var xy1:Array = model.dots[toDotIndex];
            trace("View.drawConnection: from " + xy0 + " to " + xy1);
            connection.graphics.moveTo(xy0[0], xy0[1]);
            connection.graphics.lineTo(xy1[0], xy1[1]);
        }

        internal function drawProgress(dotIndex:int, 
                x:Number, y:Number):void
        {
            progress.graphics.clear();
            if (dotIndex <= -1) {
                return;
            }
            progress.graphics.lineStyle(lineThickness, progressColor);
            progress.graphics.moveTo(dots[dotIndex].x, dots[dotIndex].y);
            progress.graphics.lineTo(x, y);
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
            drawProgress(-1, 0, 0);
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
            connection.graphics.clear();
            progress.graphics.clear();

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

        internal function tutor():void
        {
            screen.canvas.addChild(tutorClip);
            tutorClip.gotoAndPlay(1);
        }
    }
}
