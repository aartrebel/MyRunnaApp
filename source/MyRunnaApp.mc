import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Position;
import Toybox.Timer;

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
//      Run / Walk / Pause
//      GPS quality
//
// Classes:
//      RunnaApp
//      RunnaView
//      RunnaDelegate

class MyRunnaApp extends Application.AppBase {
    private var _timer as Timer.Timer?;
    private var _exStatus as ExerciseStatus?;
    private var _myRunnaView as WatchUi.View?;
    private var _myRunnaDelegate as WatchUi.InputDelegate?;

    function initialize() {
        AppBase.initialize();
    }


    // function that is called each second
    function onSecond () as Void {
        System.println("1 second");
        _exStatus.incrementTime(1);
        _exStatus.printStatus();
        WatchUi.requestUpdate();
    }


    // function that is called for each GPS update
    function onPosition( info as Position.Info ) as Void {
        System.println( "Position " + info.position.toGeoString( Position.GEO_DM ) );
    }

    // function that is call when the button is pressed
    function onButton() as Void {
        System.println("Button pressed");
        if (_exStatus.isPaused) {
            _timer.start(method(:onSecond), 1000, true); 
        }
        else {
            _timer.stop();
        }
        _exStatus.startPauseExercise();
        
        _exStatus.printStatus();
        WatchUi.requestUpdate();
    }


    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {

        System.println("onStart");

        // initialise GPS 
        Position.enableLocationEvents( Position.LOCATION_CONTINUOUS, method( :onPosition ) );

        // initialise exercise status
        _exStatus = new ExerciseStatus();    
        _exStatus.presetSettings();   
        if (_exStatus.loadSettings()) {
            // initialise timer
            _timer = new Timer.Timer();
            _myRunnaView = new MyRunnaView();
            _myRunnaView.setExerciseStatus(_exStatus);
            _myRunnaDelegate = new MyRunnaDelegate();
            _myRunnaDelegate.setButtonHandler(method(:onButton));

            _exStatus.printStatus();
        }
        else { // if settings invalid
            _myRunnaView = new SettingsErrorView();
            _myRunnaDelegate = null;
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
        //_timer.stop();
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        if (_myRunnaDelegate != null) {
            return [ _myRunnaView, _myRunnaDelegate];
        }
        else {
            return [ _myRunnaView ];
        }
    }

}

function getApp() as MyRunnaApp {
    return Application.getApp() as MyRunnaApp;
}