package;

import flash.events.TimerEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import openfl.display.Sprite;
import openfl.Lib;

/**
 * ...
 * @author Andy Woods
 */
class Main extends Sprite 
{

	private var script:String;
	
	public function new() 
	{
		super();
		delay(100, tests); //wait for system to cool down
	}
	
	function tests() {
		
		var times:Int = 5;
		
		Output.write('','Instance created each time.');
		script = "var sum = 0; for( a in angles ) sum += Math.cos(a);  sum; ";
		run_x_times(times, function() { howMany_in_1ms(run); } );
		run_x_times(times, function() { duration(run); } );
		
		Output.write('', '');
		Output.write('', 'Instance re-used.');
		HScript_singleton.init();
		HScript_singleton.instance.script = script;
		run_x_times(times, function() { howMany_in_1ms(HScript_singleton.instance.run); } );
		run_x_times(times, function() { duration(HScript_singleton.instance.run); } );
	}
	
	
	
	function howMany_in_1ms(f:Void->Void) 
	{
		var startTime:Float = timeStamp();
		var count:Int = 0;
		var averageOver:Int = 100;
		while (startTime+averageOver > timeStamp()) {
			f();
			count++;
		}
		
		Output.write(script, "how many in 1ms = " + count/averageOver);
	}
	
	private inline function timeStamp():Float {
		return Date.now().getTime();
	}
	
	function duration(f:Void->Void)
	{
		var averageOver:Int = 100;
		var timeNow:Float = timeStamp();
		
		var count:Int = averageOver;
		
		while (count-->0) {
			f();
		}
		
		Output.write(script, "average ms duration = " + Std.string((timeStamp() - timeNow)/averageOver));
	}
	
	function run() 
	{
		var parser = new hscript.Parser();
		var program = parser.parseString(script);
		var interp = new hscript.Interp();
		interp.variables.set("Math",Math); // share the Math class
		interp.variables.set("angles", [0, 1, 2, 3]); // set the angles list
		interp.execute(program);
	}
	
	
	
	function delay(dur:Int, callBack:Void->Void) {
		var t:Timer = new Timer(dur, 0);
		
		function timerL(e:TimerEvent) {
			t.stop();
			t.removeEventListener(TimerEvent.TIMER, timerL);
			callBack();
		}
		
		t.addEventListener(TimerEvent.TIMER, timerL);
		t.start();
	}
	
	function run_x_times(howManyTimes:Int, f:Void->Void) {
		while (howManyTimes-->0) {
			f();
		}
		
	}
	

}

class HScript_singleton {
	public static var instance:HScript_singleton;
	
	public var script:String;
	
	private var parser:Parser;
	private var program:Expr;
	private var interp:Interp;
	
	static public function init() 
	{
		instance = new HScript_singleton();
	}
	
	public function new() {
	
		parser = new hscript.Parser();
		interp = new hscript.Interp();
		
		interp.variables.set("Math",Math); // share the Math class
		interp.variables.set("angles",[0,1,2,3]); // set the angles list
		
	}
	
	public function run() {
		program = parser.parseString(script);
		interp.execute(program);
	}
	
}

class Output extends Sprite{
	
	public static var instance:Output;
	public var tf:TextField;
	
	public static function write(script:String, str:String) {
		if (instance == null) init();
		trace(str);
		if (script == "") instance.tf.text += "\n" + str;
		else instance.tf.text += "\n" + script + '-------> ' + str;
		
		instance.tf.y = instance.stage.stageHeight - instance.tf.height; 
		
	}
	
	public function new() {
		super();
		Lib.current.stage.addChild(this);
		tf = new TextField();
		tf.multiline = true;
		tf.autoSize = TextFieldAutoSize.LEFT;
		addChild(tf);
		
	}
	
	static private function init() 
	{
		instance = new Output();
		
	}
	
	
}
