package com.finegamedesign.connectedworlds
{
    import flash.utils.ByteArray;

    public class Util
    {
        public static function clone( source:Object ):* 
        { 
            var myBA:ByteArray = new ByteArray(); 
            myBA.writeObject( source ); 
            myBA.position = 0; 
            return( myBA.readObject() ); 
        }
    }
}
