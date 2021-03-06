package com.finegamedesign.connectedworlds
{
    public class Model
    {
        internal var alpha:Number;
        internal var fadeDuration:Number;
        internal var alphaDraw:Number;
        internal var connections:Array;
        internal var connectionsOld:Array;
        internal var connecting:Array;
        internal var dots:Array;
        internal var distractors:Array;
        internal var enabled:Boolean = false;
        internal var from:int;
        internal var inTrial:Boolean = false;
        internal var listening:Boolean = false;
        internal var level:int = 0;
        internal var milestoneCount:int = 0;
        internal var milestoneMax:int = 0;
        /**
         * Timer starts at fifth trial, after tutoring disconnected dots.  2014-08-25 Tyler Hinman expects to timer starts after first trial.
         */
        internal var levelTutor:int = 6;
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
        internal var linesVisible:Boolean;
        internal var to:int;
        internal var referee:Referee = new Referee();
        internal var reviewing:Boolean = false;
        internal var trial:int = 0;
        /**
         * End after 10 trials.  2014-08-28 After 17 trials of 256 dots. 4 minutes.  Mark Scoptur expects brief.
         */
        internal var trialMax:int;
        internal var tutor:Boolean;
        /**
         * Otherwise keep it simple.
         */
        internal var advanced:Boolean = false;

        internal function get graphsLength():int
        {
            return graphs.length - 1;
        }

        /**
         * Add review graph.
         * All milestones available except last.
         */
        public function Model(levelPrevious:int=0):void
        {
            include "Levels.as"
            level = levelPrevious;
            if (advanced) {
                graphs.push({});
                spliceGraphs();
                trialMax = 8;
            }
            else {
                trialMax = graphs.length;
                graphs = GraphGen.introduce(graphs);
            }
            adjustAlpha(false);
            tutor = true;
            milestoneCount = graphs.length / trialMax;
            milestoneMax = milestoneCount * level / graphs.length + 1;
        }

        private function spliceGraphs():void
        {
            var spliceArguments:Array = [levelTutor, 0].concat(new GraphGen().graphs);
            graphs.splice.apply(graphs, spliceArguments);
            spliceArguments = [graphs.length - 1, 0].concat(new GraphGen().graphs.slice(10));
            graphs.splice.apply(graphs, spliceArguments);
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
         * @return 0 to 5.
         */
        internal function get degree():int
        {
            var degree:int = level / 10;
            if (tutor) {
                degree = Math.min(0, degree);
            }
            if (!advanced) {
                degree = Math.min(2, degree);
            }
            else {
                degree = Math.min(5, degree);
            }
            return degree;
        }

        /**
         * Score total dots.
         * Distractors make the connections more difficult.
         * Cache sorted connections for faster lookup.
         */
        internal function populate():void
        {
            cancel();
            connectionsOld = [];
            alpha = 1.0;
            var params:Object = graphs[level];
            if (advanced) {
                tutor = level < levelTutor;
            }
            if (!tutor && level && trial < trialMax) {
                params = GraphGen.vary(params, degree);
            }
            for (var prop:String in params) {
                this[prop] = Util.clone(params[prop]);
            }
            linesVisible = true;
            inTrial = true;
            listening = false;
            distractors = GraphGen.findSingles(connections, dots.length);
            if (!tutor) {
                referee.start();
            }
        }

        internal function selectMilestone(milestone:int):void
        {
            level = (milestone - 1) * trialMax;
        }

        internal function cancel():void
        {
            connecting = [];
            from = -1;
            to = -1;
        }

        internal function listen():void
        {
            if (inTrial && !listening) {
                listening = true;
            }
        }

        /**
         * @return  -1: example was not connected, 0: already connected, 1: new connection.
         * 2014-09-11 Retrace already connected.  Ben expects to not be judged.
         */
        internal function answer(x:int, y:int):int
        {
            alpha = alphaDraw;
            var result:int = -1;
            if (complete) {
                result = 1;
            }
            else {
                referee.stop();
            }
            var dotIndex:int = -1;
            for (var d:int = 0; d < dots.length; d++) {
                var xy:Array = dots[d];
                if (x == Math.round(xy[0]) && y == Math.round(xy[1])) {
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
            var c:int = indexOf(connections, connecting);
            if (0 <= c) {
                connections.splice(c, 1);
                connectionsOld.push(connecting);
                result = 1;
                referee.count++;
            }
            if (connecting[0] == connecting[1]) {
                result = 1;
            }
            if (result <= -1) {
                var old:Boolean = 0 <= indexOf(connectionsOld, connecting);
                if (old) {
                    result = 0;
                }
            }
            connecting = [dotIndex];
            from = to;
            to = dotIndex;
            // trace("Model.answer: " + result + " x " + x + " y " + y + " connecting " + connecting);
            return result;
        }

        /**
         * @return index of either pair matches in either order.  else -1.
         */
        private function indexOf(connections:Array, connecting:Array):int
        {
            var index:int = -1;
            for (var c:int = 0; c < connections.length; c++) {
                var connection:Array = connections[c];
                if ((connecting[0] == connection[0] 
                        && connecting[1] == connection[1])
                || (connecting[1] == connection[0] 
                        && connecting[0] == connection[1])) {
                    index = c;
                    break;
                }
            }
            return index;
        }

        internal function get only():Boolean
        {
            return 0 == level && connecting.length <= 0;
        }

        internal function get complete():Boolean
        {
            return null != connections && connections.length <= 0;
        }

        /**
         * Gradually reduce opacity over 10 consecutive correct trials.
         * A wrong response resets opacity.
         * 2014-11-25 Faraz expects outline remains.  
         * 3-year-old boy expects to feel aware of goal to connect only some dots.
         */
        private function adjustAlpha(correct:Boolean):void
        {
            if (advanced) {
                alphaDraw = 0.0;
                fadeDuration = 0.5;
            }
            else {
                var trialCount:int = 16.0;
                alphaDraw = correct ? Math.max(0.0, alphaDraw - 1.0 / trialCount * 0.5)
                                    : 0.5;
                tutor = 0.0 < alphaDraw;
                fadeDuration = 4.0;
            }
        }

        /**
         * Review.  Wrong.  Repeat.  2014-08-29 Review Wrong.  Samantha Yang expects to fix repeat number.
         * If reviewing and correct, disable. 2014-09-09 Review.  Complete.  Expect to fix to continue.  Got repeat review.
         */
        internal function trialEnd(correct:Boolean):void
        {
            if (!inTrial) {
                return;
            }
            alpha = 0.0;
            adjustAlpha(correct);
            inTrial = false;
            listening = false;
            graphsOld[level] = true;
            if (!tutor) {
                if (!reviewing) {
                    if (correct) {
                        referee.count += dots.length;
                    }
                    trial++;
                }
            }
            if (reviewing) {
                enabled = !correct;
            }
            else {
                level = findNewLevel(correct);
            }
            if (!reviewing && review) {
                if (advanced) {
                    reviewing = true;
                    truncate();
                    reverseGraph0();
                }
                else {
                    enabled = false;
                }
            }
        }

        /**
         * Trace first line with prompt in reverse.  Was trace score.  Shift down to not overlap score.  2014-09-01 Amy expects not to trace score. (2014-09-05 +Mark Palange, +Ben Ahroni)
         */
         private function reverseGraph0():void
         {
            graphs[level] = Util.clone(graphs[0]);
            graphs[level].dots.reverse();
            var down:int = 90;
            graphs[level].dots[0][1] += down;
            graphs[level].dots[1][1] += down;
         }

        internal function get review():Boolean
        {
            return trialMax <= trial;
        }

        private var stepUp:Number = 1.0;
        private var stepUpMin:Number = 1.0;
        private var stepUpMax:Number = 3.0;
        /**
         * If too high, repeats.
         * 2014-11-01 Jennifer Russ expects to unlock a level if making one mistake.
         */
        private var stepUpRate:Number = // 0.25;
                                        0.5;
                                        // 1.25;  
                                        // 1.5;
        private var graphsOld:Object = {};
        /**
         * @return  If correct, up by 1 in tutorial, or 2 after tutorial.  If wrong down by 1, or repeat same level in tutorial.  If already seen this level, try next level in that direction.  If cannot find any, find next level in other direction.  If searched all, throw error.
         * Expects twice as many levels as trials.
         */
        internal function findNewLevel(correct:Boolean):int
        {
            var up:int;
            var nextLevel:int;
            if (tutor || !advanced) {
                up = correct ? 1 : 0;
                nextLevel = Math.min(level + up, graphs.length - 1);
                return nextLevel;
            }
            if (correct) {
                up = stepUp;
                stepUp += stepUpRate;
                stepUp = Math.min(stepUpMax, stepUp);
            }
            else {
                up = -1;
                stepUp = stepUpMin;
            }
            trace("findNewLevel: level " + level + " stepUp " + stepUp);
            nextLevel = Math.min(level + up, graphs.length - 1);
            up = 1;
            var head:int = nextLevel;
            var attempt:int = 0;
            while (nextLevel in graphsOld) {
                nextLevel += up;
                if (nextLevel < 0 || graphs.length - 1 <= nextLevel) {
                    head -= up;
                    nextLevel = head - up;
                }
                attempt++;
                if (1024 <= attempt) {
                    throw new Error("Expected to find new level.");
                }
            }
            return nextLevel;
        }
    }
}
