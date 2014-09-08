package com.finegamedesign.connectedworlds
{
    import flash.display.MovieClip;

    import com.greensock.TweenLite;
    import com.greensock.TimelineMax;

    internal class Trace
    {
        internal var handClip:MovieClip;
        private var current:TimelineMax;

        public function Trace()
        {
        }

        internal function destroy():void
        {
            if (null != current) {
                current.stop();
                current = null;
            }
            if (null != handClip) {
                View.remove(handClip);
                handClip = null;
            }
        }

        /**
         * Trace from current position to end position at start seconds until end seconds.  Repeat.
         */
        internal function line(
                x0:Number, y0:Number, x1:Number, y1:Number)
        {
            destroy();
            var startSeconds:Number = 80.0 / 30.0;
            var endSeconds:Number = 110.0 / 30.0;
            var repeatSeconds:Number = 150.0 / 30.0;
            Trace.handClip = handClip;
            handClip.x = x0;
            handClip.y = y0;
            var timeline:TimelineMax = new TimelineMax({repeat: -1});
            timeline.add(TweenLite.to(handClip, 0.0, {x: handClip.x, y: handClip.y, onComplete: start}));
            timeline.add(TweenLite.to(handClip, startSeconds, {x: handClip.x, y: handClip.y}));
            timeline.add(TweenLite.to(handClip, endSeconds - startSeconds, {x: x1, y: y1}));
            timeline.add(TweenLite.to(handClip, repeatSeconds - endSeconds, {x: x1, y: y1}));
            current = timeline;
        }

        private function start():void
        {
            handClip.gotoAndPlay(1);
        }
    }
}
