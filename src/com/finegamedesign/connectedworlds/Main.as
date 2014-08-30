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
        private var loopChannel:SoundChannel;

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
            Sounds.instance = new Sounds();
            scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            keyMouse = new KeyMouse();
            keyMouse.listen(stage);
            //+ loopChannel = loop.play(0);
            model = new Model();
            view = new View(this);
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
            view.clear();
            view.remove(view.screen);
            view.backgroundClip.stop();
            view.screen.stop();
            view.remove(view.backgroundClip);
            init();
        }

        private function trialEnable():void
        {
            // trace("Main.trialEnable");
            model.enabled = true;
            view.backgroundClip.stop();
            view.screen.gotoAndPlay("begin");
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
            model.inTrial = true;
            model.populate();
            view.populate(model);
            if (0 == model.level) {
                view.tutor();
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
                    win();
                }
            }
            if (!model.enabled && !model.inTrial && "trialEnable" == view.backgroundClip.currentLabel) {
                trialEnable();
            }
        }

        private function win():void
        {
            model.trialEnd(true);
            if (!model.enabled) {
                view.end();
            }
            else {
                view.win();
            }
            reset();
            // FlxKongregate.api.stats.submit("Score", Model.score);
            // API.postScore("Score", Model.score);
        }

        private function reset():void
        {
            // trace("Main.reset");
            model.inTrial = false;
            if (null != loopChannel) {
                // loopChannel.stop();
            }
            view.cancel();
            if ("end" != view.screen.currentLabel) {
                view.screen.gotoAndPlay("end");
            }
        }

        private function lose():void
        {
            model.trialEnd(false);
            reset();
            // FlxKongregate.api.stats.submit("Score", Model.score);
            // API.postScore("Score", Model.score);
            // mouseChildren = false;
        }

        public function clear():void
        {
            if (model) {
                model.clear();
            }
            if (view) {
                view.clear();
            }
        }

        // Game-specific:

        /**
         * Only play screen if model is still enabled and complete.
         */
        private function answer(e:MouseEvent):void
        {
            if (model.inTrial) {
                var down:Boolean = keyMouse.pressed("MOUSE");
                if (down) {
                    var x:Number = e.currentTarget.mouseX;
                    var y:Number = e.currentTarget.mouseY;
                    var dot:DotClip = view.newDotAt(x, y);
                    if (null == dot) {
                        view.drawProgress(model.to, x, y);
                    }
                    else {
                        if (model.lines) {
                            model.lines = false;
                            view.clearLines();
                        }
                        var index:int = model.answer(dot.x, dot.y);
                        var correct:Boolean = 0 <= index;
                        view.drawConnection(model.from, model.to, correct);
                        if (correct) {
                            Sounds.instance.next();
                            if (model.complete)
                            {
                                win();
                            }
                        }
                        else {
                            Sounds.instance.wrong();
                            lose();
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
