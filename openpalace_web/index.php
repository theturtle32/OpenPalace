<?php include("header.php") ?>

        <div class="article">
          <h1>Source Code now Public</h1>
          <p>
            True to its "open" name, the source code for OpenPalace is now publicly available.  Since I can only tend to OpenPalace in my spare time, I haven't been able to pay much attention to it for the last two months as I've been inundated with paying projects.  I had wanted to move things to a somewhat more completed state, write code comments, and a take a first pass at some documentation before I released the code publicly, but in the interest of getting it out there, I decided to make the initial release as is.  So be warned, it's a little messy!  If you're still interested in taking a look, <a href="source.php">get the source here</a>!
          </p>
        </div>

        <div class="article">
          <h1>What is it?</h1>
          <p>OpenPalace is a free, open source client application for The Palace, a 2d graphical avatar chat platform.  It is available as a desktop application built on the Adobe Air platform, and also as a browser-based version, meant to replace the aging InstantPalace client.  The project is still under heavy development, and I have only my spare time to work with, so your patience while I prepare the first public release is appreciated.  Until then, you're welcome to try out the web-based version.  Because of security restrictions in the flash player, it will only connect to my test palace at openpalace.org:9998. For more information about The Palace, visit <a href="http://www.thepalace.com/">thepalace.com</a>.</p>
        </div>
        <div class="tryItNow">
          <a href="/demo">Try it now!</a>
          <p style="text-align:center;">
            Current Version: 0.956<br/>
            <a href="changelog.php">Changelog</a><br/>
            <a href="/trac/newticket">Report a Bug</a>
          </p>
        </div>
        <div class="article">
          <h1>Current Features</h1>
          <ul class="bulleted">
            <li>Background Image Formats: GIF, JPEG, PNG, and SWF.</li>
            <li>Avatar Formats: 8bit, 16bit, 20bit, s20bit, and 32bit</li>
            <li>Loose Props</li>
            <li>Working door hotspots.</li>
            <li>Hotspots with Images.</li>
            <li>Chat &amp; Whispers.</li>
            <li>Working Log Window, User List, and Room List.</li>
          </ul>
        </div>
        <div class="article">
          <h1>Planned Features</h1>
          <ul class="bulleted">
            <li>Iptscrae.</li>
            <li>Sounds.</li>
            <li>Lockable Doors</li>
            <li>Avatar (Prop) Bag.</li>
            <li>User Interface Overhaul (the current UI is just enough to test the features.)</li>
            <li>Caching avatar images between sessions.</li>
          </ul>
        </div>
        <div class="article">
          <h1>Known Issues</h1>
          <ul class="bulleted">
            <li>Chat bubbles are extremely static and need serious improvements to be usable.</li>
            <li>Whispers and Room Messages only appear in the log window.</li>
            <li>Quirky behavior when clicking on other avatars for whispering.</li>
            <li>Entering a highly populated room in certain palaces causes the connection to be dropped.</li>
            <li>Layer ordering isn't quite right, often avatars prevent you from clicking on doors underneath.</li>
          </ul>
        </div>
        <div class="article">
          <h1>Acknowledgements</h1>
          <p>Special thanks to Chris and Martyn of the <a href="http://www.bhlabs.com">Phalanx</a> team for all their support, and for providing code snippets for decoding the new avatar formats.</p>
        </div>

<?php include("footer.php") ?>