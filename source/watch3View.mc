import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.System as Sys;

using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

using Toybox.Lang as Lang;
using Toybox.ActivityMonitor as Act;
using Toybox.Weather as Wth;
using Toybox.Math as Math;

class watch3View extends Ui.WatchFace {
  var months;
  var weekdays;
  var dateFormat;
  var lang;

  var watchHeight;
  var watchWidth;

  var foregroundColor;
  var backgroundColor;

  var scaleFactor;
  var robotoFont;

  var stepBarY;

  var angle;
  var arcAngle;
  var stats;
  var battery;
  var batteryString;
  var batteryDisplay;
  var minX;
  var maxX;
  var minY;
  var maxY;
  var centerX;
  var centerY;

  var actinfo;

  var steps; // 3000
  var stepGoal; //10000;

  var currentWeatherConditions;
  var viewCurrentWeather;
  var stepColor;
  // var stepBarWidth ;

  // var highlightWidth ;

  function initialize() {
    WatchFace.initialize();

    foregroundColor = Gfx.COLOR_WHITE;
    backgroundColor = Gfx.COLOR_BLACK;
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.WatchFace(dc));

    watchHeight = dc.getHeight();
    watchWidth = dc.getWidth();

    scaleFactor = watchHeight / 180.0;

    stepBarY = watchHeight - watchHeight * 0.15 * scaleFactor;
    //
    minX = 0;
    maxX = watchWidth; // 205
    minY = 0;
    maxY = watchHeight; // 148
    // for now work with a sq screen rather than rectangle
    minX = (maxX - maxY) / 2;
    maxX = minX + maxY;
    centerX = (maxX - minX) / 2 + minX;
    centerY = (maxY - minY) / 2 + minY;
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // clear(dc);
    // dc.setColor(backgroundColor, backgroundColor);

    // Clear gfx
    // dc.setColor(backgroundColor, foregroundColor);
    View.onUpdate(dc);

    drawClock(dc);
    drawSteps(dc);

    //  drawTemperature(); //creates error at loading the screen

    drawBattery();
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {}

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() as Void {}
  //
  function drawBattery() {
    stats = Sys.getSystemStats();
    battery = stats.battery;
    batteryString = battery.toLong().toString() + "%";
    batteryDisplay = View.findDrawableById("Battery") as Text;

    //     //set color of battery
    batteryDisplay.setColor(getApp().getProperty("BatteryColorProp") as Number);

    if (battery <= 50) {
      batteryDisplay.setText(batteryString);
    } else {
      // #don't display battery if battery>50%
    }
  }

  function drawTemperature() {
    viewCurrentWeather = View.findDrawableById("FeelTemperature") as Text;

    // display current temperature
    currentWeatherConditions = Wth.getCurrentConditions();
    viewCurrentWeather.setColor(
      getApp().getProperty("TemperatureColorProp") as Number
    );

    var curentTemperature = currentWeatherConditions.temperature;
    if (curentTemperature != null) {
      viewCurrentWeather.setText(curentTemperature + "°");
    }
  }
  //
  function drawClock(dc) {
    dc.setColor(
      getApp().getProperty("ClockColorProp") as Number,
      Gfx.COLOR_TRANSPARENT
    );

    // Get the current time and format it correctly
    var timeFormat = "$1$:$2$";
    var clockTime = System.getClockTime();
    var hours = clockTime.hour;
    if (!System.getDeviceSettings().is24Hour) {
      if (hours > 12) {
        hours = hours - 12;
      }
    } else {
      if (getApp().getProperty("UseMilitaryFormat")) {
        timeFormat = "$1$$2$";
        hours = hours.format("%02d");
      }
    }
    var timeString = Lang.format(timeFormat, [
      hours,
      clockTime.min.format("%02d"),
    ]);

    dc.drawText(
      dc.getWidth() / 2, // gets the width of the device and divides by 2
      dc.getHeight() / 2, // gets the height of the device and divides by 2
      Graphics.FONT_NUMBER_HOT, // sets the font size
      timeString, // the String to display
      Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER // sets the justification for the text
    );
    //

    drawDate(dc);
  }

  function drawDate(dc) {
    var viewDate = View.findDrawableById("DateLabel") as Text;

    viewDate.setColor(getApp().getProperty("DateColorProp") as Number);

    // viewDate.setColor(getApp().getProperty("ForegroundColor") as Number);

    var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    var dateString = Lang.format("$1$ $2$ $3$", [
      today.day_of_week,
      today.day,
      today.month,
    ]);

    // viewDate.setText(dateString);

    dc.drawText(
      dc.getWidth() / 2, // gets the width of the device and divides by 2
      170, // gets the height of the device and divides by 2
      Graphics.FONT_XTINY, // sets the font size
      dateString, // the String to display
      Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER // sets the justification for the text
    );
    //
  }

  function drawSteps(dc) {
    actinfo = Act.getInfo();

    steps = actinfo.steps; // 3000
    stepGoal = actinfo.stepGoal; //10000;

    var MINUTES_PER_HOUR = 60.0;
    var myAngle = (steps * 60) / stepGoal;
    var arcRadius = (maxX - centerX) / 2;

    // steps=10;
    // stepGoal=10;

    System.println("steps" + steps);

    System.println("stepGoal" + stepGoal);
    dc.setPenWidth(7);

    if (steps >= stepGoal) {
      stepColor = getApp().getProperty("StepsColorGoalReached"); //green

      dc.setColor(stepColor as Number, stepColor as Number);

      dc.drawArc(
        centerX,
        centerY,
        watchHeight / 2 - 3,
        Gfx.ARC_CLOCKWISE,
        90,
        90
      ); //position of circle
    } else {
      var arcSteps = (60.0 * steps) / stepGoal;
      angle = getAngle(arcSteps, MINUTES_PER_HOUR);

      arcAngle = 90 - (180 * angle) / Math.PI;

      if (arcAngle != 90.0) {
        if (steps >= stepGoal / 2) {
          stepColor = getApp().getProperty("StepsColorLoading"); //yellow

          dc.setColor(stepColor as Number, stepColor as Number);
        } else if (steps < stepGoal / 2) {
          stepColor = getApp().getProperty("StepsColor"); //red

          dc.setColor(stepColor as Number, stepColor as Number);
        }

        dc.drawArc(
          centerX,
          centerY,
          watchHeight / 2 - 3,
          Gfx.ARC_CLOCKWISE,
          90,
          arcAngle
        ); //position of circle

        // dc.drawArc(centerX, centerY ,arcRadius+15, Gfx.ARC_CLOCKWISE, 90,arcAngle);  //position of circle
      }

      //don't draw any circle when not enough steps
      // dc.drawArc(centerX, centerY, arcRadius, Gfx.ARC_CLOCKWISE, 90, 1 );
    }
  }

  //! Clear the screen
  hidden function clear(dc) {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();
  }

  hidden function getAngle(value, maxValue) {
    return (value / maxValue) * Math.PI * 2.0;
  }
}
