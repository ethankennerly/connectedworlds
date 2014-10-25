package com.finegamedesign.connectedworlds
{
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.utils.getTimer;

    import org.flixel.system.input.KeyMouse;
    // import org.flixel.plugin.photonstorm.API.FlxKongregate;
    // import com.newgrounds.API;

    public dynamic class Main extends Sprite
    {
        internal var keyMouse:KeyMouse;
        private var model:Model;
        private var view:View;
        private var sounds:Sounds;
        private var levelPrevious:int = 0;

        public function Main()
        {
            if (stage) {
                init(null);
            }
            else {
                addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
            }
        }
        
        public function init(event:Event=null):void
        {
            sounds = new Sounds();
            scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            keyMouse = new KeyMouse();
            keyMouse.listen(stage);
            levelPrevious = Shared.level;
            if (null != model) {
                levelPrevious = model.level;
            }
            model = new Model(levelPrevious);
            LevelSelect.milestoneCount = model.milestoneCount;
            LevelSelect.milestoneMax = model.milestoneMax;
            LevelSelect.onSelect = selectMilestone;
            view = new View(this);
            view.screen.mouseChildren = false;
            view.screen.mouseEnabled = false;
            view.screen.easel.addEventListener(
                MouseEvent.MOUSE_MOVE,
                answer, false, 0, true);
            addEventListener(Event.ENTER_FRAME, update, false, 0, true);
            view.screen.addFrameScript(2, trial);
            view.screen.addFrameScript(view.screen.totalFrames - 2, trialLoop);
            // var trialFrame:int = 105;
            view.backgroundClip.addFrameScript(view.backgroundClip.totalFrames - 2, restart);
            // API.connect(root, "", "");
        }

        private function restart():void
        {
            view.restart();
            init();
        }

        private function selectMilestone(milestone:int):void
        {
            if ("trialEnable" != view.backgroundClip.currentLabel) {
                model.selectMilestone(milestone);
                view.backgroundClip.gotoAndPlay("trialEnable");
            }
        }

        private function trialEnable():void
        {
            // trace("Main.trialEnable");
            model.enabled = true;
            view.backgroundClip.stop();
            view.screen.gotoAndPlay("begin");
            view.screen.mouseChildren = true;
            view.screen.mouseEnabled = true;
        }

        private function trialLoop():void
        {
            if (model.enabled) {
                view.screen.gotoAndPlay("begin");
            }
            else {
                view.hideScreen();
            }
        }

        public function trial():void
        {
            clear();
            model.populate();
            view.populate(model);
            if (model.level < model.levelTutor) {
                view.prompt(model.connections);
                view.hintDistractors(model.distractors);
            }
            else if (model.review) {
                view.review();
            }
        }

        /**
         * Cheats to quickly test:
         *      "ENTER" complete trial.
         *      "DELETE", "ESC", "X" this is the last trial. DELETE key different on Mac than Windows.
         */
        private function update(event:Event):void
        {
            var now:int = getTimer();
            keyMouse.update();
            // After stage is setup, connect to Kongregate.
            // http://flixel.org/forums/index.php?topic=293.0
            // http://www.photonstorm.com/tags/kongregate
            /* 
            if (! FlxKongregate.hasLoaded && stage != null) {
                FlxKongregate.stage = stage;
                FlxKongregate.init(FlxKongregate.connect);
            }
             */
            if (keyMouse.justPressed("DELETE")
             || keyMouse.justPressed("ESCAPE")
             || keyMouse.justPressed("X")) {
                model.truncate();
            }
            if (keyMouse.justPressed("ENTER")) {
                if (model.enabled) {
                    trialEnd(true);
                }
            }
            if (keyMouse.justPressed("MOUSE")) {
                model.listen();
            }
            if (!model.enabled && !model.inTrial 
            && "trialEnable" == view.backgroundClip.currentLabel) {
                trialEnable();
            }
        }

        private function trialEnd(correct:Boolean):void
        {
            model.trialEnd(correct);
            view.trialEnd();
            if (correct) {
                if (model.reviewing) {
                    Shared.level = model.level;
                }
                if (model.enabled) {
                    view.win();
                }
                else {
                    view.end();
                }
            }
            // FlxKongregate.api.stats.submit("Score", Model.score);
            // API.postScore("Score", Model.score);
        }

        public function clear():void
        {
            if (null != view) {
                view.clear();
            }
        }

        // Game-specific:

        /**
         * Only play screen if model is still enabled and complete.
         * If already connected, play no sound.
         * Lines remain until mouse button released after previous trial.  2014-08-29 Mouse down. Wrong.  Next.  Mouse still down and happens to be over a dot.  Samantha Yang expects to see lines.  Got lines disappear; felt confused.  
         */
        private function answer(e:MouseEvent):void
        {
            if (model.listening) {
                var down:Boolean = keyMouse.pressed("MOUSE");
                if (down) {
                    var x:Number = e.currentTarget.mouseX;
                    var y:Number = e.currentTarget.mouseY;
                    var dot:DotClip = view.nextDotAt(x, y);
                    if (null == dot) {
                        view.drawProgress(model.to, x, y);
                    }
                    else {
                        if (model.linesVisible) {
                            model.linesVisible = false;
                            view.clearLines();
                        }
                        var result:int = model.answer(dot.x, dot.y);
                        if (result <= -1) {
                            view.drawConnection(model.from, model.to, false);
                            sounds.wrong();
                            trialEnd(false);
                        }
                        if (1 <= result) {
                            sounds.correct();
                            view.drawConnection(model.from, model.to, true);
                            if (model.complete)
                            {
                                trialEnd(true);
                            }
                        }
                    }
                }
                else {
                    model.cancel();
                    view.cancel();
                }
            }
            if (model.enabled && model.complete) {
                view.screen.play();
            }
        }
    }
}
