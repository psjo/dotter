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
    var timer = 9;
    var dott = 3, dotd = 2, dotts = 2;
    var w, h, w2, h2;
    var fg = Gfx.COLOR_WHITE;

    // building blocks for numbers and ....
    var block = [ [ 0, 0, 0, 0, 0 ], // 0
                  [ 1, 1, 1, 1, 1 ], // 1
                  [ 1, 0, 0, 0, 1 ], // 2
                  [ 0, 0, 0, 0, 1 ], // 3
                  [ 0, 0, 0, 1, 0 ], // 4
                  [ 0, 0, 1, 0, 0 ], // 5
                  [ 0, 1, 0, 0, 0 ], // 6
                  [ 1, 0, 0, 0, 0 ], // 7
                  [ 0, 1, 1, 0, 0 ], // 8
                  [ 0, 1, 1, 1, 0 ], // 9
                  [ 1, 1, 1, 1, 0 ], // 10
                  [ 0, 1, 1, 1, 1 ], // 11
                  [ 0, 1, 0, 1, 0 ], // 12
                  [ 1, 0, 1, 0, 1 ], // 13
                  [ 1, 1, 0, 1, 1 ], // 14
                  [ 1, 1, 1, 0, 0 ], // 15
                  [ 1, 1, 0, 0, 1 ], // 16
                  [ 1, 0, 0, 1, 1 ], // 17
                  [ 1, 0, 0, 1, 0 ], // 18
                  [ 1, 0, 1, 0, 0 ] ]; // 19
    // use blocks to make numbers
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
                  [ 9, 2, 7, 7, 7, 2, 9 ] ]; // C 32

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
        dc.setColor(fg, 0);
        dc.clear();
        if (on) {
            drawTime(dc, dott);
            if (timer > 0) {
                drawDate(dc, dotd);
                drawBat(dc, dotd);
                timer -= 1;
            }
            drawMsg(dc);
        } else if (analog) {
            drawAnalog(dc);
        } else {
            drawTime(dc, dotts);
        }
    }

    function drawTime(dc, size) {
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
        drawSNum(dc, hour/10, w2 - 100, h2 - 24, 9, size); // hour
        drawSNum(dc, hour%10, w2 - 50, h2 - 24, 9, size);
        drawSNum(dc, 10, w2 - 18, h2 - 24, 9, size); // :
        drawSNum(dc, min/10, w2 + 14, h2 - 24, 9, size); // min
        drawSNum(dc, min%10, w2 + 63, h2 - 24, 9, size);
    }

    function drawDate(dc, size) {
        var now = Cal.info(Time.now(), Time.FORMAT_SHORT);
        //date perhaps
        var day = now.day;
        var mon = now.month;
        var y = h2 - 65;
        if (batdot) {
            y -= 5;
        }
        drawSNum(dc, day/10, w2 - 74, y, 5, size);
        drawSNum(dc, day%10, w2 - 47, y, 5, size);

        drawMonth(dc, size, mon);

        day = now.day_of_week;
        drawDay(dc, size, day);
    }

    function drawBat(dc, size) {
        var bat = Sys.getSystemStats().battery.toNumber();
        if (batdot) {
            var rad = 6;
            bat = bat / 20;
            for (var i = 0; i <= bat; i += 1) {
                dc.fillCircle(59 + i * 25, 20, rad);
            }
            for (var i = bat + 1; i < 5; i += 1) {
                dc.drawCircle(59 + i * 25, 20, rad);
            }
        } else {
            var pad = 0;

            if (bat > 99) {
                drawSNum(dc, bat/100, w2 - 44, h2 - 100, 4, size);
            }
            if (bat > 9) {
                drawSNum(dc, bat/10%10, w2 - 23, h2 - 100, 4, size);
                pad += 20;
            }
            drawSNum(dc, bat%10, w2 - 20 + pad, h2 - 100, 4, size);
            drawSNum(dc, 24, w2 + 3 + pad, h2 - 100, 4, size);
        }
    }

    function drawMonth(dc, size, mon) {
        var pad = 5;
        var y = h2 - 65;
        if (batdot) {
            y -= 5;
        }
        if (mon == 1) {
            drawSNum(dc, 25, w2 - 2, y, pad, size);
            drawSNum(dc, 20, w2 + 27, y, pad, size);
            drawSNum(dc, 15, w2 + 56, y, pad, size);
        } else if (mon == 2) {
            drawSNum(dc, 14, w2 - 2, y, pad, size);
            drawSNum(dc, 16, w2 + 27, y, pad, size);
            drawSNum(dc, 26, w2 + 56, y, pad, size);
        } else if (mon == 3) {
            drawSNum(dc, 11, w2 - 2, y, pad, size);
            drawSNum(dc, 20, w2 + 27, y, pad, size);
            drawSNum(dc, 17, w2 + 56, y, pad, size);
        } else if (mon == 4) {
            drawSNum(dc, 20, w2 - 2, y, pad, size);
            drawSNum(dc, 27, w2 + 27, y, pad, size);
            drawSNum(dc, 17, w2 + 56, y, pad, size);
        } else if (mon == 5) {
            drawSNum(dc, 11, w2 - 2, y, pad, size);
            drawSNum(dc, 20, w2 + 27, y, pad, size);
            drawSNum(dc, 25, w2 + 56, y, pad, size);
        } else if (mon == 6) {
            drawSNum(dc, 25, w2 - 2, y, pad, size);
            drawSNum(dc, 23, w2 + 27, y, pad, size);
            drawSNum(dc, 15, w2 + 56, y, pad, size);
        } else if (mon == 7) {
            drawSNum(dc, 25, w2 - 2, y, pad, size);
            drawSNum(dc, 15, w2 + 27, y, pad, size);
            drawSNum(dc, 28, w2 + 56, y, pad, size);
        } else if (mon == 8) {
            drawSNum(dc, 20, w2 - 2, y, pad, size);
            drawSNum(dc, 23, w2 + 27, y, pad, size);
            drawSNum(dc, 29, w2 + 56, y, pad, size);
        } else if (mon == 9) {
            drawSNum(dc, 21, w2 - 2, y, pad, size);
            drawSNum(dc, 16, w2 + 27, y, pad, size);
            drawSNum(dc, 27, w2 + 56, y, pad, size);
        } else if (mon == 10) {
            drawSNum(dc, 0, w2 - 2, y, pad, size);
            drawSNum(dc, 32, w2 + 27, y, pad, size);
            drawSNum(dc, 12, w2 + 56, y, pad, size);
        } else if (mon == 11) {
            drawSNum(dc, 15, w2 - 2, y, pad, size);
            drawSNum(dc, 0, w2 + 27, y, pad, size);
            drawSNum(dc, 31, w2 + 56, y, pad, size);
        } else if (mon == 12) {
            drawSNum(dc, 22, w2 - 2, y, pad, size);
            drawSNum(dc, 16, w2 + 27, y, pad, size);
            drawSNum(dc, 32, w2 + 56, y, pad, size);
        }
    }

    function drawDay(dc, size, day) {
        var pad = 5;
        var y = h2 + 45;

        if (day == 1) {
            drawSNum(dc, 21, w2 - 42, y, pad, size);
            drawSNum(dc, 23, w2 - 10, y, pad, size);
            drawSNum(dc, 15, w2 + 22, y, pad, size);
        } else if (day == 2) { // mon
            drawSNum(dc, 11, w2 - 42, y, pad, size);
            drawSNum(dc, 0, w2 - 10, y, pad, size);
            drawSNum(dc, 15, w2 + 22, y, pad, size);
        } else if (day == 3) { // tue
            drawSNum(dc, 12, w2 - 42, y, pad, size);
            drawSNum(dc, 23, w2 - 10, y, pad, size);
            drawSNum(dc, 16, w2 + 22, y, pad, size);
        } else if (day == 4) { // wed
            drawSNum(dc, 13, w2 - 42, y, pad, size);
            drawSNum(dc, 16, w2 - 10, y, pad, size);
            drawSNum(dc, 22, w2 + 22, y, pad, size);
        } else if (day == 5) { // thu
            drawSNum(dc, 12, w2 - 42, y, pad, size);
            drawSNum(dc, 19, w2 - 10, y, pad, size);
            drawSNum(dc, 23, w2 + 22, y, pad, size);
        } else if (day == 5) { // fri
            drawSNum(dc, 14, w2 - 42, y, pad, size);
            drawSNum(dc, 17, w2 - 10, y, pad, size);
            drawSNum(dc, 18, w2 + 22, y, pad, size);
        } else if (day == 5) { // sat
            drawSNum(dc, 21, w2 - 42, y, pad, size);
            drawSNum(dc, 20, w2 - 10, y, pad, size);
            drawSNum(dc, 12, w2 + 22, y, pad, size);
        }
    }

    function drawMsg(dc) {
        if (Sys.getDeviceSettings().notificationCount) {
            for (var i = h - 22; i < h; i += 6) {
                for (var j = w2 - 42; j < w2 + 43; j += 6) {
                    dc.fillCircle(j, i, 2);
                }
            }
        }
    }

    function drawAnalog(dc) {
        var hand = [ w2 - 6, w2 - 14, w2 - 28, w2 - 42 ];
        var now = Sys.getClockTime();
        var hour = Math.PI/6.0 * ((now.hour % 12) + now.min/60.0);
        var min = Math.PI * now.min / 30.0;
        var x = w2 + hand[1]*Math.sin( hour );
        var y = w2 - hand[1]*Math.cos( hour );
        dc.setColor(fg, -1);
        dc.fillCircle(x, y, 5);

        x = w2 + hand[0]*Math.sin( min );
        y = w2 - hand[0]*Math.cos( min );
        dc.setColor(fg, -1);
        dc.fillCircle(x, y, 3);
        x = w2 + hand[1]*Math.sin( min );
        y = w2 - hand[1]*Math.cos( min );
        dc.fillCircle(x, y, 3);

    }

    function drawSNum(dc, nr, x, y, pad, size) {
        for (var i = 0; i < 7; i += 1) {
            for (var j = 0; j < 5; j += 1) {
                if (block[ numS[nr][i] ][ j ]) {
                    dc.fillCircle(x+j*pad, y+i*pad, size);
                }
            }
        }
    }

    function onHide() {
    }

    function onExitSleep() {
        on = true;
        timer = 5;
    }

    function onEnterSleep() {
        on = false;
    }

    function getS() {
        var app = App.getApp();
        analog = app.getProperty("analog");
        fg = app.getProperty("fg");
        timer = app.getProperty("count");
        batdot = app.getProperty("batdot");
    }
}
