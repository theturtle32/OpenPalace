package net.codecomposer.palace.view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.controls.Image;
	import mx.events.DragEvent;
	
	/*
		Code adapted from Moses Supposes InteractivePNG example
		http://blog.mosessupposes.com/?p=40
	*/
	
	public class AlphaHitAreaImage extends Image
	{
		
		// -== Public Properties ==-
		
		/**
		 * Whether this MovieClip is using InteractivePNG functionality.
		 * 
		 * <p>Functionality is enabled by default from instantiation. Only returns 
		 * false if disableInteractivePNG() has been called. (Note that setting 
		 * <code>hitArea</code> or <code>mouseEnabled</code> may result in a disable 
		 * in certain cases, see documentation in the class file for more information 
		 * on this topic.)</p> 
		 * 
		 * @return	False if disableInteractivePNG() has been called.
		 * 
		 * @see #disableInteractivePNG
		 * @see #enableInteractivePNG
		 */
		public function get interactivePngActive() : Boolean {
			return _interactivePngActive;
		}
		
		/**
		 * Set to 0 to detect hit on any pixel that is not completely transparent, or 255 
		 * detect only completely opaque pixels.
		 * 
		 * @default	128
		 * @return	An alpha threshold between 0 and 255.
		 */
		public function get alphaTolerance() : uint {
			return _threshold;
		}
		public function set alphaTolerance(value : uint) : void {
			_threshold = Math.min(255, value);
		}
		
		// Excluded from documentation for simplicity, a note is provided under disableInteractivePNG.
		/**
		 * @private
		 * Using a <code>hitArea</code> disables the functionality of this class, which cannot
		 * be reenabled until the <code>hitArea</code> is removed.
		 * 
		 * @see #interactivePngActive
		 * @see #enableInteractivePNG
		 * @see #disableInteractivePNG
		 */
		override public function set hitArea(value : Sprite) : void {
			if (value!=null && super.hitArea==null) {
				disableInteractivePNG();
			}
			else if (value==null && super.hitArea!=null) {
				enableInteractivePNG();
			}
			super.hitArea = value;
		}
		
		// Excluded from documentation for simplicity, a note is provided under disableInteractivePNG.
		/**
		 * @private
		 * This class uses <code>mouseEnabled</code> actively, so avoid setting it if possible;
		 * setting it will disable InteractivePNG functionality if the mouse is within clip bounds.
		 * If this happens, you must then call enableInteractivePNG() to restart functionality.
		 * 
		 * @see #interactivePngActive
		 * @see #enableInteractivePNG
		 * @see #disableInteractivePNG
		 */
		override public function set mouseEnabled(enabled : Boolean) : void {
			if (isNaN(_buttonModeCache)==false) { // indicates that mouse has entered clip bounds.
				disableInteractivePNG();
			}
			super.mouseEnabled = enabled;
		}
		
		// -== Private Properties ==-
		
		/**
		 * @private
		 */
		protected var _threshold : uint = 128;
		/**
		 * @private
		 */
		protected var _transparentMode : Boolean = false;
		/**
		 * @private
		 */
		protected var _interactivePngActive : Boolean = false;
		/**
		 * @private
		 */
		protected var _bitmapHit : Boolean = false;
		/**
		 * @private
		 */
		protected var _basePoint : Point;
		/**
		 * @private
		 */
		protected var _mousePoint : Point;
		/**
		 * @private
		 */
		protected var _bitmapForHitDetection : Bitmap;
		/**
		 * @private
		 */
		protected var _buttonModeCache : Number = NaN;
		
		// -== Public Methods ==-
		
		/**
		 * InteractivePNG functionality is active from instantiation, but can
		 * be turned off at any time by calling disableInteractivePNG().
		 */
		public function AlphaHitAreaImage() {
			super();
			_basePoint = new Point();
			_mousePoint = new Point();
			//this.loaderInfo.addEventListener(Event.COMPLETE, drawBitmapHitArea); 
			enableInteractivePNG();
		}
		
		/**
		 * A hit-detection bitmap is generated on the first mouse interaction with the clip,
		 * but you may need to call this method or use it as an ENTER_FRAME handler to refresh
		 * the hit area if the clip's shape changes during play.
		 * 
		 * @param event		Provided so this method can be used as an event handler with no extra work.
		 */
		public function drawBitmapHitArea(event:Event=null) : void 
		{
			var isRedraw:Boolean = (_bitmapForHitDetection!=null);
			if (isRedraw) {
				try { removeChild(_bitmapForHitDetection); }catch(e:Error) { }
			}
			var bounds:Rectangle = getBounds(this);
			var left:Number = bounds.left;
			var top:Number = bounds.top;
			var b:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0);
			_bitmapForHitDetection = new Bitmap(b);
			_bitmapForHitDetection.name = "interactivePngHitMap"; // (So that it is not a mystery if the displaylist is being inspected!)
			_bitmapForHitDetection.visible = false;
			var mx:Matrix = new Matrix();
			mx.translate(-left, -top);
			b.draw(this, mx);
			addChildAt(_bitmapForHitDetection, 0);
			_bitmapForHitDetection.x = left;
			_bitmapForHitDetection.y = top;
		}
		
		/**
		 * Turns off the functionality of this class. Note that setting 
		 * <code>hitArea</code> or <code>mouseEnabled</code> may result in 
		 * a disable in certain cases (see documentation in the class file 
		 * for more information on this topic).
		 * 
		 * @see #interactivePngActive
		 * @see #enableInteractivePNG
		 */
		public function disableInteractivePNG(): void {
			deactivateMouseTrap();
			removeEventListener(Event.ENTER_FRAME, trackMouseWhileInBounds);
			try { removeChild(_bitmapForHitDetection); }catch(e:Error) { }
			_bitmapForHitDetection = null;
			super.mouseEnabled = true;
			_transparentMode = false;
			setButtonModeCache(true);
			_bitmapHit = false;
			_interactivePngActive = false;
		}
		
		/**
		 * Restores functionality of this class if it was previously disabled.
		 * This method will have no effect if <code>hitArea</code> has been set.
		 * 
		 * @see #interactivePngActive
		 * @see #disableInteractivePNG
		 */
		public function enableInteractivePNG(): void {
			disableInteractivePNG();
			if (hitArea!=null)
				return;
			activateMouseTrap();
			_interactivePngActive = true;
		}
		
		// -== Private Methods ==-
		
		/**
		 * @private
		 * Listens for hit to edges of this MovieClip, which then turns on bitmap hit tracking.
		 */
		protected function activateMouseTrap() : void {
			addEventListener(MouseEvent.ROLL_OVER, captureMouseEvent, false, 10000, true); //useCapture=true, priority=high, weakRef=true
			addEventListener(MouseEvent.MOUSE_OVER, captureMouseEvent, false, 10000, true);
			addEventListener(MouseEvent.ROLL_OUT, captureMouseEvent, false, 10000, true);  
			addEventListener(MouseEvent.MOUSE_OUT, captureMouseEvent, false, 10000, true);
			addEventListener(MouseEvent.MOUSE_MOVE, captureMouseEvent, false, 10000, true);
		}
		
		/**
		 * @private
		 * Turns off listening for mouse events on this MovieClip.
		 */
		protected function deactivateMouseTrap() : void {
			removeEventListener(MouseEvent.ROLL_OVER, captureMouseEvent);
			removeEventListener(MouseEvent.MOUSE_OVER, captureMouseEvent);
			removeEventListener(MouseEvent.ROLL_OUT, captureMouseEvent);  
			removeEventListener(MouseEvent.MOUSE_OUT, captureMouseEvent);
			removeEventListener(MouseEvent.MOUSE_MOVE, captureMouseEvent);
		}
		
		/**
		 * @private
		 * Captures and suppresses MouseEvents as the mouse enters this MovieClip's bounds.
		 * Mouse is then tracked onEnterFrame by trackMouseWhileInBounds() until it leaves 
		 * clip bounds again. If the mouse hits a pixel this method is unsubscribed until
		 * it falls off the bitmap again, otherwise it is left on to suppress all events.
		 * 
		 * @param event		Any event subscribed in activateBitmapHitDetection().
		 */
		protected function captureMouseEvent(event : Event) : void 
		{
			if (!_transparentMode) {
				if (event.type==MouseEvent.MOUSE_OVER || event.type==MouseEvent.ROLL_OVER) {
					// The buttonMode state is cached then disabled to avoid a cursor flicker 
					// at the movieclip bounds. Reenabled when bitmap is hit.
					setButtonModeCache();
					_transparentMode = true;
					super.mouseEnabled = false;
					addEventListener(Event.ENTER_FRAME, trackMouseWhileInBounds, false, 10000, true); // activates bitmap hit & exit tracking
					trackMouseWhileInBounds(); // important: Immediate response, and sets _bitmapHit to correct state for event suppression.
				}
			}
			
			if (!_bitmapHit)
				event.stopImmediatePropagation();
		}
		
		/**
		 * @private
		 * Actively track the mouse for bitmap hit or exit of MovieClip bounds.
		 * @param event		This method is called on ENTER_FRAME when mouse is in bounds and mouseEnabled is turned off.
		 */
		protected function trackMouseWhileInBounds(event:Event=null):void 
		{
			if (bitmapHitTest() != _bitmapHit) 
			{
				_bitmapHit = !_bitmapHit;
				
				// Mouse is now on a nonclear pixel based on alphaTolerance. Reenable mouse events.
				if (_bitmapHit) {
					deactivateMouseTrap();
					setButtonModeCache(true, true);
					_transparentMode = false;
					super.mouseEnabled = true; // This will trigger rollOver & mouseOver events
				}
					
					// Mouse is now on a clear pixel based on alphaTolerance. Disable mouse events but .
				else if (!_bitmapHit) {
					_transparentMode = true;
					super.mouseEnabled = false; // This will trigger rollOut & mouseOut events
				}
			}
			
			// When mouse exits this MovieClip's bounds, end tracking & restore all.
			var localMouse:Point = _bitmapForHitDetection.localToGlobal(_mousePoint);
			if (hitTestPoint( localMouse.x, localMouse.y)==false) {
				removeEventListener(Event.ENTER_FRAME, trackMouseWhileInBounds);
				_transparentMode = false;
				setButtonModeCache(true);
				super.mouseEnabled = true;
				activateMouseTrap();
			}
		}
		
		/**
		 * @private
		 * @return	Whether the mouse touches a pixel with an alpha value greater than the 
		 * 			<code>alphaTolerance</code> setting.
		 */
		protected function bitmapHitTest():Boolean {
			if (_bitmapForHitDetection==null)
				drawBitmapHitArea();
			_mousePoint.x = _bitmapForHitDetection.mouseX;
			_mousePoint.y = _bitmapForHitDetection.mouseY;
			return _bitmapForHitDetection.bitmapData.hitTest(_basePoint, _threshold, _mousePoint);
		}
		
		/**
		 * @private
		 * Helper for avoiding cursor flicker at clip bounds.
		 * @param restore	Default false caches buttonMode state, true restores state from cache.
		 * @param retain	If flagged do not clear the cache during restore.
		 */
		protected function setButtonModeCache(restore:Boolean=false, retain:Boolean=false) : void {
			if (restore) {
				if (_buttonModeCache==1)
					buttonMode = true;
				if (!retain)
					_buttonModeCache = NaN;
				return;
			}
			_buttonModeCache = (buttonMode==true ? 1 : 0);
			buttonMode = false;
		}

	}
}