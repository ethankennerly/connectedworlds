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
            // trial();
            // API.connect(root, "", "");
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
        }

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
        }

        private function win():void
        {
            model.levelUp();
            reset();
            // FlxKongregate.api.stats.submit("Score", Model.score);
            // API.postScore("Score", Model.score);
        }

        private function reset():void
        {
            trace("Main.reset");
            model.inTrial = false;
            if (null != loopChannel) {
                // loopChannel.stop();
            }
            view.cancel();
            view.screen.play();
        }

        private function lose():void
        {
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

        // **

        private function answerFirst(e:MouseEvent):void
        {
            if (model.only) {
                trace("Main.answerFirst");
                answer(e, true);
            }
        }

        private function answer(e:MouseEvent, down:Boolean=false):void
        {
            if (model.inTrial) {
                down = down || keyMouse.pressed("MOUSE");
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
                        var correct:int = model.answer(dot.x, dot.y);
                        view.drawConnection(model.from, model.to);
                        if (0 <= correct) {
                            if (model.complete)
                            {
                                win();
                            }
                        }
                        else {
                            lose();
                        }
                    }
                }
                else {
                    model.cancel();
                    view.cancel();
                }
            }
        }
    }
}
