import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Position;
import Toybox.Timer;
import Toybox.Attention;
import Toybox.Sensor;
import Toybox.ActivityRecording;
import Toybox.WatchUi;


class MyRunnaApp extends Application.AppBase {
    private var _timer as Timer.Timer?;
    private var _exStatus as ExerciseStatus?;
    private var _myRunnaView as WatchUi.View?;
    private var _myRunnaDelegate as WatchUi.InputDelegate?;
    private var _session as ActivityRecording.Session?;

    // vibration profiles
    private var vibeProfile = [
        new Attention.VibeProfile(100,300),
        new Attention.VibeProfile(0,600),
        new Attention.VibeProfile(100,300),
        new Attention.VibeProfile(0,600),
        new Attention.VibeProfile(100,300),
        new Attention.VibeProfile(0,500)
    ];


    function initialize() {
        AppBase.initialize();
    }


    // function that is called each second
    function onSecond () as Void {
        if (_exStatus.incrementTime(1)) { // state change
            Attention.vibrate(vibeProfile);
            _session.addLap();
        }

        _exStatus.printStatus("TMR");
        WatchUi.requestUpdate();

    }


    // function that is called for each GPS update
    function onPosition( info as Position.Info ) as Void {
        if (_exStatus.updatePosition(info)) {
            Attention.vibrate(vibeProfile);
            _session.addLap();
        }

        _exStatus.printStatus("GPS");
        WatchUi.requestUpdate();
    }


    // function that is called when the button is pressed
    function onButton() as Void {

        // check if activity recording session exists and initialise if not
        if (_session == null) {
            _session = ActivityRecording.createSession(
                {          
                    :name=>"Interval Running",
                    :sport=>Activity.SPORT_RUNNING,
                    :subSport=>Activity.SUB_SPORT_GENERIC
                }
            );
        }

        // handle the pause button
        if (_exStatus.isPaused) {
            _timer.start(method(:onSecond), 1000, true);
            if (!_session.isRecording()) {
                _session.start();
            } 
        }
        else {
            _timer.stop();
            if (_session.isRecording()) {
                _session.stop();
            }
        }
        _exStatus.startPauseExercise();
        
        _exStatus.printStatus("BUT");
        WatchUi.requestUpdate();
    }


    // function is called when the display is tapped
    function onTap() as Void {
        _exStatus.showLap = !_exStatus.showLap;
        WatchUi.requestUpdate();
    }


    // function is called when the display is pressed
    function onPress() as Void {
        if ((_session != null) && (_exStatus.isPaused)) {
            // confirm if the activity recording must be discarded
            var dialog = new WatchUi.Confirmation("Discard activity?");
            WatchUi.pushView(dialog, new DiscardConfirmationDelegate(method(:discardSession)), WatchUi.SLIDE_IMMEDIATE);
        }
    }


    // function is called when the session has to be discarded
    function discardSession() as Void {
        _session.stop();
        _session.discard();
        _session = null;
    }


    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {

        // initialise GPS 
        Position.enableLocationEvents( Position.LOCATION_CONTINUOUS, method( :onPosition ) );

        // initialise exercise status
        _exStatus = new ExerciseStatus();    
        _exStatus.presetSettings();   
        if (_exStatus.loadSettings()) {
            // initialise timer
            _timer = new Timer.Timer();

            // initialise view and delegate
            _myRunnaView = new MyRunnaView();
            _myRunnaView.setExerciseStatus(_exStatus);
            _myRunnaDelegate = new MyRunnaDelegate(method(:onButton), method(:onTap), method(:onPress));

            // initialise the heart rate sensor
            Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);

            _exStatus.printStatus("STR");
        }
        else { // if settings invalid
            _myRunnaView = new SettingsErrorView();
            _myRunnaDelegate = null;
        }
    }


    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {

        // stop the timer if initialised
        if (_timer != null) {
            _timer.stop();
        }

        // stop and save the activity if not discarded
        if (_session != null) {
            if (_session.isRecording()) {
                _session.stop();
            }
            _session.save();
        }

        // disable GPS
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));

        // disable the heart rate sensor
        Sensor.setEnabledSensors([]);

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