using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Cal;
using Toybox.Math as Math;

class dotterView extends Ui.WatchFace {
	/* var */
	var sim = 0;
	var thesetting = 0; // ON_MASK | 
	var load = true;    // load settings
	var on = true;      // something
	var batdot = true;  // five min dots on analog I think
	var analog = true;  // analog watchface in lpm
	var digstart = 0;   // to know when to show digital
	var is24 = true;    // YES
	var alwayson = false; // everything every time
	var timer = 9;        // ...
	var countdown = timer;
	var dotsize = 4;
	var w, h, w2, h2;    // width, height, halfwhit
	var fg = Gfx.COLOR_WHITE;
	var bg = Gfx.COLOR_BLACK;
	var size_day_name = 2;
	var size_month = 2;
	var size_day_date = 2;

	/*
	 * the setting
	 */
	var dotsize_lpm = 3;

	/*
	 * device spec
	 */
	var time_yoff;
	var time_xoffhr;
	var time_xoffhl;
	var time_xoffmr;
	var time_xoffml;
	var time_padx;
	var time_pady;
	var date_xoffr;
	var date_xoffl;
	var date_yoff;
	var date_pad;
	var bat_x;
	var bat_pad;
	var bat_y;
	var month_pad;
	var month_y;
	var month_xoff;
	var month_xoff1;
	var day_pad;
	var day_y;
	var day_xoff;
	var day_xoff1;
	var bt_start;
	var bt_end;
	var bt_rad;
	var bt_ypad;

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
		/* common */
		/* bt */
		bt_start = w2 - 59;
		bt_end = w2 + 62;
		bt_rad = 2;
		var settings = Sys.getDeviceSettings();
		if (settings.screenShape == 1) { //circular
			/* for 240x240 */
			/* time */
			time_yoff = h2 - 40;
			time_xoffhr = w2 - 112;
			time_xoffhl = w2 - 54;
			time_xoffmr = w2 + 6;
			time_xoffml = w2 + 64;
			time_padx = 11;
			time_pady = 13;

			/* date */
			date_xoffr = 82;
			date_xoffl = 50;
			date_yoff = 90;
			date_pad = 6;

			/* month */
			month_pad = 6;
			month_y = h2 - 90;
			month_xoff = 32;
			month_xoff1 = w2 - 14;

			/* day */
			day_pad = 7;
			day_y = h2 + 55;
			day_xoff = 42;
			day_xoff1 = w2 - 56;

			/* battery */
			bat_x = w2 - 59;
			bat_pad = 6;
			bat_y = 13;

			/* bt */
			bt_ypad = -16;

		} else if (settings.screenShape == 2) { // semi-circular
			/* time */
			time_yoff = h2 - 30;
			time_xoffhr = w2 - 94;
			time_xoffhl = w2 - 44;
			time_xoffmr = w2 + 8;
			time_xoffml = w2 + 58;
			time_padx = 9;
			time_pady = 11;

			/* date */
			date_xoffr = 74;
			date_xoffl = 47;
			date_yoff = 75;
			date_pad = 5;

			/* month */
			month_pad = 5;
			month_y = h2 - 75;
			month_xoff = 29;
			month_xoff1 = w2 - 4;

			/* day */
			day_pad = 5;
			day_y = h2 + 50;
			day_xoff = 32;
			day_xoff1 = w2 - 42;

			/* battery */
			bat_x = w2 - 59;
			bat_pad = 6;
			bat_y = 1;

			/* bt */
			bt_ypad = -2;
		}
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
			drawTime(dc, dotsize, dotsize);
			if (alwayson || (countdown > 0)) {
				drawDate(dc, size_day_date);
				drawBat(dc, dotsize);
				countdown -= 1;
			}
			drawMsg(dc);
		} else if (analog) {
			drawAnalog(dc);
		} else {
			drawTime(dc, dotsize_lpm, dotsize_lpm);
		}
	}

	function drawTime(dc, size_h, size_m) {
		dc.setColor(fg, -1);
		/*
		if (on && false) {
			for (var i = 0; i < h; i += 4) {
				for (var j = 0; j < w; j += 4) {
					dc.fillCircle( j, i, 1);
				}
			}
		}
		*/
		var now = Cal.info(Time.now(), Time.FORMAT_SHORT);
		var hour = now.hour;
		var min = now.min;
		if (!is24 && hour > 12) {
			hour -= 12;
		}
		// hour
		drawSNumPad(dc, hour/10, time_xoffhr, time_yoff, time_padx, time_pady, size_h);
		drawSNumPad(dc, hour%10, time_xoffhl, time_yoff, time_padx, time_pady, size_h);
		// minutes
		drawSNumPad(dc, min/10, time_xoffmr, time_yoff, time_padx, time_pady, size_m);
		drawSNumPad(dc, min%10, time_xoffml, time_yoff, time_padx, time_pady, size_m);
	}

	function drawDate(dc, size) {
		var now = Cal.info(Time.now(), Time.FORMAT_SHORT);
		//date perhaps
		var day = now.day;
		var mon = now.month;
		var y = h2 - date_yoff;

		drawSNum(dc, day/10, w2 - date_xoffr, y, date_pad, size);
		drawSNum(dc, day%10, w2 - date_xoffl, y, date_pad, size);

		drawMonth(dc, size_month, mon);

		day = now.day_of_week;
		drawDay(dc, size_day_name, day);
	}

	/*
	 * TODO: change color when it gets to like twenty percent...
  	 */
	function drawBat(dc, rad) {
		var bat = Sys.getSystemStats().battery.toNumber();
		// I whish I had a fancy watch that supported this... but wait, I do now
		var stat = Sys.getSystemStats();
		if (stat has :charging && stat.charging == true) {
			if (stat.battery.toNumber() > 95) {
				dc.setColor(Gfx.COLOR_GREEN, -1);
			} else {
				dc.setColor(Gfx.COLOR_YELLOW, -1);
			}
		} else if (bat < 20) {
			dc.setColor(Gfx.COLOR_PINK, -1);
		}

		bat = bat / 5; //20;

		for (var i = 0; i < bat && i < 20; i += 1) {
			dc.fillCircle(bat_x + i * bat_pad, bat_y, rad);
		}
		for (var i = bat; i < 20; i += 1) {
			dc.drawCircle(bat_x + i * bat_pad, bat_y, rad);
		}
		if (bat < 20) {
			dc.setColor(fg, -1);
		}

	}

	function drawMonthLetters(dc, size, first, second, third) {
		drawSNum(dc, first, month_xoff1, month_y, month_pad, size);
		drawSNum(dc, second, month_xoff1 + month_xoff, month_y, month_pad, size);
		drawSNum(dc, third, month_xoff1 + 2 * month_xoff, month_y, month_pad, size);
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
		drawSNum(dc, first, day_xoff1, day_y, day_pad, size);
		drawSNum(dc, second, day_xoff1 + day_xoff, day_y, day_pad, size);
		drawSNum(dc, third, day_xoff1 + 2 * day_xoff, day_y, day_pad, size);
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
		var local_settings = Sys.getDeviceSettings();
		
		if (local_settings.notificationCount) {
			for (var j = bt_start; j < bt_end; j += 6) {
				dc.fillCircle(j, h + bt_ypad, bt_rad);
			}
		} else if (local_settings.phoneConnected) {
			for (var j = bt_start; j < bt_end; j += 6) {
				dc.drawCircle(j, h + bt_ypad, bt_rad);
			}
		}
	}

	function drawAnalog(dc) {
		var now = Sys.getClockTime();
		if (digstart & (1 << now.hour)) {
			drawTime(dc, dotsize, dotsize);
			return;
		}
		var hand = [ w2 - 24, w2 - 32, w2 - 40, w2 - 48 ];
		var hour = Math.PI/6.0 * ((now.hour % 12) + now.min/60.0);
		var min = Math.PI * now.min / 30.0;
		var x = w2 + hand[1]*Math.sin( hour );
		var y = h2 - hand[1]*Math.cos( hour );
		dc.setColor(fg, -1);
		dc.fillCircle(x, y, 5);

		x = w2 + hand[0]*Math.sin( min );
		y = h2 - hand[0]*Math.cos( min );
		dc.fillCircle(x, y, 3);
		x = w2 + hand[1]*Math.sin( min );
		y = h2 - hand[1]*Math.cos( min );
		dc.fillCircle(x, y, 3);

		if (Sys.getDeviceSettings().notificationCount) {
			x = w2 + hand[2]*Math.sin( min );
			y = h2 - hand[2]*Math.cos( min );
			dc.fillCircle(x, y, 3);
		}
		if (batdot) {
			for (var i = 0; i < 12; i += 1) {
				x = w2 + hand[0]*Math.sin( Math.PI * i / 6.0 );
				y = h2 - hand[0]*Math.cos( Math.PI * i / 6.0 );
				dc.drawCircle(x, y, 2);
			}
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

	function getS() {
		var settings = Sys.getDeviceSettings();
		is24 = settings.is24Hour;

		var app = App.getApp();
		var dig = 0;
		var duration = 0;
		digstart = 0;
		if (app has :Storage) {
			analog = app.Properties.getValue("analog");
			fg = app.Properties.getValue("fg").toNumber();
			bg = app.Properties.getValue("bg").toNumber();
			timer = app.Properties.getValue("count").toNumber();
			batdot = app.Properties.getValue("batdot");
			alwayson = app.Properties.getValue("alwayson");
			dig = app.Properties.getValue("digstart");
			duration = app.Properties.getValue("duration");
			thesetting = app.Properties.getValue("thesetting");
		} else {
			analog = app.getProperty("analog");
			fg = app.getProperty("fg").toNumber();
			bg = app.getProperty("bg").toNumber();
			timer = app.getProperty("count").toNumber();
			batdot = app.getProperty("batdot");
			alwayson = app.getProperty("alwayson");
			dig = app.getProperty("digstart");
			duration = app.getProperty("duration");
			thesetting = app.getProperty("thesetting");
		}
		if (duration) {
			for (var i = dig; i < (dig + duration); i += 1) {
				digstart |= 1 << (i % 24);
			}
		}
		/*
		 * surprise
		 */
		if (thesetting & 1) {
			var d = (thesetting >> 1) & 3;
			dotsize_lpm = d ? d : 4;
		}
		/* 
		 * invert colors to see screen size in simulator
		 */
		if (sim) {
			fg = Gfx.COLOR_BLACK;
			bg = Gfx.COLOR_WHITE;
		}
	}
}
