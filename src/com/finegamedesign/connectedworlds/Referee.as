package com.finegamedesign.connectedworlds
{
    import flash.utils.getTimer;

    /**
     * 2014-08-24 End.  Kerry at The MADE expects to score.
     */
    internal final class Referee
    {
        /**
         * Add count of connections.
         * 2014-11-04 Shelby Macleod expects score.  
         */
        internal var count:int = 0;
        private var millisecondsTotal:int = 0;
        private var millisecondsStart:int = 0;
        private var playing:Boolean = false;

        public function Referee()
        {
        }

        internal function get connectionsPerMinute():int
        {
            var rate:int = Math.ceil(count * 60000 
                / millisecondsTotal);
            return rate;
        }

        internal function start():void
        {
            if (!playing) {
                playing = true;
                millisecondsStart = getTimer();
            }
        }

        internal function stop():void
        {
            if (playing) {
                playing = false;
                var milliseconds:int = getTimer() - millisecondsStart;
                millisecondsTotal += milliseconds;
                trace("Referee.stop: connectionsPerMinute " + connectionsPerMinute + " milliseconds " 
                    + milliseconds + " count " + count);
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

        internal function get score():int
        {
            return connectionsPerMinute;
        }
    }
}
