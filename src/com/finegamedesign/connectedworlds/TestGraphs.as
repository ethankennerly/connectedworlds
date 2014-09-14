package com.finegamedesign.connectedworlds
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Rectangle;

    public class TestGraphs extends Sprite
    {
        public function TestGraphs()
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
            drawGraphThumbnails();
        }

        private function drawGraphThumbnails():void
        {
            var columnCount:int = 10;
            var model:Model = new Model();
            var length:int = model.graphsLength;
            trace("TestGraphs.drawGraphs: length " + length);
            for (var level:int = 0; level < length; level++) {
                trace("TestGraphs.drawGraphs: " + level);
                model = new Model();
                model.level = level;
                model.populate();
                var parent:Sprite = new Sprite();
                var view:View = new View(parent);
                view.populate(model);
                view.backgroundClip.scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
                view.backgroundClip.visible = false;
                view.screen.gotoAndPlay("begin");
                parent.x = (level % columnCount) * stage.stageWidth / columnCount;
                parent.y = int(level / columnCount) * stage.stageHeight / columnCount;
                parent.scaleX = 1 / columnCount;
                parent.scaleY = 1 / columnCount;
                addChild(parent);
            }
        }
    }
}
