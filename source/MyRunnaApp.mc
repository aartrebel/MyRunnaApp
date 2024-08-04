import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

// Design
// Use GPS updates and user inputs to drive state machine
//      GPS state drivers
//          Distance (end)
//          Pace (range)
//          Time (end)
//      Input state drivers
//          Start/pause button
//          Exit app swipe
//          Save/discard (menu)
//          Lap vs exercise value (tap display)
//
// States:
//      WU / EX / CD
//      Cycles (EX only)
//      Run / Walk
//      Run / Pause
//
// Classes:
//      RunnaApp
//      RunnaView
//      RunnaDelegate

class MyRunnaApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        // initialise settings for debugging only - should be set vir Garmin Connect
        Properties.setValue("wuExType",1);
        Properties.setValue("wuExValue",120);
        Properties.setValue("wuReType",0);
        Properties.setValue("wuReValue",0);

        Properties.setValue("ruExType",1);
        Properties.setValue("ruExValue",180);
        Properties.setValue("ruReType",1);
        Properties.setValue("ruReValue",60);
        Properties.setValue("ruRepeats",3);

        Properties.setValue("cdExType",2);
        Properties.setValue("cdExValue",500);
        Properties.setValue("cdReType",0);
        Properties.setValue("cdReValue",0);

        System.println("Setting initialised");
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new MyRunnaView(), new MyRunnaDelegate() ];
    }

}

function getApp() as MyRunnaApp {
    return Application.getApp() as MyRunnaApp;
}