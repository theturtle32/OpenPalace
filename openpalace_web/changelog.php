<?php include("header.php") ?>

        <div class="article">
          <h1>ChangeLog</h1>
          <h2>Version 0.956 (2009-03-05, r65)</h2>
          <ul class="bulleted">
            <li>Overhauled the UI for the web client.</li>
          </ul>
          <h2>Version 0.955 (2009-03-04, r63)</h2>
          <ul class="bulleted">
            <li>Fixed a bug relating to the clickable area of avatars.</li>
          </ul>
          <h2>Version 0.954 (2009-03-04, r60)</h2>
          <ul class="bulleted">
            <li>Fixed log window bug where the last line of the chat was sometimes being cut off.</li>
          </ul>
          
          <h2>Version 0.953 (2009-03-04, r55)</h2>
          <ul class="bulleted">
            <li>Added a loaderContext to the images so that cross domain image loading for images with a transparency color specified doesn't fail.</li>
          </ul>
          
          <h2>Version 0.952 (2009-03-02, r50)</h2>
          <ul class="bulleted">
            <li>Improved timings of prop requests to the server to improve prop download responsiveness and also to prevent you from getting killed for flooding in a highly populated room with lots of props.</li>
            <li>Armored the manual transparency color function for hotspot images against corrupt images.</li>
            <li>Made a substantial speed optimization for rendering rooms with lots of loose props.</li>
          </ul>
          
          <h2>Version 0.951 (2009-03-01, r46)</h2>
          <ul class="bulleted">
            <li>Made door outlines show on mouseover.</li>
          </ul>
          
          <h2>Version 0.95 (2009-03-01, r44)</h2>
          <ul class="bulleted">
            <li>Started keeping a changelog!</li>
            <li>Implemented hotspot image support, including manual transparency manipulation in addition to inherently transparent image formats</li>
            <li>Added preliminary support for locked doors, though this is still not quite right and I'm not sure I understand how it works yet.</li>
          </ul>
          
        </div>
        
<?php include("footer.php") ?>