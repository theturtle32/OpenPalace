function midiPlayer() {
	return document.midiplayer;
}

function loadMidi(url) {
	addPlayer();
	setTimeout(function() {
		midiPlayer().SetURL(url);
		midiPlayer().SetControllerVisible(false);
	}, 300);
}

function midiStop() {
    midiPlayer().Stop();
    document.getElementById('midiPlayerContainer').innerHTML = "";
}

function midiPlay(url) {
    loadMidi(url);
    midiPlayer().Play();
    midiPlayer().SetIsLooping(false);
}

function midiLoop(url, loopCount) {
	// Todo: Actually make this respect the loopCount.
    loadMidi(url);
    midiPlayer().Play();
    midiPlayer().SetIsLooping(true);
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
