package net.codecomposer.palace.view
{
	import flash.media.SoundTransform;
	
	import mx.core.SoundAsset;

	public class PalaceSoundPlayer
	{
		
		[Embed(source="assets/sounds/amen.mp3")]
		private static const amen:Class;
		
		[Embed(source="assets/sounds/applause.mp3")]
		private static const applause:Class;
		
		[Embed(source="assets/sounds/belch.mp3")]
		private static const belch:Class;
		
		[Embed(source="assets/sounds/boom.mp3")]
		private static const boom:Class;
		
		[Embed(source="assets/sounds/Chime.mp3")]
		private static const chime:Class;
		
		[Embed(source="assets/sounds/crunch.mp3")]
		private static const crunch:Class;
		
		[Embed(source="assets/sounds/debut.mp3")]
		private static const debut:Class;
		
		[Embed(source="assets/sounds/DoorClose.mp3")]
		private static const doorClose:Class;
		
		[Embed(source="assets/sounds/DoorOpen.mp3")]
		private static const doorOpen:Class;
		
		[Embed(source="assets/sounds/Fader.mp3")]
		private static const fader:Class;
		
		[Embed(source="assets/sounds/fazein.mp3")]
		private static const fazein:Class;
		
		[Embed(source="assets/sounds/guffaw.mp3")]
		private static const guffaw:Class;
		
		[Embed(source="assets/sounds/kiss.mp3")]
		private static const kiss:Class;
		
		[Embed(source="assets/sounds/no.mp3")]
		private static const no:Class;
		
		[Embed(source="assets/sounds/pop.mp3")]
		private static const pop:Class;
		
		[Embed(source="assets/sounds/teehee.mp3")]
		private static const teehee:Class;
		
		[Embed(source="assets/sounds/yes.mp3")]
		private static const yes:Class;
		
		private var soundMap:Object = {
			amen: amen,
			applause: applause,
			belch: belch,
			boom: boom,
			chime: chime,
			crunch: crunch,
			debut: debut,
			fazein: fazein,
			guffaw: guffaw,
			kiss: kiss,
			no: no,
			pop: pop,
			teehee: teehee,
			yes: yes
		};
		
		private static var _instance:PalaceSoundPlayer;
		
		public function PalaceSoundPlayer()
		{
			if (_instance != null) {
				throw new Error("You can only create one instance of PalaceSoundPlayer");
			}
		}
		
		
		public static function getInstance():PalaceSoundPlayer {
			if (_instance == null) {
				_instance = new PalaceSoundPlayer();
			}
			return _instance;
		}
		
		public function playDoorLock():void {
			playSoundAsset(SoundAsset(new doorClose()));
		}
		
		public function playDoorUnlock():void {
			playSoundAsset(SoundAsset(new doorOpen()));
		}
		
		public function playConnectionPing():void {
			playSoundAsset(SoundAsset(new fader()));
		}
		
		public function playWhisperBell():void {
			playSoundAsset(SoundAsset(new chime()));
		}
		
		private function playSoundAsset(soundAsset:SoundAsset):void {
				var soundTransform:SoundTransform = new SoundTransform(1,0);
				soundAsset.play(0,0,soundTransform);
		}
		
		public function playSound(soundName:String):void {
			var sound:Class = Class(soundMap[soundName.toLowerCase()]);
			if (sound != null) {
				playSoundAsset(SoundAsset(new sound()));
			}
		}
	}
}