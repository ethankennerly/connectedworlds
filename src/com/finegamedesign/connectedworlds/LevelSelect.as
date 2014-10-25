package com.finegamedesign.connectedworlds
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;

    public class LevelSelect extends Sprite
    {
        internal static var milestoneCount:int;
        internal static var milestoneMax:int;
        /**
         * @param   level:int
         */
        internal static var onSelect:Function;

        /**
         * Level buttons, horizontally centered, vertical from top.
         * LevelTile:
         *      txt
         *      btn
         * If above milestoneMax, transparent and no button response.
         */
        public function LevelSelect() 
        {
            super();
            for (var c:int = numChildren - 1; 0 <= c; c--) {
                removeChildAt(c);
            }
            var columnCount:int = 2;
            var columnWidth:int = 100;
            for (var i:int = 0; i < milestoneCount; i++) {
                var tile:LevelTile = new LevelTile();
                tile.x = columnWidth * ((i % columnCount) - ((columnCount - 1) / 2));
                tile.y = columnWidth * int(i / columnCount);
                var level:int = i + 1;
                tile.txt.text = level.toString();
                tile.txt.mouseEnabled = false;
                tile.name = "_" + level.toString();
                if (i < milestoneMax) {
                    tile.btn.addEventListener(MouseEvent.CLICK,
                        selectMilestone, false, 0, true);
                }
                else {
                    tile.btn.mouseEnabled = false;
                    tile.alpha = 0.25;
                }
                addChild(tile);
            }
        }

        private function selectMilestone(event:MouseEvent):void
        {
            var milestone:int = parseInt(event.currentTarget.parent.name.split("_")[1]);
            trace("LevelSelect.selectMilestone: " + milestone.toString());
            onSelect(milestone);
        }
    }
}
