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
        /**
         * My illustration after image of baby girl sleeping:
         * http://www.7sib.ir/sites/default/files/users/12/article/images/child-sleep.jpg
         */
        internal var backgroundClip:BackgroundClip;
        private var lines:Sprite;
        private var connection:Sprite;
        private var lineThickness:Number = // 8.0;
                                            32.0;
        private var lineColor:Number = 0x006699;
        private var previousDot:DotClip;
        private var progress:Sprite;
        private var progressColor:Number = 0xCCFFFF;
        private var radius:Number = 24;
                                    // 40;
        private var radiusSquared:Number;
        private var reviewClip:ReviewClip;
        /**
         * 2014-08-23 Aaron at The MADE expects to emphasize ring at dot.
         * Diagonal motion with finger to touch.  2014-08-23 Jennifer Russ expects to recognize icon and motion to swipe.  Got confused that it was a loading bar.  2014-08-24 Beth expects to see instructions on what to do.
         */
        private var tutorClip:TutorClip;

        public function View(parent:DisplayObjectContainer)
        {
            radiusSquared = radius * radius;
            screen = new Screen();
            backgroundClip = new BackgroundClip();
            parent.addChild(backgroundClip);
            backgroundClip.gotoAndPlay("begin");
            parent.addChild(screen);
            screen.gotoAndStop(1);
            progress = new Sprite();
            connection = new Sprite();
            tutorClip = new TutorClip();
            tutorClip.mouseChildren = false;
            tutorClip.mouseEnabled = false;
            tutorClip.gotoAndStop(1);
            screen.dots.mouseChildren = false;
            screen.dots.mouseEnabled = false;
            screen.canvas.mouseChildren = false;
            screen.canvas.mouseEnabled = false;
            screen.canvas.addChild(connection);
            screen.canvas.addChild(progress);
            screen.lines.mouseChildren = false;
            screen.lines.mouseEnabled = false;
            remove(screen.dots.getChildAt(0));
            remove(screen.lines.getChildAt(0));
            remove(screen.canvas.getChildAt(0));
        }

        internal function end():void
        {
            remove(reviewClip);
            backgroundClip.gotoAndPlay("end");
            screen.addFrameScript(screen.totalFrames - 1, screen.stop);
        }

        internal function populate(model:Model):void
        {
            dots = [];
            this.model = model;
            for each(var xy:Array in model.dots) {
                // trace("View.populate: " + xy);
                var dot:DotClip = new DotClip();
                dot.x = int(Math.round(xy[0]));
                dot.y = int(Math.round(xy[1]));
                dots.push(dot);
                screen.dots.addChild(dot);
            }
            drawLines(screen.lines);
            remove(tutorClip);
        }

        /**
         * At top of screen, when showing digits, show "* / @ =", where @ looks like a clock icon.  Black background covers disconnected dots.  2014-08-25 Tyler Hinman expects to recognize speed.  Got dots. 
         */
        internal function review():void
        {
            screen.stop();
            reviewClip = new ReviewClip();
            screen.addChild(reviewClip);
            reviewClip.addFrameScript(reviewClip.totalFrames - 3, screen.play);
        }

        internal function win():void
        {
            if ("trial" != backgroundClip.currentLabel) {
                backgroundClip.gotoAndPlay("trial");
            }
        }

        internal function clearLines():void
        {
            screen.gotoAndPlay("input");
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
            // trace("View.drawConnection: from " + xy0 + " to " + xy1);
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
            return ((dx * dx + dy * dy) <= radiusSquared);
        }

        internal function clear():void
        {
            for each(var dot:DotClip in dots) {
                remove(dot);
            }
            remove(tutorClip);
            screen.lines.graphics.clear();
            connection.graphics.clear();
            progress.graphics.clear();
        }

        internal function remove(dot:DisplayObject):void
        {
            if (dot.parent && dot.parent.contains(dot)) {
                dot.parent.removeChild(dot);
            }
        }

        internal function tutor():void
        {
            progress.addChild(tutorClip);
            tutorClip.gotoAndPlay(1);
        }
    }
}
