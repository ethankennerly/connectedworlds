package com.finegamedesign.connectedworlds
{
    import flash.utils.getTimer;

    /**
     * 2014-08-24 End.  Kerry at The MADE expects to score.
     */
    internal final class Referee
    {
        internal var connectionTrial:int = 0;
        private var connectionCount:int = 0;
        private var milliseconds:int;
        private var start:int;

        public function Referee()
        {
            start = getTimer();
        }

        internal function get connectionsPerMinute():int
        {
            var rate:int = Math.ceil(connectionCount * 60000 / milliseconds);
            return rate;
        }

        internal function record():void
        {
            this.connectionCount += connectionTrial;
            milliseconds = getTimer() - start;
            trace("Referee.record: connectionsPerMinute " + connectionsPerMinute);
        }
    }
}
