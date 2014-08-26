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
        private var millisecondsTotal:int;
        private var millisecondsStart:int;
        private var playing:Boolean;

        public function Referee()
        {
        }

        internal function get connectionsPerMinute():int
        {
            var rate:int = Math.ceil(connectionCount * 60000 
                / millisecondsTotal);
            return rate;
        }

        internal function start(connectionTrial:int):void
        {
            this.connectionTrial = connectionTrial;
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
                connectionCount += connectionTrial;
                trace("Referee.stop: connectionsPerMinute " + connectionsPerMinute);
            }
        }
    }
}
