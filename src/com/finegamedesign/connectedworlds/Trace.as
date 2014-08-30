package com.finegamedesign.connectedworlds
{
    import flash.display.MovieClip;

    import com.greensock.TweenLite;
    import com.greensock.TimelineMax;

    internal class Trace
    {
        private static var current:TimelineMax;
        private static var tutorClip:MovieClip;

        internal static function destroy():void
        {
            if (null != current) {
                current.stop();
                current = null;
            }
            if (null != tutorClip) {
                View.remove(tutorClip);
                tutorClip = null;
            }
        }

        /**
         * Trace from current position to end position at start seconds until end seconds.  Repeat.
         */
        public function Trace(tutorClip:MovieClip, 
                startSeconds:Number, endSeconds:Number, repeatSeconds:Number,
                x1:Number, y1:Number)
        {
            destroy();
            Trace.tutorClip = tutorClip;
            var timeline:TimelineMax = new TimelineMax({repeat: -1});
            timeline.add(TweenLite.to(tutorClip, 0.0, {x: tutorClip.x, y: tutorClip.y, onComplete: start}));
            timeline.add(TweenLite.to(tutorClip, startSeconds, {x: tutorClip.x, y: tutorClip.y}));
            timeline.add(TweenLite.to(tutorClip, endSeconds - startSeconds, {x: x1, y: y1}));
            timeline.add(TweenLite.to(tutorClip, repeatSeconds - endSeconds, {x: x1, y: y1}));
            current = timeline;
        }

        private function start():void
        {
            tutorClip.gotoAndPlay(1);
        }
    }
}
