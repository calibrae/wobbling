package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;

	[SWF(frameRate="60", backgroundColor="#000000")]
	public class WobblingMain extends Sprite {
		[Embed(source="Po_N1_A_7.png")]
		public static const fishClass : Class;

		public static var DisplaySize : Point;

		public function WobblingMain() {
			addEventListener(flash.events.Event.ADDED_TO_STAGE, _preinit);
		}


		private function _preinit(event : flash.events.Event) : void {
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, _preinit);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			_count = 0;
			addEventListener(flash.events.Event.ENTER_FRAME, _enterFrame);
		}

		private function _enterFrame(event : flash.events.Event) : void {

			if (_count < 3) {
				_count++;
				return;
			}
			removeEventListener(flash.events.Event.ENTER_FRAME, _enterFrame);

			DisplaySize = new Point(stage.stageWidth, stage.stageHeight);
			_starling = new Starling(WobblingGame, stage);
			_starling.addEventListener(Event.ROOT_CREATED, _rootCreated);
			_starling.start();
		}

		private function _rootCreated(event : Event) : void {
			var texture : Texture = Texture.fromBitmap(new fishClass, false, true, 5);

			var i : uint = 0, len : uint = 50;
			for (i; i < len; i++) {
				var image : Image = new Image(texture);
				image.x = Math.random() * stage.stageWidth;
				image.y = Math.random() * stage.stageHeight;
				(_starling.root as starling.display.Sprite).addChild(image);
				_images.push(image);

			}
			stage.addEventListener(MouseEvent.CLICK, _click);
		}

		private function _click(event : MouseEvent) : void {
			trace("click");
			var service : WobblingService = new WobblingService;
			var i : uint = 0, len : uint = _images.length;
			for (i; i < len; i++) {
				service.add(_images[i]);
			}
		}

		private var _count : int;
		private var _starling : Starling;
		private var _images : Vector.<Image> = new <Image>[];
	}
}
