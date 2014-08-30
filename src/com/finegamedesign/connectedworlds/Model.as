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
        internal var listening:Boolean = false;
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
	     * Two lines.  One distractor.  Big dipper.  Distractor.  2014-08-29 Samantha Yang expects to feel aware of distractors.
	     * Mouth instead of checkmark.  2014-08-29 Checkmark.  Samantha Yang confused if this is feedback or input.
         */
        private var graphs:Array;
        internal var lines:Boolean;
        internal var to:int;
        internal var referee:Referee = new Referee();
        internal var trial:int = 0;
        /**
         * End after 10 trials.  2014-08-28 After 17 trials of 256 dots. 4 minutes.  Mark Scoptur expects brief.
         */
        internal var trialMax:int = 6;

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
            trialMax = trial;
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
            inTrial = true;
            listening = false;
            if (levelTutor <= level) {
                referee.start();
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
                    referee.add++;
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
        /**
         * Review.  Wrong.  Repeat.  2014-08-29 Review Wrong.  Samantha Yang expects to fix repeat number.
         */
        internal function trialEnd(correct:Boolean):void
        {
            if (!inTrial) {
                return;
            }
            inTrial = false;
            graphsOld[level] = true;
            if (correct) {
                referee.add = dots.length;
            }
            if (levelTutor <= level) {
                if (!reviewing) {
                    referee.stop();
                    trial++;
                }
            }
            if (correct) {
                if (reviewing) {
                    enabled = false;
                }
                else {
                    level = findNewLevel(true);
                }
            }
            else {
                if (reviewing) {
                }
                else {
                    level = findNewLevel(false);
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

        private var stepUp:Number = 2.0;
        private var stepUpMin:Number = 2.0;
        private var stepUpMax:Number = 4.0;
        private var stepUpRate:Number = 0.5;
        private var graphsOld:Object = {};
        /**
         * @return  If correct, up by 1 in tutorial, or 2 after tutorial.  If wrong down by 1, or repeat same level in tutorial.  If already seen this level, try next level in that direction.  If cannot find any, find next level in other direction.  If searched all, throw error.
         * Expects twice as many levels as trials.
         */
        private function findNewLevel(correct:Boolean):int
        {
            if (level < levelTutor) {
                return level + (correct ? 1 : 0);
            }
            var up:int;
            if (correct) {
                up = stepUp;
                stepUp += stepUpRate;
            }
            else {
                up = -1;
                stepUp = stepUpMin;
            }
            var next:int = Math.min(level + up, graphs.length - 1);
            up = 1;
            var head:int = next;
            var attempt:int = 0;
            while (next in graphsOld) {
                next += up;
                if (next < 0 || graphs.length - 1 <= next) {
                    head -= up;
                    next = head - up;
                }
                attempt++;
                if (1024 <= attempt) {
                    throw new Error("Expected to find new level.");
                }
            }
            return next;
        }
    }
}
