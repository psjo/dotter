using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Cal;
using Toybox.Math as Math;

class dotterView extends Ui.WatchFace {
	var load = true;
	var on = true;
	var batdot = true;
	var analog = true;
	var is24 = true;
	var alwayson = false;
	var colon = 0;
	var timer = 9;
	var countdown = timer;
	var dott = 3, dotd = 1, dotts = 2;
	var w, h, w2, h2;
	/*
	var fg = Gfx.COLOR_BLACK;
	var bg = Gfx.COLOR_WHITE;
	*/
	var fg = Gfx.COLOR_WHITE;
	var bg = Gfx.COLOR_BLACK;
	var size_day_name = 2;
	var size_month = 2;
	var size_day_date = 2;
	var size_hour = 4;
	var size_min = 4;

	// building blocks for numbers and ....
	var block = [ [ 0, 0, 0, 0, 0 ],   // 0
	              [ 1, 1, 1, 1, 1 ],   // 1
	              [ 1, 0, 0, 0, 1 ],   // 2
	              [ 0, 0, 0, 0, 1 ],   // 3
	              [ 0, 0, 0, 1, 0 ],   // 4
	              [ 0, 0, 1, 0, 0 ],   // 5
	              [ 0, 1, 0, 0, 0 ],   // 6
	              [ 1, 0, 0, 0, 0 ],   // 7
	              [ 0, 1, 1, 0, 0 ],   // 8
	              [ 0, 1, 1, 1, 0 ],   // 9
	              [ 1, 1, 1, 1, 0 ],   // 10
	              [ 0, 1, 1, 1, 1 ],   // 11
	              [ 0, 1, 0, 1, 0 ],   // 12
	              [ 1, 0, 1, 0, 1 ],   // 13
	              [ 1, 1, 0, 1, 1 ],   // 14
	              [ 1, 1, 1, 0, 0 ],   // 15
	              [ 1, 1, 0, 0, 1 ],   // 16
	              [ 1, 0, 0, 1, 1 ],   // 17
	              [ 1, 0, 0, 1, 0 ],   // 18
	              [ 1, 0, 1, 0, 0 ] ]; // 19
	// use blocks to make numbers + letters
	var numS =   [ [ 9, 2, 2, 2, 2, 2, 9 ], // 0
	               [ 5, 8, 5, 5, 5, 5, 9 ], // 1
	               [ 9, 2, 3, 4, 5, 6, 1 ], // 2
	               [ 9, 2, 3, 4, 3, 2, 9 ], // 3
	               [ 7, 2, 2, 2, 1, 3, 3 ], // 4
	               [ 1, 7, 10, 3, 3, 2, 9 ], // 5
	               [ 9, 2, 7, 10, 2, 2, 9 ], // 6
	               [ 1, 2, 3, 3, 4, 5, 5 ], // 7
	               [ 9, 2, 2, 9, 2, 2, 9 ], // 8
	               [ 9, 2, 2, 2, 11, 3, 4 ], // 9
	               [ 0, 0, 0, 5, 0, 5, 0 ], // : as 10
	               [ 2, 14, 13, 2, 2, 2, 2 ], // M 11
	               [ 1, 13, 5, 5, 5, 5, 5 ], // T 12
	               [ 2, 2, 2, 2, 13, 14, 2 ], // W 13
	               [ 1, 2, 7, 15, 7, 7, 7 ], // F 14
	               [ 2, 16, 13, 13, 13, 17, 2 ], // N 15
	               [ 1, 2, 7, 15, 7, 2, 1 ], // E 16
	               [ 10, 2, 2, 15, 18, 2, 2 ], // R 17
	               [ 9, 5, 5, 5, 5, 5, 9 ], // I 18
	               [ 2, 2, 2, 1, 2, 2, 2 ], // H 19
	               [ 9, 2, 2, 1, 2, 2, 2 ], // A 20
	               [ 9, 2, 7, 9, 3, 2, 9 ], // S 21
	               [ 15, 18, 2, 2, 2, 18, 15 ], // D 22
	               [ 2, 2, 2, 2, 2, 2, 9 ], // U 23
	               [ 2, 4, 4, 5, 6, 6, 2 ], // % 24
	               [ 3, 3, 3, 3, 3, 2, 9 ], // J 25
	               [ 10, 2, 2, 10, 2, 2, 10 ], // B 26
	               [ 10, 2, 2, 10, 7, 7, 7 ], // P 27
	               [ 7, 7, 7, 7, 7, 2, 1 ], // L 28
	               [ 9, 2, 7, 17, 2, 2, 9 ], // G 29
	               [ 2, 18, 19, 15, 19, 18, 2 ], // K 30
	               [ 2, 2, 12, 12, 12, 5, 5 ], // V 31
	               [ 9, 2, 7, 7, 7, 2, 9 ], // C 32
	               [ 2, 2, 2, 9, 5, 5, 5 ] ]; // Y 33

	function initialize() {
		WatchFace.initialize();
	}

	function onLayout(dc) {
		w = dc.getWidth();
		w2 = w >> 1;
		h = dc.getHeight();
		h2 = h >> 1;
	}

	function onShow() {
	}

	function onUpdate(dc) {
		if (load) {
			load = false;
			getS();
		}
		dc.setColor(fg, bg);
		dc.clear();
		if (on) {
			drawTime(dc, size_hour, size_min);
			if (alwayson || (countdown > 0)) {
				drawDate(dc, size_day_date);
				drawBat(dc, dotd);
				countdown -= 1;
			}
			drawMsg(dc);
		} else if (analog) {
			drawAnalog(dc);
		} else {
			drawTime(dc, dotts, dotts);
		}
	}

	function drawTime(dc, size_h, size_m) {
		dc.setColor(fg, -1);
		if (on && false) {
			for (var i = 0; i < h; i += 4) {
				for (var j = 0; j < w; j += 4) {
					dc.fillCircle( j, i, 1);
				}
			}
		}
		var now = Cal.info(Time.now(), Time.FORMAT_SHORT);
		var hour = now.hour;
		var min = now.min;
		if (!is24 && hour > 12) {
			hour -= 12;
		}
		var hoff = h2 - 30;
		var padx = 9;
		var pady = 11;
		// hour
		drawSNumPad(dc, hour/10, w2 - 94, hoff, padx, pady, size_h);
		drawSNumPad(dc, hour%10, w2 - 44, hoff, padx, pady, size_h);
		//if (colon) {
		//	drawSNumPad(dc, 10, w2 - 18, hoff, padx, pady, size); // :
		//}
		// minutes
		drawSNumPad(dc, min/10, w2 + 8, hoff, padx, pady, size_m);
		drawSNumPad(dc, min%10, w2 + 58, hoff, padx, pady, size_m);
	}

	function drawDate(dc, size) {
		var now = Cal.info(Time.now(), Time.FORMAT_SHORT);
		//date perhaps
		var day = now.day;
		var mon = now.month;
		var y = h2 - 75;
		drawSNum(dc, day/10, w2 - 74, y, 5, size);
		drawSNum(dc, day%10, w2 - 47, y, 5, size);

		drawMonth(dc, size_month, mon);

		day = now.day_of_week;
		drawDay(dc, size_day_name, day);
	}

	/*
	 * TODO: change color when it gets to like twenty percent...
  	 */
	function drawBat(dc, size) {
		var bat = Sys.getSystemStats().battery.toNumber();
		if (bat < 20) {
			dc.setColor(Gfx.COLOR_PINK, -1);
		}

		var rad = 4;
		bat = bat / 5; //20;
		var start = w2 - 59;
		var pad = 6; //25;
		for (var i = 0; i < bat && i < 20; i += 1) {
			//if (batdot) {
			dc.fillCircle(start + i * pad, 1, rad);
			//} else {
			//dc.fillRectangle(start + i * pad, 1, rad); //TODO
			//}
		}
		for (var i = bat; i < 20; i += 1) {
			dc.drawCircle(start + i * pad, 1, rad);
		}
		//} else {
		//	var pad = 0;

		//	if (bat > 99) {
		//		drawSNum(dc, bat/100, w2 - 44, h2 - 100, 4, size);
		//	}
		//	if (bat > 9) {
		//		drawSNum(dc, bat/10%10, w2 - 23, h2 - 100, 4, size);
		//		pad += 20;
		//	}
		//	drawSNum(dc, bat%10, w2 - 20 + pad, h2 - 100, 4, size);
		//	drawSNum(dc, 24, w2 + 3 + pad, h2 - 100, 4, size);
		//if (batdot && (bat < 100)) {
		//	/* not finished */
		//	var pad = 0;
		//	if (bat > 9) {
		//		drawSNum(dc, bat/10%10, w2 + 23, h2 + 50, 4, size);
		//		pad += 20;
		//	}
		//	drawSNum(dc, bat%10, w2 + 30 + pad, h2 + 50, 4, size);
		//	drawSNum(dc, 24, w2 + 50 + pad, h2 + 50, 4, size);
		//}
		if (bat < 20) {
			dc.setColor(fg, bg);
		}

	}

	function drawMonthLetters(dc, size, first, second, third) {
		var pad = 5;
		var y = h2 - 75;
		var off = 29;
		var off1 = w2 - 4;
		var off2 = off1 + off;
		var off3 = off2 + off;
		drawSNum(dc, first, off1, y, pad, size);
		drawSNum(dc, second, off2, y, pad, size);
		drawSNum(dc, third, off3, y, pad, size);
	}

	function drawMonth(dc, size, mon) {
		if (mon == 1) {
			drawMonthLetters(dc, size, 25, 20, 15);	
		} else if (mon == 2) {
			drawMonthLetters(dc, size, 14, 16, 26);	
		} else if (mon == 3) {
			drawMonthLetters(dc, size, 11, 20, 17);	
		} else if (mon == 4) {
			drawMonthLetters(dc, size, 20, 27, 17);	
		} else if (mon == 5) {
			drawMonthLetters(dc, size, 11, 20, 33);	
		} else if (mon == 6) {
			drawMonthLetters(dc, size, 25, 23, 15);	
		} else if (mon == 7) {
			drawMonthLetters(dc, size, 25, 23, 28);	
		} else if (mon == 8) {
			drawMonthLetters(dc, size, 20, 23, 29);	
		} else if (mon == 9) {
			drawMonthLetters(dc, size, 21, 16, 27);	
		} else if (mon == 10) {
			drawMonthLetters(dc, size, 0, 32, 12);	
		} else if (mon == 11) {
			drawMonthLetters(dc, size, 15, 0, 31);	
		} else if (mon == 12) {
			drawMonthLetters(dc, size, 22, 16, 32);	
		}
	}

	function drawDayLetters(dc, size, first, second, third) {
		var pad = 5;
		var y = h2 + 50;
		var off = 32;
		//var off1 = w2 - 70;
		var off1 = w2 - 42;
		var off2 = off1 + off;
		var off3 = off2 + off;
		drawSNum(dc, first, off1, y, pad, size);
		drawSNum(dc, second, off2, y, pad, size);
		drawSNum(dc, third, off3, y, pad, size);
	}

	function drawDay(dc, size, day) {
		if (day == 1) {
			drawDayLetters(dc, size, 21, 23, 15);
		} else if (day == 2) { // mon
			drawDayLetters(dc, size, 11, 0, 15);
		} else if (day == 3) { // tue
			drawDayLetters(dc, size, 12, 23, 16);
		} else if (day == 4) { // wed
			drawDayLetters(dc, size, 13, 16, 22);
		} else if (day == 5) { // thu
			drawDayLetters(dc, size, 12, 19, 23);
		} else if (day == 6) { // fri
			drawDayLetters(dc, size, 14, 17, 18);
		} else if (day == 7) { // sat
			drawDayLetters(dc, size, 21, 20, 12);
		}
	}

	function drawMsg(dc) {
		var settings = Sys.getDeviceSettings();
		var start = w2 - 59;
		var end = w2 + 62;
		var rad = 2;
		if (settings.notificationCount) {
			//for (var i = h - 22; i < h; i += 6) {
			for (var j = start; j < end; j += 6) {
				dc.fillCircle(j, h - 2, rad);
			}
			//}
		} else if (settings.phoneConnected) {
			for (var j = start; j < end; j += 6) {
				dc.drawCircle(j, h - 2, rad);
			}
		}
	}

	function drawAnalog(dc) {
		var hand = [ h2 - 6, h2 - 14, h2 - 22, h2 - 30 ];
		//var hand = [ w2 - 6, w2 - 14, w2 - 22, w2 - 30 ];
		var now = Sys.getClockTime();
		var hour = Math.PI/6.0 * ((now.hour % 12) + now.min/60.0);
		var min = Math.PI * now.min / 30.0;
		var x = w2 + hand[1]*Math.sin( hour );
		var y = w2 - hand[1]*Math.cos( hour );
		dc.setColor(fg, -1);
		dc.fillCircle(x, y, 5);

		x = w2 + hand[0]*Math.sin( min );
		y = w2 - hand[0]*Math.cos( min );
		dc.fillCircle(x, y, 3);
		x = w2 + hand[1]*Math.sin( min );
		y = w2 - hand[1]*Math.cos( min );
		dc.fillCircle(x, y, 3);

		if (Sys.getDeviceSettings().notificationCount) {
			x = w2 + hand[2]*Math.sin( min );
			y = w2 - hand[2]*Math.cos( min );
			dc.fillCircle(x, y, 3);
		}
	}

	function drawSNum(dc, nr, x, y, pad, size) {
		drawSNumPad(dc, nr, x, y, pad, pad, size);
	}

	function drawSNumPad(dc, nr, x, y, padx, pady, size) {
		for (var i = 0; i < 7; i += 1) {
			for (var j = 0; j < 5; j += 1) {
				if (block[ numS[nr][i] ][ j ]) {
					dc.fillCircle(x + j * padx, y + i * pady, size);
				}
			}
		}
	}

	function onHide() {
	}

	function onExitSleep() {
		on = true;
	}

	function onEnterSleep() {
		countdown = timer;
		on = alwayson;
	}

	/* Get settings and watchface properties */
	function getS() {
		var settings = Sys.getDeviceSettings();
		is24 = settings.is24Hour;

		var app = App.getApp();
		analog = app.Properties.getValue("analog");
		fg = app.Properties.getValue("fg").toNumber();
		bg = app.Properties.getValue("bg").toNumber();
		timer = app.Properties.getValue("count").toNumber();
		batdot = app.Properties.getValue("batdot");
		alwayson = app.Properties.getValue("alwayson");
		/*
		 */
	}
}
