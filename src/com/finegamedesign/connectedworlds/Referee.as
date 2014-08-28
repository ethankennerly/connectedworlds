package com.finegamedesign.connectedworlds
{
    import flash.utils.getTimer;

    /**
     * 2014-08-24 End.  Kerry at The MADE expects to score.
     */
    internal final class Referee
    {
        private var _count:int = 0;
        private var millisecondsTotal:int;
        private var millisecondsStart:int;
        private var playing:Boolean;
        private var trial:int = 0;

        public function Referee()
        {
        }

        internal function get connectionsPerMinute():int
        {
            var rate:int = Math.ceil(_count * 60000 
                / millisecondsTotal);
            return rate;
        }

        internal function start(trial:int):void
        {
            this.trial = trial;
            if (!playing) {
                playing = true;
                millisecondsStart = getTimer();
            }
        }

        internal function stop():void
        {
            if (playing) {
                playing = false;
                millisecondsTotal += getTimer() - millisecondsStart;
                _count += trial;
                trace("Referee.stop: connectionsPerMinute " + connectionsPerMinute);
            }
        }

        /**
         * 2014-08-27 Jennifer Russ may understand number by reading format like "1:20".
         */
        internal function get minutes():String
        {
            const secPerMin:int = 60;
            var seconds:int = Math.ceil(millisecondsTotal / 1000);
            var min:int = seconds / secPerMin;
            var sec:int = seconds % secPerMin;
            var lead:String = sec < 10 ? "0" : "";
            return min + ":" + lead + sec;
        }

        internal function get count():String
        {
            return _count.toString();
        }
    }
}
