package uk.co.singlemind
{
	import flash.events.*;
	import flash.net.FileReference;

	public class PendingFileUpload extends EventDispatcher
	{
		public var fileReference:FileReference;
		public var bytesLoaded:uint = 0;
		public var complete:Boolean = false;
						
		public function PendingFileUpload(fr:FileReference)
		{
			fileReference = fr;

            fr.addEventListener(Event.OPEN, openHandler);
            fr.addEventListener(Event.COMPLETE, completeHandler);
            fr.addEventListener(ProgressEvent.PROGRESS, progressHandler);

		}
		
		
	
        private function openHandler(event:Event):void {
        }
     
        private function progressHandler(event:ProgressEvent):void {
            bytesLoaded = event.bytesLoaded;
            dispatchEvent(new Event('progressChanged'));
        }
     
        private function completeHandler(event:Event):void {
        	complete = true;
            dispatchEvent(new Event('progressChanged'));
        }		
		
		
		
		
        public function get size():uint
        {
            return fileReference.size;
        }       
		

		public function get name():String
		{
			return fileReference.name;
		}		
		
		public function get formattedSize():String
		{
			return Math.round(fileReference.size / 1024) + " kb";
		}
		
		[Bindable(event="progressChanged")]
		public function get percentageDone():String
		{
			return Math.round( 100 / (fileReference.size / bytesLoaded) ) + "%";
		}
		
		[Bindable(event="progressChanged")]
		public function get status():String
		{
			if(complete){
				return 'Complete'
			}
			if(bytesLoaded == 0){
				return 'Queued';
			}
			if(bytesLoaded == fileReference.size){
				return 'Saving...';
			}
			return percentageDone;
		}		
		
		
		
	}




}