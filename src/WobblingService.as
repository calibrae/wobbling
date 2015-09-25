/**
 * Created by IntelliJ IDEA.
 * User: cali
 * Bitbucket: https://bitbucket.org/calibrae
 * Date: 22/09/15
 * Time: 12:22
 */
package {
	import flash.utils.Dictionary;

	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.filters.WarpFilter;

	public class WobblingService implements IAnimatable {

		public function WobblingService(){
			init();
		}
		public function add(disp : DisplayObject) : void {

			if (disp.stage) {
				_dispAddedToStage(null, disp);

			} else {
				disp.addEventListener(Event.ADDED_TO_STAGE, _dispAddedToStage);
			}

		}

		public function advanceTime(time : Number) : void {
			var i : uint = 0, len : uint = _tweeners.length;
			for (i; i < len; i++) {
				_tweeners[i].advanceTime(time);
			}
		}

		public function remove(disp : DisplayObject) : void {
			var tweener : WarpFilterTweener = _cache[disp];
			if (!tweener) {
//				dev("no tweener for this display object");
				return;
			}
			_pool.push(_tweeners.splice(_tweeners.indexOf(tweener), 1)[0]);
			delete _cache[disp];
			tweener.tearDown();

			if (_tweeners.length == 0) {
				Starling.juggler.remove(this);
			}

		}

		[PostConstruct]
		public function init() : void {
			trace("init");

			ls = new Dictionary();
			rs = new Dictionary();

			var i : Number = 0, len : Number = 2 * Math.PI;
			for (i; i < len; i += step) {
				ls[i] = pipart * Math.sin(i) + pipart / 2;
			}
			i = 0;
			for (i; i < len; i += step) {
				rs[i] = 1 - (pipart * Math.sin(i) + pipart / 2);
			}

		}

		[PreDestroy]
		public function tearDown() : void {
		}

		private function _dispAddedToStage(event : Event = null, disp : DisplayObject = null) : void {
			disp = disp ? disp :  event.target as DisplayObject;
			disp.removeEventListener(Event.ADDED_TO_STAGE, _dispAddedToStage);

			_tweeners ||= new <WarpFilterTweener>[];

			var filter : WarpFilter = new WarpFilter();
			disp.filter = filter;
			var tweener : WarpFilterTweener = tweenerInst;
			tweener.init(filter);

			_tweeners.push(tweener);
			_cache[disp] = tweener;

			if (_tweeners.length == 1) {
				Starling.juggler.add(this);
			}
		}

		private var rs : Dictionary;
		private var ls : Dictionary;
		private var _cache : Dictionary = new Dictionary(true);
		private var _tweeners : Vector.<WarpFilterTweener>;
		private var _pool : Vector.<WarpFilterTweener> = new <WarpFilterTweener>[];

		private function get tweenerInst() : WarpFilterTweener {
			if (_pool.length > 0) {
				return _pool.pop();
			}
			var tweener : WarpFilterTweener = new WarpFilterTweener();
			tweener.ls = ls;
			tweener.rs = rs;
			return tweener;
		}

		private const pipart : Number = 1 / 8;
		private const step : Number = Math.PI / 32;
	}
}

import flash.utils.Dictionary;

import starling.animation.IAnimatable;
import starling.events.EventDispatcher;
import starling.filters.WarpFilter;

internal class WarpFilterTweener extends EventDispatcher implements IAnimatable {
	private var l1 : Number;
	private var l2 : Number;
	private var l3 : Number;
	private var l4 : Number;
	private var r1 : Number;
	private var r2 : Number;
	private var r3 : Number;
	private var r4 : Number;
	private var _filter : WarpFilter;
	public var ls : Dictionary;
	public var rs : Dictionary;

	public function init(filter : WarpFilter) : void {
		l1 = random;
		l2 = random;
		l3 = random;
		l4 = random;
		r1 = random;
		r2 = random;
		r3 = random;
		r4 = random;
		_filter = filter;

	}

	public function toString() : String {
		return "l1:" + _filter.l1 + ", l2:" + _filter.l2 + ", l3:" + _filter.l3 + ", l4:" + _filter.l4 + ", r1:" + _filter.r1 + ", r2:" + _filter.r2 + ", r3:" + _filter.r3 + ", r4:" + _filter.r4;
	}

	public function tearDown() : void {
		_filter.dispose();
		_filter = null;

	}

	private function get random() : Number {
		return pis[Math.floor(Math.random() * pis.length)];
	}

	private const pis : Vector.<Number> = new <Number>[0, Math.PI / 4, Math.PI / 2
		, 3 * Math.PI / 4, Math.PI, 5 * Math.PI / 4, 3 * Math.PI / 2, 7 * Math.PI / 4];

	public function advanceTime(time : Number) : void {
		_filter.l1 = ls[l1];
		_filter.l2 = ls[l2];
		_filter.l3 = ls[l3];
		_filter.l4 = ls[l4];
		_filter.r1 = rs[r1];
		_filter.r2 = rs[r2];
		_filter.r3 = rs[r3];
		_filter.r4 = rs[r4];

		l1 = l1 + step >= 2 * Math.PI ? 0 : l1 + step;
		l2 = l2 + step >= 2 * Math.PI ? 0 : l2 + step;
		l3 = l3 + step >= 2 * Math.PI ? 0 : l3 + step;
		l4 = l4 + step >= 2 * Math.PI ? 0 : l4 + step;
		r1 = r1 + step >= 2 * Math.PI ? 0 : r1 + step;
		r2 = r2 + step >= 2 * Math.PI ? 0 : r2 + step;
		r3 = r3 + step >= 2 * Math.PI ? 0 : r3 + step;
		r4 = r4 + step >= 2 * Math.PI ? 0 : r4 + step;
	}

	private const step : Number = Math.PI / 32;
}