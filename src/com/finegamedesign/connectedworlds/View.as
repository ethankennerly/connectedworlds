package com.finegamedesign.connectedworlds
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    public class View
    {
        internal var model:Model;

        public function View()
        {
        }

        internal function populate(model:Model):void
        {
            this.model = model;
        }

        internal function clear():void
        {
        }
    }
}
