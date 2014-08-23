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
            view = new View();
            addEventListener(Event.ENTER_FRAME, update, false, 0, true);
            reset();
            // API.connect(root, "", "");
        }

        private function restartTrial(e:MouseEvent):void
        {
            loopChannel.stop();
            reset();
            next();
        }

        public function trial():void
        {
            model.inTrial = true;
            model.populate();
            view.populate(model);
        }

        internal function answer():void
        {
            var correct:Boolean = model.answer();
            if (correct) {
                this.correct.play();
            }
            else {
                this.step.play();
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
            if (model.inTrial) {
                result(updateTrial());
            }
        }

        private function updateTrial():int
        {
            if (keyMouse.pressed("MOUSE")) {
                answer();
            }
            var winning:int = model.update();
            return winning;
        }

        private function result(winning:int):void
        {
            if (!model.inTrial) {
                return;
            }
            if (winning <= -1) {
                lose();
            }
            else if (1 <= winning) {
                win();
            }
        }

        private function win():void
        {
            reset();
            // FlxKongregate.api.stats.submit("Score", Model.score);
            // API.postScore("Score", Model.score);
        }

        private function reset():void
        {
            model.inTrial = false;
            if (null != loopChannel) {
                // loopChannel.stop();
            }
        }

        private function lose():void
        {
            reset();
            // FlxKongregate.api.stats.submit("Score", Model.score);
            // API.postScore("Score", Model.score);
            // mouseChildren = false;
        }

        public function next():void
        {
            restart();
        }

        public function restart():void
        {
            if (model) {
                model.clear();
            }
            if (view) {
                view.clear();
            }
        }
    }
}
