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
    private var _timer as Timer.Timer?;
    //private var _updateTimer as Timer.Timer?;
    private var _exStatus as ExerciseStatus?;
    private var _myRunnaView as WatchUi.View?;
    private var _myRunnaDelegate as WatchUi.InputDelegate?;
    private var _session as ActivityRecording.Session?;

    // vibration profiles
    private var vibeProfile = [
        new Attention.VibeProfile(100,250),
        new Attention.VibeProfile(0,250),
        new Attention.VibeProfile(100,250),
        new Attention.VibeProfile(0,250),
        new Attention.VibeProfile(100,250),
        new Attention.VibeProfile(0,250),
        new Attention.VibeProfile(100,250)
    ];


    function initialize() {
        AppBase.initialize();
    }


    // function that is called each second
    function onSecond () as Void {
        // update duration if not paused 
        if (!_exStatus.isPaused) {
            if (_exStatus.incrementTime(1)) { // state change
                Attention.vibrate(vibeProfile);
                _session.addLap();
            }
        }

        // update activity data
        _exStatus.updateActivity(Activity.getActivityInfo());

        _exStatus.printStatus("TMR");
        WatchUi.requestUpdate();

    }


    // function that is called for each GPS update
    function onPosition( info as Position.Info ) as Void {
        if (_exStatus.updatePosition(info)) {
            WatchUi.requestUpdate();
            Attention.vibrate(vibeProfile);
            _session.addLap();
        }

        _exStatus.printStatus("GPS");
    }


    // function handles the request or cancellation of an exercise pause
    public function handlePause() as Void {

        // handle the pause button
        if (_exStatus.isPaused) {
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
        }
        else {
            // pause recording
            if (_session.isRecording()) {
                _session.stop();
            }
        }
        _exStatus.startPauseExercise();
        
        _exStatus.printStatus("BUT");
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


    // function handles a request to discard the session
    // opens a dialogue to confirm to discard
    public function handleDiscardSession() as Void {
        if ((_session != null) && (_exStatus.isPaused)) {
            var dialog = new WatchUi.Confirmation("Discard activity?");
            WatchUi.pushView(dialog, new DiscardConfirmationDelegate(method(:discardSession)), WatchUi.SLIDE_IMMEDIATE);
        }
    }


    // function is called when the session has to be discarded
    // called by the dialogue that confirms to discard
    public function discardSession() as Void {
        _session.stop();
        _session.discard();
        _session = null;
    }


    // function handles a request to end the activity
    // opens a dialogue to confirm to end
    public function handleEndActivity() as Void {
        if (_exStatus.isPaused) {
            var dialog;
            if (_session != null) {
                dialog = new WatchUi.Confirmation("End and save activity?");
            } else {
                dialog = new WatchUi.Confirmation("End activity?\n(nothing to save)");
            }
            WatchUi.pushView(dialog, new DiscardConfirmationDelegate(method(:endActivity)), WatchUi.SLIDE_IMMEDIATE);
        }
    }


    // function is called when the activity is ended
    // called by the dialogue that confirms to end
    public function endActivity() as Void {
        System.exit();
    }


    // function formats the submenu text
    // uses the exercise type and value
    private function subMenuText(exType as ExType, value as Number) as String{
        switch (exType) {
            case NONE:
                return ExerciseInputView.NONE_TITLE;
            case DURATION:
                // format duration
                var seconds = value%60;
                var minutes = (value/60)%60;
                var hours = value/3600;
                return ExerciseInputView.DUR_TITLE + " = " + hours.toString() + ":" + minutes.format("%02u") +
                    ":" + seconds.format("%02u");
            case DISTANCE:
            default:
                return ExerciseInputView.DIST_TITLE + " = " + value.toString() + ExerciseInputView.DIST_UNIT;
        }
    }


    // function opens the menu to configure the exercise
    // called by the onMenu function in the delegate
    public function menuHandler() as Void {
        // Generate a new menu
        var menu = new WatchUi.Menu2({:title=>"Exercise Details"});

        // Add menu items for the configurables
        menu.addItem(new WatchUi.MenuItem("Discard activity", null, ExerciseMenuDelegate.DISCARD_ITEM, null));
        menu.addItem(new WatchUi.MenuItem("Warmup - run", subMenuText(_exStatus.wuExType, _exStatus.wuExValue), ExerciseMenuDelegate.WARMUP_RUN_ITEM, null));
        menu.addItem(new WatchUi.MenuItem("Warmup - walk", subMenuText(_exStatus.wuReType, _exStatus.wuReValue), ExerciseMenuDelegate.WARMUP_WALK_ITEM, null));
        menu.addItem(new WatchUi.MenuItem("Exercise - run", subMenuText(_exStatus.ruExType, _exStatus.ruExValue), ExerciseMenuDelegate.EXERCISE_RUN_ITEM, null));
        menu.addItem(new WatchUi.MenuItem("Exercise - walk", subMenuText(_exStatus.ruReType, _exStatus.ruReValue), ExerciseMenuDelegate.EXERCISE_WALK_ITEM, null));
        menu.addItem(new WatchUi.MenuItem("Exercise - repeats", _exStatus.ruRepeats.toString(), ExerciseMenuDelegate.EXERCISE_REPEATS_ITEM, null));
        menu.addItem(new WatchUi.MenuItem("Cooldown - run", subMenuText(_exStatus.cdExType, _exStatus.cdExValue), ExerciseMenuDelegate.COOLDOWN_RUN_ITEM, null));
        menu.addItem(new WatchUi.MenuItem("Cooldown - walk", subMenuText(_exStatus.cdReType, _exStatus.cdReValue), ExerciseMenuDelegate.COOLDOWN_WALK_ITEM, null));
        WatchUi.pushView(menu, new ExerciseMenuDelegate(), WatchUi.SLIDE_UP);
    }


    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        System.println("onStart() called");

        // initialise GPS 
        Position.enableLocationEvents( Position.LOCATION_CONTINUOUS, method( :onPosition ) );

        // initialise exercise status
        _exStatus = new ExerciseStatus();    
        //_exStatus.presetSettings();   
        if (_exStatus.loadSettings()) {
            // initialise timer
            _timer = new Timer.Timer();
            _timer.start(method(:onSecond), 1000, true);

            // initialise view and delegate
            _myRunnaView = new MyRunnaView(_exStatus);
            _myRunnaDelegate = new MyRunnaDelegate(method(:handlePause), method(:handleDisplayModeChange), 
                method(:handleEndActivity), method(:menuHandler));

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
        System.println("onStop() called");

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