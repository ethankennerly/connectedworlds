package com.finegamedesign.connectedworlds
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;

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
        /**
         * Line narrower than dot diameter.  2014-08-29 Line covers dot.  Samantha Yang expects to feel aware to trace line now.  Got confused.
         */
        private var lineThickness:Number = // 8.0;
                                           // 32.0;
                                           // 48.0;
                                           64.0;
        private var lineColor:uint = 0x006699;
        private var wrongLineColor:uint = 0xFF3299;
        private var previousDot:DotClip;
        private var progress:Sprite;
        private var progressColor:uint = 0xCCFFFF;
        private var radius:Number = GraphGen.dotRadius;
        private var radiusSquared:Number;
        private var reviewClip:ReviewClip;
        private var _prompt:Prompt;

        /**
         * In BackgroundClip timeline:  After panning, just before first trial, eyes wake up, blink, look up.  Goes to sleep.  2014-08-25 End.  Tyler Hinman expects animation to save the baby.
         */ 
        public function View(parent:DisplayObjectContainer)
        {
            radiusSquared = radius * radius;
            _prompt = new Prompt();
            screen = new Screen();
            backgroundClip = new BackgroundClip();
            parent.addChild(backgroundClip);
            backgroundClip.gotoAndPlay("begin");
            parent.addChild(screen);
            screen.gotoAndStop(1);
            progress = new Sprite();
            connection = new Sprite();
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
            backgroundClip.gotoAndPlay("end");
            screen.addFrameScript(screen.totalFrames - 1, screen.stop);
        }

        internal function hideScreen():void
        {
            // trace("View.hideScreen");
            remove(reviewClip);
            reviewClip.visible = false;
            screen.stop();
            screen.visible = false;
            remove(screen);
        }

        internal function populate(model:Model):void
        {
            this.model = model;
            drawDots();
            drawLines();
        }

        private function drawDots():void
        {
            dots = [];
            for each(var xy:Array in model.dots) {
                // trace("View.populate: " + xy);
                var dot:DotClip = new DotClip();
                dot.x = int(Math.round(xy[0]));
                dot.y = int(Math.round(xy[1]));
                dots.push(dot);
                screen.dots.addChild(dot);
            }
        }

        private function drawLines():void
        {
            var lines:Sprite = screen.lines;
            removeAll(lines);
            lines.graphics.clear();
            lines.graphics.lineStyle(lineThickness, lineColor);
            for each(var ij:Array in model.connections) {
                var xy0:Array = model.dots[ij[0]];
                var xy1:Array = model.dots[ij[1]];
                lines.graphics.moveTo(xy0[0], xy0[1]);
                lines.graphics.lineTo(xy1[0], xy1[1]);
            }
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
            reviewClip.count.text = model.referee.count.toString();
            reviewClip.minutes.text = model.referee.minutes;
            reviewClip.score.text = model.referee.score.toString();
            reviewClip.count.mouseEnabled = false;
            reviewClip.minutes.mouseEnabled = false;
        }

        internal function win():void
        {
            if ("trial" != backgroundClip.currentLabel) {
                backgroundClip.gotoAndPlay("trial");
            }
        }

        internal function clearLines():void
        {
            _prompt.destroy();
            screen.gotoAndPlay("input");
        }

        internal function drawConnection(fromDotIndex:int, toDotIndex:int,
                correct:Boolean):void
        {
            if (toDotIndex <= -1) {
                return;
            }
            var dot1:DotClip = dots[toDotIndex];
            animateDot(dot1);
            if (fromDotIndex <= -1) {
                return;
            }
            var dot0:DotClip = dots[fromDotIndex];
            var color:uint = correct ? lineColor : wrongLineColor;
            connection.graphics.lineStyle(lineThickness, color);
            // trace("View.drawConnection: from " + xy0 + " to " + xy1);
            connection.graphics.moveTo(dot0.x, dot0.y);
            connection.graphics.lineTo(dot1.x, dot1.y);
        }

        /**
	     * Connect as shown.  Animate ring exploding and then imploding from dot.  Hopefully reward connecting as shown.  2014-08-25 Trackpad.  Erin McCarty expects to see connection event.  2014-08-25 Tyler expects to realize speed is graded.    
         */
        private function animateDot(dot:DotClip):void
        {
            dot.play();
        }

        internal function drawProgress(dotIndex:int, 
                x:Number, y:Number):void
        {
            progress.graphics.clear();
            if (dotIndex <= -1) {
                return;
            }
            progress.graphics.lineStyle(lineThickness, progressColor);
            var dot:DotClip = dots[dotIndex];
            progress.graphics.moveTo(dot.x, dot.y);
            progress.graphics.lineTo(x, y);
        }

        internal function update()
        {
            if (model) {
                screen.lines.alpha = model.alpha;
            }
        }

        /**
         * @return  Distance squared, unless out of range, then infinity.
         */
        private function near(dx:Number, dy:Number):Number
        {
            var distanceSquared:Number = dx * dx + dy * dy;
            if (distanceSquared < radiusSquared) {
                return distanceSquared;
            }
            else {
                return Number.POSITIVE_INFINITY;
            }
        }

        /**
         * @return  Nearest dot.
         */
        internal function nextDotAt(x:Number, y:Number):DotClip
        {
            var nearest:DotClip;
            var nearestDistanceSquared:Number = Number.POSITIVE_INFINITY;
            for each(var dot:DotClip in dots) {
                var distanceSquared:Number = near(dot.x - x, dot.y - y);
                if (distanceSquared < nearestDistanceSquared) {
                    // trace("View.dotAt: x " + x + " y " + y + " dot " + dot.x + ", " + dot.y);
                    if (dot != previousDot) {
                        previousDot = dot;
                        nearest = dot;
                        nearestDistanceSquared = distanceSquared;
                    }
                    break;
                }
            }
            return nearest;
        }

        internal function cancel():void
        {
            previousDot = null;
            drawProgress(-1, 0, 0);
            _prompt.destroy();
        }

        internal function trialEnd():void
        {
            cancel();
            if ("end" != screen.currentLabel) {
                screen.gotoAndPlay("end");
            }
        }

        internal function clear():void
        {
            cancel();
            for each(var dot:DotClip in dots) {
                remove(dot);
            }
            screen.lines.graphics.clear();
            connection.graphics.clear();
            progress.graphics.clear();
        }

        internal function restart():void
        {
            clear();
            remove(screen);
            backgroundClip.stop();
            screen.stop();
            remove(backgroundClip);
        }

        internal static function remove(dot:DisplayObject):void
        {
            if (null != dot && null != dot.parent && dot.parent.contains(dot)) {
                dot.parent.removeChild(dot);
            }
        }

        private static function removeAll(lines:DisplayObjectContainer):void
        {
            for (var c:int = lines.numChildren - 1; 0 <= c; c--) {
                remove(lines.getChildAt(c));
            }
        }

        internal function prompt(connections:Array):void
        {
            _prompt.lines(connections, dots, progress);
        }

        internal function hintDistractors(dotIndexes:Array):void
        {
            for each(var dotIndex:int in dotIndexes) {
                var dot:DotClip = dots[dotIndex];
                var distractorHint:DistractorHint = new DistractorHint();
                distractorHint.x = dot.x;
                distractorHint.y = dot.y;
                screen.lines.addChild(distractorHint);
            }
        }
    }
}
