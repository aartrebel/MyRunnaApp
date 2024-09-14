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
import Toybox.Activity;


class MyRunnaApp extends Application.AppBase {
    // speed check interval (s)
    static private const SPEED_CHECK_INTERVAL = 10;

    private var _timer as Timer.Timer?;
    private var _status as ExerciseStatus?;
    private var _settings as ExerciseSettings?;
    private var _myRunnaView as WatchUi.View?;
    private var _myRunnaDelegate as WatchUi.InputDelegate?;
    private var _session as ActivityRecording.Session?;
    private var _longTimer as Number = 0;

    // vibration profiles
    private var _walkVibeProfile = [
        new Attention.VibeProfile(80,500),
        new Attention.VibeProfile(0,50),
        new Attention.VibeProfile(80,500),
        new Attention.VibeProfile(0,50),
        new Attention.VibeProfile(80,500),
        new Attention.VibeProfile(0,50),
        new Attention.VibeProfile(80,500)
    ];
    private var _runVibeProfile = [
        new Attention.VibeProfile(80,150),
        new Attention.VibeProfile(0,150),
        new Attention.VibeProfile(80,150),
        new Attention.VibeProfile(0,150),
        new Attention.VibeProfile(80,150),
        new Attention.VibeProfile(0,150),
        new Attention.VibeProfile(80,150)
    ];


    function initialize() {
        AppBase.initialize();
    }


    // function checks that speed,state and the 10s timer
    // function buzzes when not running at speed for longer than 10s or when immediate
    private function checkSpeed (checkNow as Boolean) as Void {
        _longTimer += 1;
        switch(_status.exState) {
            case ExerciseStatus.STATE_WARMUP_RUN:
            case ExerciseStatus.STATE_EXERCISE_RUN:
            case ExerciseStatus.STATE_COOLDOWN_RUN:
                if (_status.isRunning()) {
                    _longTimer = 0;
                } else {
                    if ((_longTimer >= SPEED_CHECK_INTERVAL) || (checkNow)) {
                        Attention.vibrate(_runVibeProfile);
                        _longTimer = 0;
                    } 
                }
                break;
            case ExerciseStatus.STATE_WARMUP_WALK:
            case ExerciseStatus.STATE_EXERCISE_WALK:
            case ExerciseStatus.STATE_COOLDOWN_WALK:
                if (!_status.isRunning()) {
                    _longTimer = 0;
                } else {
                    if ((_longTimer >= SPEED_CHECK_INTERVAL) || (checkNow)) {
                        Attention.vibrate(_walkVibeProfile);
                        _longTimer = 0;
                    }
                }
                break;
            case ExerciseStatus.STATE_EXTEND:
                if (checkNow) {
                    Attention.vibrate(_walkVibeProfile);
                    _longTimer = 0;
                }
                break;
            case ExerciseStatus.STATE_INITIAL:
            default:
        }
    } 


    // function that is called each second
    function onSecond () as Void {
        // update activity data
        _status.updateActivity(Activity.getActivityInfo());

        // update duration if not paused 
        if (!_status.isPaused) {

            if (_status.incrementTime(1)) { // state change
                checkSpeed(true);
                _session.addLap();
            } else {
                checkSpeed(false);
            }

        } 

        _status.printStatus("TMR");
        WatchUi.requestUpdate();
    }


    // function that is called for each GPS update
    function onPosition( info as Position.Info ) as Void {
        if (_status.updatePosition(info)) {
            WatchUi.requestUpdate();
            checkSpeed(true);
            _session.addLap();
        }

        _status.printStatus("GPS");
    }


    // function handles the request or cancellation of an exercise pause
    public function handlePause() as Void {

        // handle the pause button
        if (_status.isPaused) {
            // check if in initial state and start if so
            if (_status.exState == ExerciseStatus.STATE_INITIAL) {
                _status.startExercise();
            }

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

            // start/restart recording
            if (!_session.isRecording()) {
                _session.start();
            } 

            // restart timer
            _timer.stop(); 
            _timer.start(method(:onSecond), 1000, true);

            // check the speed and reset the timer
            checkSpeed(true);
        }
        else {
            // pause recording
            if (_session.isRecording()) {
                _session.stop();
            }
        }
        _status.startPauseExercise();
        
        _status.printStatus("BUT");
        WatchUi.requestUpdate();
    }


    // function handles the a display mode change
    // cycles through DISPLAY_REMAINDER, DISPLAY_TOTALS, DISPLAY_LAP
    public function handleDisplayModeChange(isNext as Boolean) as Void {
        if (isNext) {
            (_myRunnaView as MyRunnaView).toggleSpeedOrHR();
        }
        else {
            (_myRunnaView as MyRunnaView).nextDisplayMode();
        }
        WatchUi.requestUpdate();
    }


    // function is called when the session has to be discarded
    // called by the dialogue that confirms to discard
    public function discardSession() as Void {
        _session.stop();
        _session.discard();
        _session = null;
        WatchUi.requestUpdate();
    }


    // function checks is a session is open and returns true if so
    public function isSessionOpen() as Boolean {
        return (_session != null);
    }


    // function handles a request to end the activity
    // opens a dialogue to confirm to end
    public function handleEndActivity() as Void {
        if (_status.isPaused) {
            var dialog;
            if (isSessionOpen()) {
                dialog = new WatchUi.Confirmation("End and save activity?");
            } else {
                dialog = new WatchUi.Confirmation("End activity?\n(nothing to save)");
            }
            WatchUi.pushView(dialog, new MyRunnaConfirmationDelegate(method(:endActivity)), WatchUi.SLIDE_IMMEDIATE);
        }
    }


    // function is called when the activity is ended
    // called by the dialogue that confirms to end
    public function endActivity() as Void {
        System.exit();
    }


    // function opens the menu to configure the exercise
    // called by the onMenu function in the delegate
    public function menuHandler() as Void {
        if (_status.isPaused) {
            var delegate = new ExerciseMenuDelegate();
            WatchUi.pushView(new ExerciseMenuView(_settings, _status, method(:discardSession), method(:isSessionOpen), delegate), 
                delegate, WatchUi.SLIDE_UP);
        } 
    }


    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {

        // initialise GPS 
        Position.enableLocationEvents( Position.LOCATION_CONTINUOUS, method( :onPosition ) );

        // initialise exercise settings
        _settings = new ExerciseSettings();
        //_settings.preset();   
        if (_settings.areValid()) {
            // initialise exercise status
            _status = new ExerciseStatus(_settings);    

            // initialise timer
            _timer = new Timer.Timer();
            _timer.start(method(:onSecond), 1000, true);

            // initialise view and delegate
            _myRunnaView = new MyRunnaView(_status, _settings);
            _myRunnaDelegate = new MyRunnaDelegate(method(:handlePause), method(:handleDisplayModeChange), 
                method(:handleEndActivity), method(:menuHandler));

            // initialise the heart rate sensor
            Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);

            _status.printStatus("STR");
        }
        else { // if settings invalid
            _myRunnaView = new ErrorMessageView("SETTINGS\nARE INVALID\n and have been reset");
            _myRunnaDelegate = new ErrorMessageDelegate();
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