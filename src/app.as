import flash.events.KeyboardEvent;

import mx.controls.Alert;

import uk.co.singlemind.CustomFileReferenceList;

[Bindable]
public var fileRefList:CustomFileReferenceList;

[Bindable]
private var params:Object;

private var defaultParams:Object = {
    upload_url:  "http://localhost:3000/davidnorth/photos/batch",
    session_id:   "3Da60c8ddb95f97ec0d4e104bf03fef5b7",
    authenticity_token: "pluses++endswithequalsign=",
    complete_url:  "http://localhost:3000/davidnorth/photos/batch/090203-155604/edit"
}

public function init():void 
{
	// Load external parameters into params, using defaults for development
	params = mx.core.Application.application.parameters;
	for(var key:String in defaultParams){
		if(params[key] == undefined){
			params[key] = defaultParams[key];
		}
	}
	
	fileRefList = new CustomFileReferenceList();
	
	// Turn url string into uploadURL object
    var uploadURL = new URLRequest();
    
    // Normalize the base url so next query string parameters can be added
    if(params.upload_url.match(/\?/)){
    	params.upload_url = params.upload_url + '&';
    } else {
    	params.upload_url = params.upload_url + '?';
    }
    // Add parameters required by Rails
    params.upload_url = params.upload_url + '_session_id=' + escape(params.session_id) + '&';
    params.upload_url = params.upload_url + 'authenticity_token=' + escape(params.authenticity_token).replace(/\+/g, '%2B');
    
    uploadURL.url = params.upload_url;
	fileRefList.uploadURL = uploadURL;

	fileRefList.addEventListener(Event.SELECT, selectHandler);
	fileRefList.addEventListener('progress', progressHandler);


	fileRefList.addEventListener('completed', completeHandler);
	addEventListener(KeyboardEvent.KEY_DOWN, myKeyDownHandler);
}

public function myKeyDownHandler(event:KeyboardEvent):void
{	
	if(event.keyCode == 8){
		fileRefList.removeItems(fileListDataGrid.selectedIndices);
	}
}

public function browse():void
{
	fileRefList.browse();
}

public function selectHandler(event):void {
	currentState = 'filesSelected';
	var totalFileSize:String = Math.round(fileRefList.bytesTotal / 1024) + " kb";
	uploadProgress.label = 'Selected files: ' + totalFileSize;
	uploadProgress.setProgress(0,100);
}

public function upload():void {
	fileRefList.upload()
	currentState = 'filesUploading';
}

public function progressHandler(event):void {
	trace('app.as progressHandler');
	if(fileRefList.percentageComplete > 99){
        uploadProgress.label = 'Processing files...';
        uploadProgress.indeterminate = true;
	}
	else {
        uploadProgress.label = fileRefList.percentageComplete + '%';
		
	}
	uploadProgress.setProgress(fileRefList.percentageComplete,100);
}

public function completeHandler(event):void {
	trace('app.as completeHandler');
	uploadProgress.label = 'complete';
	uploadProgress.setProgress(100,100);
    currentState = 'uploadsComplete';
}

public function goToCompleteURL():void {
  var request:URLRequest = new URLRequest(params.complete_url);
  try {
    navigateToURL(request, "_self"); // second argument is target
  } catch (e:Error) {
    trace("goToEditURL failed");
  }    	
}
