package com.finegamedesign.connectedworlds
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;

    import com.greensock.TweenLite;
    import com.greensock.TimelineMax;

    internal class Prompt
    {
        /**
         * 2014-08-23 Aaron at The MADE expects to emphasize ring at dot.
         * Diagonal motion with finger to touch.  2014-08-23 Jennifer Russ expects to recognize icon and motion to swipe.  Got confused that it was a loading bar.  2014-08-24 Beth expects to see instructions on what to do.
         */
        internal var handClip:HandClip;
        private var dots:Array;
        private var connectionIndex:int;
        private var connections:Array;
        private var parent:DisplayObjectContainer;
        private var timeline:TimelineMax;

        public function Prompt()
        {
            handClip = new HandClip();
            handClip.mouseChildren = false;
            handClip.mouseEnabled = false;
            handClip.gotoAndStop(1);
        }

        internal function destroy():void
        {
            if (null != timeline) {
                timeline.stop();
                timeline = null;
            }
            if (null != handClip) {
                View.remove(handClip);
            }
        }

        private function copy(connections:Array):Array
        {
            var copied:Array = [];
            for (var c:int = 0; c < connections.length; c++) {
                 copied.push(connections[c].concat());
            }
            return copied;
        }

        /**
         * DEPRECATED
         * Shuffle 2D array of edges.
         */
        private function shuffle(connections:Array):Array
        {
            var shuffled:Array = copy(connections);
            for (var s:int = shuffled.length - 1; 1 <= s; s--) {
                var r:int = Math.random() * (s + 1);
                if (s != r) {
                    var swap:Array = shuffled[s];
                    shuffled[s] = shuffled[r];
                    shuffled[r] = swap;
                }
                if (Math.random() < 0.5) {
                    var swapInteger:int = shuffled[s][0];
                    shuffled[s][0] = shuffled[s][1];
                    shuffled[s][1] = swapInteger;
                }
            }
            return shuffled;
        }

        /**
         * Animate lines that were already ordered in drawing order.
         * 2014-09-15 Eyes diagram.  Mary Ann Quintin may expect to see hand lift.  Got confused and tried to connect separate lines.
         */
        internal function lines(connections:Array, dots:Array, parent:DisplayObjectContainer):void
        {
            this.connections = copy(connections);
            //- this.connections = shuffle(connections);
            this.dots = dots;
            this.parent = parent;
            connectionIndex = 0;
            nextLine();
        }

        /**
         * Prompt traces between a connection.  2014-08-29 checkmark.  Samantha Yang expects to feel aware to trace.  Got confused.
         */
        internal function nextLine():void
        {
            if (connections.length <= connectionIndex) {
                connectionIndex = 0;
                //- connections = shuffle(connections);
            }
            var dotIndexes:Array = connections[connectionIndex];
            var dot0:DisplayObject = dots[dotIndexes[0]];
            var dot1:DisplayObject = dots[dotIndexes[1]];
            var handClip:HandClip = line(dot0.x, dot0.y, dot1.x, dot1.y);
            parent.addChild(handClip);
            connectionIndex++;
        }

        /**
         * Trace from current position to end position at start seconds until end seconds.  Repeat.
         */
        internal function line(
                x0:Number, y0:Number, x1:Number, y1:Number):HandClip
        {
            destroy();
            var startSeconds:Number = 40.0 / 30.0;
            var holdSeconds:Number = 20.0 / 30.0;
            var endSeconds:Number = 90.0 / 30.0;
            var repeatSeconds:Number = 101.0 / 30.0;
            handClip.x = x0;
            handClip.y = y0;
            handClip.gotoAndStop("none");
            timeline = new TimelineMax();
            timeline.add(TweenLite.to(handClip, startSeconds, {x: handClip.x, y: handClip.y,
                onComplete: begin}));
            timeline.add(TweenLite.to(handClip, holdSeconds, {x: handClip.x, y: handClip.y}));
            timeline.add(TweenLite.to(handClip, endSeconds - startSeconds, {x: x1, y: y1,
                onComplete: end}));
            timeline.add(TweenLite.to(handClip, repeatSeconds - endSeconds, {x: x1, y: y1,
                onComplete: nextLine}));
            return handClip;
        }

        private function begin():void
        {
            handClip.gotoAndPlay("begin");
        }

        private function end():void
        {
            handClip.gotoAndPlay("end");
        }
    }
}
