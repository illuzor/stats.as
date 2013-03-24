/**
 * stats.as
 * http://github.com/mrdoob/stats.as
 * 
 * Released under MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * How to use:
 * 
 *	addChild( new Stats() );
 *
 **/

package net.hires.debug {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	public final class Stats extends Sprite {
		
		private const WIDTH:uint = 70;
		private const HEIGHT:uint = 100;
		
		private var text:TextField;
		private var fps:uint;
		private var ms:uint;
		private var ms_prev:uint;
		private var mem:Number;
		private var graph:Bitmap;
		private var rectangle:Rectangle;
		private var mem_max:Number = 0;
		private var xml:XML = <xml><fps>FPS:</fps><ms>MS:</ms><mem>MEM:</mem><memMax>MAX:</memMax></xml>;;
		private var theme:Object = { bg: 0x000033, fps: 0xffff00, ms: 0x00ff00, mem: 0x00ffff, memmax: 0xff0070 };
		
		/**
		 * <b>Stats</b> FPS, MS and MEM, all in one.
		 */
		
		public function Stats():void{

			var style:StyleSheet = new StyleSheet();
			style.setStyle("xml", {fontSize: '9px', fontFamily: '_sans', leading: '-2px'});
			style.setStyle("fps", {color: hex2css(theme.fps)});
			style.setStyle("ms", {color: hex2css(theme.ms)});
			style.setStyle("mem", {color: hex2css(theme.mem)});
			style.setStyle("memMax", {color: hex2css(theme.memmax)});
			
			text = new TextField();
			text.width = WIDTH;
			text.height = 50;
			text.styleSheet = style;
			text.condenseWhite = true;
			text.selectable = false;
			text.mouseEnabled = false;
			
			graph = new Bitmap();
			graph.y = 50;
			
			rectangle = new Rectangle(WIDTH - 1, 0, 1, HEIGHT - 50);
			
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
		}
		
		private function init(e:Event):void{
			graphics.beginFill(theme.bg);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();
			
			addChild(text);
			
			graph.bitmapData = new BitmapData(WIDTH, HEIGHT - 50, false, theme.bg);
			addChild(graph);
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function destroy(e:Event):void{
			graphics.clear();
			
			while (numChildren > 0)
				removeChildAt(0);
			
			graph.bitmapData.dispose();
			
			removeEventListener(MouseEvent.CLICK, onClick);
			removeEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(e:Event):void{
			var timer:uint = getTimer();
			
			if (timer - 1000 > ms_prev){
				ms_prev = timer;
				mem = Number((System.totalMemory * 0.000000954).toFixed(3));
				mem_max = mem_max > mem ? mem_max : mem;
				
				var fps_graph:uint = Math.min(graph.height, (fps / stage.frameRate) * graph.height);
				var mem_graph:uint = Math.min(graph.height, Math.sqrt(Math.sqrt(mem * 5000))) - 2;
				var mem_max_graph:uint = Math.min(graph.height, Math.sqrt(Math.sqrt(mem_max * 5000))) - 2;
				
				graph.bitmapData.scroll(-1, 0);
				
				graph.bitmapData.fillRect(rectangle, theme.bg);
				graph.bitmapData.setPixel(graph.width - 1, graph.height - fps_graph, theme.fps);
				graph.bitmapData.setPixel(graph.width - 1, graph.height - ((timer - ms) >> 1), theme.ms);
				graph.bitmapData.setPixel(graph.width - 1, graph.height - mem_graph, theme.mem);
				graph.bitmapData.setPixel(graph.width - 1, graph.height - mem_max_graph, theme.memmax);
				
				xml.fps = "FPS: " + fps + " / " + stage.frameRate;
				xml.mem = "MEM: " + mem;
				xml.memMax = "MAX: " + mem_max;
				
				fps = 0;
			}
			
			fps++;
			
			xml.ms = "MS: " + (timer - ms);
			ms = timer;
			
			text.htmlText = xml;
		}
		
		private function onClick(e:MouseEvent):void{
			mouseY / height > .5 ? stage.frameRate-- : stage.frameRate++;
			xml.fps = "FPS: " + fps + " / " + stage.frameRate;
			text.htmlText = xml;
		}
		
		private function hex2css(color:int):String{
			return "#" + color.toString(16);
		}
		
	}
}
