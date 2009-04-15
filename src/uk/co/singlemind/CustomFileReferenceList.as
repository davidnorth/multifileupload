package uk.co.singlemind
{
	import flash.events.*;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;

	public class CustomFileReferenceList extends FileReferenceList
	{

		public var uploadURL:URLRequest;
	    public var _pendingFiles:Array;
	    public var currentFileIndex:uint;
	    public var filesComplete:uint = 0;
		public var bytesTotal:uint;	    
		public var bytesLoaded:uint;
		
		public function CustomFileReferenceList()
		{
			bytesTotal = 0;
			_pendingFiles = [];
	        initializeListListeners();
		}
		
		public function upload():void
		{
			pendingFiles[currentFileIndex].fileReference.upload(uploadURL);
		}

		public function removeItems(indeces:Array):void
		{
			indeces.forEach(function(index){
				pendingFiles.removeItemAt(index);
				fileList.removeItemAt(index);
			});

            bytesTotal = _pendingFiles.sum('size');
			dispatchEvent(new Event('select'));
			dispatchEvent(new Event('filesChanged'));
		}

		[Bindable(event="filesChanged")]
		public function get pendingFiles():Array
		{
			return _pendingFiles;	
		}
		public function set pendingFiles(newFiles:Array):void
		{
			_pendingFiles = newFiles;
		}
		


	    private function initializeListListeners():void 
	    {
	        addEventListener(Event.SELECT, selectHandler);
	        addEventListener(Event.CANCEL, cancelHandler);
	    }
	    
	    private function doOnComplete():void
	    {
	    	trace('Completed');
	    }
    
	    private function createPendingFileUpload(file:FileReference)
	    {
	        file.addEventListener(Event.OPEN, openHandler);
	        file.addEventListener(Event.COMPLETE, completeHandler);
	        file.addEventListener(ProgressEvent.PROGRESS, progressHandler);
	        file.addEventListener(IOErrorEvent.IO_ERROR, uploadErrorHandler);
	        file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, uploadErrorHandler);
			return new PendingFileUpload(file)
	    }

	    private function selectHandler(event:Event):void
	    {
	    	currentFileIndex = 0;
			for(var i:uint = 0;i < fileList.length; i++){
				_pendingFiles.push(  createPendingFileUpload(fileList[i])  );
			}
			bytesTotal = _pendingFiles.sum('size');
			dispatchEvent(new Event('filesChanged'));
	    }
	 
	    private function cancelHandler(event:Event):void {
	    }
	 
	    private function openHandler(event:Event):void {
//	        var file:FileReference = FileReference(event.target);
			dispatchEvent(new Event('filesChanged'));
	    }
	 
	    private function progressHandler(event:ProgressEvent):void {

            bytesLoaded = _pendingFiles.sum('bytesLoaded');
			dispatchEvent(new Event('filesChanged'));
			dispatchEvent(new Event('progress'));
			
			// Don't wait for complete event to start another upload
			if(event.bytesLoaded == event.bytesTotal ){
                startNextUploadIfPossible();
			}
			
	    }
	    
	    private function startNextUploadIfPossible():void {
          currentFileIndex ++;
          if(currentFileIndex < pendingFiles.length){
            upload();
          }
          //	    	
	    }
	 
	    private function completeHandler(event:Event):void {
            filesComplete ++;
            if(filesComplete == _pendingFiles.length){
                complete();
            }
			bytesLoaded = _pendingFiles.sum('bytesLoaded');
			dispatchEvent(new Event('filesChanged'));
            dispatchEvent(new Event('progress'));

            startNextUploadIfPossible();
            
	    }
	 
		private function complete():void
		{
			bytesLoaded = bytesTotal;
			dispatchEvent(new Event('completed'));
		}
		
	    private function uploadErrorHandler(event:Event):void {
	        var file:FileReference = FileReference(event.target);
	    	Alert.show('Upload failed: ' + file.name);
	    }
	    
	    public function get percentageComplete():uint {
			return Math.round( 100 / (bytesTotal / bytesLoaded) ) ;
	    }


	}
}