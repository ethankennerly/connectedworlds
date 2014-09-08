package com.finegamedesign.connectedworlds
{
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

        /**
         * Trace from current position to end position at start seconds until end seconds.  Repeat.
         */
        internal function line(
                x0:Number, y0:Number, x1:Number, y1:Number):HandClip
        {
            destroy();
            var startSeconds:Number = 80.0 / 30.0;
            var endSeconds:Number = 110.0 / 30.0;
            var repeatSeconds:Number = 150.0 / 30.0;
            handClip.x = x0;
            handClip.y = y0;
            timeline = new TimelineMax({repeat: -1});
            timeline.add(TweenLite.to(handClip, 0.0, {x: handClip.x, y: handClip.y, onComplete: start}));
            timeline.add(TweenLite.to(handClip, startSeconds, {x: handClip.x, y: handClip.y}));
            timeline.add(TweenLite.to(handClip, endSeconds - startSeconds, {x: x1, y: y1}));
            timeline.add(TweenLite.to(handClip, repeatSeconds - endSeconds, {x: x1, y: y1}));
            return handClip;
        }

        private function start():void
        {
            handClip.gotoAndPlay(1);
        }
    }
}
