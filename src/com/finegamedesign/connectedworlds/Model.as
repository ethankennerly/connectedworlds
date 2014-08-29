package com.finegamedesign.connectedworlds
{
    public class Model
    {
        internal var connections:Array;
        internal var connecting:Array;
        internal var dots:Array;
        internal var enabled:Boolean = false;
        internal var from:int;
        internal var inTrial:Boolean = false;
        internal var level:int = 0;
        /**
         * Timer starts at fifth trial, after tutoring disconnected dots.  2014-08-25 Tyler Hinman expects to timer starts after first trial.
         */
        internal var levelTutor:int = 4;
        /**
         * Several levels.
         *
         * Change log:
         * Reorder Heart, Star, Taurus, Butterfly, Moon, Bunny.
		 * 2014-08-24 Diana, Anders, Aubrey, Kerry expect ascending challenge.  Got frustrated at Moon and Bunny.
         * Aries.  Taurus.  Cancer.  Distractors. Star girl.  2014-08-24 Star face.  End.  Diana Salles expects more challenging.
         * Remove nearby unnecessary dots.  Gap at least 64 pixels.  2014-08-28 Aaron Kasluzka, Mark Scoptur, Sarah Clark expect to drag approximately.
         * Reorder by observed accuracy, especially: gemini and wink sooner, moon later.  2014-08-28 Aaron Kasluzka, Annie Zhou, Mark Scoptur, Sarah Clark may expect gradual increase in complexity.  Got stumped by moon.
         */
        private var graphs:Array;
        internal var lines:Boolean;
        internal var to:int;
        internal var referee:Referee = new Referee();
        internal var trial:int = 0;
        /**
         * End after 10 trials.  2014-08-28 After 17 trials of 256 dots. 4 minutes.  Mark Scoptur expects brief.
         */
        internal var trialMax:int = 10;

        /**
         * Add review graph.
         */
        public function Model():void
        {
            include "Levels.as"
            graphs.push({});
        }

        /**
         * Delete graphs after this one.
         */
        internal function truncate():void
        {
            graphs.length = level + 1;
            graphs.push({});
        }

        /**
         * Score total dots.
         * Distractors make the connections more difficult.
         */
        internal function populate():void
        {
            connecting = [];
            from = -1;
            to = -1;
            var params:Object = graphs[level];
            for (var prop:String in params) {
                this[prop] = Util.clone(params[prop]);
            }
            lines = true;
            if (levelTutor <= level) {
                referee.start(dots.length);
            }
        }

        internal function cancel():void
        {
            connecting = [];
            from = -1;
            to = -1;
        }

        /**
         * Answer expects each connection is numerically sorted.
         */
        internal function answer(x:int, y:int):int
        {
            var correct:int = -1;
            if (complete) {
                correct = 0;
            }
            var dotIndex:int = -1;
            for (var d:int = 0; d < dots.length; d++) {
                var dot:Array = dots[d];
                if (x == dot[0] && y == dot[1]) {
                    dotIndex = d;
                    break;
                }
            }
            if (dotIndex <= -1) {
                throw new Error("Expected dot at " + x + ", " + y);
            }
            if (connecting.length <= 0) {
                connecting.push(dotIndex);
            }
            connecting.push(dotIndex);
            connecting.sort(Array.NUMERIC);
            for (var c:int = connections.length - 1; 0 <= c; c--) {
                var connection:Array = connections[c];
                if (connecting[0] == connection[0] && connecting[1] == connection[1]) {
                    connections.splice(c, 1);
                    correct = dotIndex;
                }
            }
            if (connecting[0] == connecting[1]) {
                correct = dotIndex;
            }
            connecting = [dotIndex];
            from = to;
            to = dotIndex;
            // trace("Model.answer: " + correct + " x " + x + " y " + y + " connecting " + connecting);
            return correct;
        }

        internal function get only():Boolean
        {
            return 0 == level && connecting.length <= 0;
        }

        internal function get complete():Boolean
        {
            return null != connections && connections.length <= 0;
        }

        internal function clear():void
        {
        }

        private var reviewing:Boolean = false;

        internal function trialEnd(correct:Boolean):void
        {
            referee.stop();
            trial++;
            if (correct) {
                if (reviewing) {
                    enabled = false;
                }
                else {
                    level = (level + 1) % graphs.length;
                }
            }
            if (!reviewing && review) {
                reviewing = true;
                truncate();
                graphs[level] = Format.wholeNumber(
                    referee.connectionsPerMinute);
            }
        }

        internal function get review():Boolean
        {
            return trialMax <= trial;
        }
    }
}
