function midiPlayer() {
  try {
	return document.midiplayer;
  }
  catch (e) {

  }
}

function loadMidi(url) {
  try {
	addPlayer();
	setTimeout(function() {
		midiPlayer().SetURL(url);
		midiPlayer().SetControllerVisible(false);
	}, 300);
  }
  catch (e) {

  }
}

function midiStop() {
  try {
    midiPlayer().Stop();
    document.getElementById('midiPlayerContainer').innerHTML = "";
  }
  catch (e) {

  }
}

function midiPlay(url) {
  try {
    loadMidi(url);
    midiPlayer().Play();
    midiPlayer().SetIsLooping(false);
  }
  catch (e) {

  }
}

function midiLoop(url, loopCount) {
  try {
	// Todo: Actually make this respect the loopCount.
    loadMidi(url);
    midiPlayer().Play();
    midiPlayer().SetIsLooping(true);
  }
  catch (e) {

  }
}

function addPlayer() {
	code = '<object id="midiplayer"' +  
    		'classid="clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B"' +  
    		'codebase="http://www.apple.com/qtactivex/qtplugin.cab"' +  
    		'width="10" height="10">' +  
    		'<param name="src" value="" />' +  
    		'<param name="controller" value="false" />' +  
    		'<param name="autoplay" value="true" />' +  
    		'<!--[if !IE]>-->' +  
    		'<EMBED name="midiplayer"' +  
        		'height="260"' +  
        		'width="320"' +  
        		'src=""' +  
        		'type="video/quicktime"' +  
        		'pluginspage="www.apple.com/quicktime/download"' +  
        		'controller="false"' +  
        		'autoplay="true"' +  
    		'/>' +  
    		'<!--<![endif]-->' +  
			'</object>';
	document.getElementById('midiPlayerContainer').innerHTML = code;
}

addPlayer();
