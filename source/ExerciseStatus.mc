import Toybox.System;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Math;
import Toybox.UserProfile;
import Toybox.Activity;

class ExerciseStatus {

    // exercise state values
    public enum ExState {
        STATE_WARMUP = 1,
        STATE_EXERCISE = 2,
        STATE_COOLDOWN = 3,
        STATE_EXTEND = 4
    }


    // settings
    private var _settings as ExerciseSettings?;

    // state variabls
    public var totTime as Lang.Number = 0;
    public var totDist as Lang.Double = 0.0d;
    public var lapTime as Lang.Number = 0;
    public var lapDist as Lang.Double = 0.0d;
    public var remTime as Lang.Number = 0;
    public var remDist as Lang.Double = 0.0d;
    public var finish as Lang.Number = 0;
    public var speed as Lang.Float = 0.0;
    public var heartRate as Number = 0;

    public var exState as ExState = STATE_WARMUP;
    public var isRun as Lang.Boolean = true;
    public var isPaused as Lang.Boolean = true;

    public var exCount as Lang.Number = 0;

    private var prevLocation as Position.Location?;
    public var gpsAccuracy as Position.Quality = Position.QUALITY_NOT_AVAILABLE;
    private const LAT = 0;
    private const LON = 1;

    // other variables
    private var _filter as FIRFilter?;
    public var heartRateZones as Array<Number>;


    public function initialize(settings as ExerciseSettings) {
        // set exercise settings
        _settings = settings;

        // initialise FIR filter for speed
        _filter = new FIRFilter(FIR_AVERAGE_OFF_10_FILTER);
        heartRateZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_RUNNING);

        // set initial status
        if (_settings.wuExType != ExerciseSettings.TYPE_NONE) {
            finish = _settings.wuExValue;
            isRun = true;
        } else {
            finish = _settings.wuReValue;
            isRun = false;
        }

    }


    public function printStatus(caller as Lang.String) as Void {
        System.println ("Status[" + caller +"]: state=" + exState + ", run=" + isRun + ", count=" + exCount + ", pause=" + isPaused + 
            ", totT=" + MyRunnaView.formatTime(totTime) + ", lapT=" + MyRunnaView.formatTime(lapTime) +
            ", totD=" + totDist.format("%1.0f") + ", lapD=" + lapDist.format("%1.0f") + ", speed=" + speed.format("%1.2f") +
            ", gps=" + gpsAccuracy);
    }


    // test if distance or duration is a priority
    public function isPriority(exType as ExerciseSettings.ExType) as Boolean {
        switch (exState) {
            case STATE_WARMUP:
                if (isRun) {
                    return (_settings.wuExType == exType);
                }
                else {
                    return (_settings.wuReType == exType);
                }
            case STATE_EXERCISE:
                if (isRun) {
                    return (_settings.ruExType == exType);
                }
                else {
                    return (_settings.ruReType == exType);
                }
            case STATE_COOLDOWN:
                if (isRun) {
                    return (_settings.cdExType == exType);
                }
                else {
                    return (_settings.cdReType == exType);
                }
            case STATE_EXTEND:
            default:
                return false;
        }
    }


    // calculates the distance travelled from location A to location B in meters
    private function calcDistance(locationA as Position.Location, locationB as Position.Location) as Lang.Double {
        var locA = locationA.toRadians();
        var locB = locationB.toRadians();
        var dLoc = [ (locB[LAT]-locA[LAT]), (locB[LON]-locA[LON]) ];

        var a = Math.sin(dLoc[LAT]/2.0) * Math.sin(dLoc[LAT]/2.0) +
            Math.sin(dLoc[LON]/2.0) * Math.sin(dLoc[LON]/2.0) * Math.cos(locA[LAT]) * Math.cos(locB[LAT]); 
        var c = 2.0 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return 6371000.0*c;
    }


    // updates the state
    private function updateState(testValue as Double, testType as ExerciseSettings.ExType) as Boolean {
        var curState = exState;
        var curSubstate = isRun;
        var curExCount = exCount;

        switch (exState) {
            case STATE_WARMUP:
                if (isRun) {
                    if ((testValue >= _settings.wuExValue) && (_settings.wuExType == testType)) {
                        lapTime = 0;
                        lapDist = 0.0d;
                        if (_settings.wuReType != ExerciseSettings.TYPE_NONE) {
                            isRun = false;
                            finish = _settings.wuReValue;
                        }
                        else {
                            exState = STATE_EXERCISE;
                            if (_settings.ruExType != ExerciseSettings.TYPE_NONE) {
                                finish = _settings.ruExValue;
                            }
                            else {
                                isRun = false;
                                finish = _settings.ruReValue;
                            }
                        }
                    }
                }
                else {
                    if ((testValue >= _settings.wuReValue) && (_settings.wuReType == testType)) {
                        lapTime = 0;
                        lapDist = 0.0d;
                        exState = STATE_EXERCISE;
                        if (_settings.ruExType != ExerciseSettings.TYPE_NONE) {
                            isRun = true;
                            finish = _settings.ruExValue;
                        }
                        else {
                            finish = _settings.ruReValue;
                        }
                    }
                }
                break;
            case STATE_EXERCISE: 
                if (isRun) {
                    if ((testValue >= _settings.ruExValue) && (_settings.ruExType == testType)) {
                        lapTime = 0;
                        lapDist = 0.0d;
                        if (_settings.ruReType != ExerciseSettings.TYPE_NONE) {
                            isRun = false;
                            finish = _settings.ruReValue;
                        }
                        else {
                            exCount += 1;
                            if (exCount == _settings.ruRepeats) {
                                exState = STATE_COOLDOWN;
                                if (_settings.cdExType != ExerciseSettings.TYPE_NONE) {
                                    finish = _settings.cdExValue;
                                }
                                else {
                                    isRun = false;
                                    finish = _settings.cdReValue;
                                }
                            }
                        }
                    }
                }
                else {
                    if ((testValue >= _settings.ruReValue) && (_settings.ruReType == testType)) {
                        lapTime = 0;
                        lapDist = 0.0d;
                        exCount += 1;
                        if (exCount == _settings.ruRepeats) {
                            exState = STATE_COOLDOWN;
                            if (_settings.cdExType != ExerciseSettings.TYPE_NONE) {
                                isRun = true;
                                finish = _settings.cdExValue;
                            }
                            else {
                                finish = _settings.cdReValue;
                            }
                        }
                        else {
                            if (_settings.ruExType != ExerciseSettings.TYPE_NONE) {
                                isRun = true;
                                finish = _settings.ruExValue;
                            }
                            else {
                                finish = _settings.ruReValue;
                            }
                        }
                    }
                }
                break;
            case STATE_COOLDOWN: 
                if (isRun) {
                    if ((testValue >= _settings.cdExValue) && (_settings.cdExType == testType)) {
                        lapTime = 0;
                        lapDist = 0.0d;
                        isRun = false;
                        if (_settings.cdReType != ExerciseSettings.TYPE_NONE) {
                            finish = _settings.cdReValue;
                        }
                        else {
                            exState = STATE_EXTEND;
                            finish = 0;
                        }
                    }
                }
                else {
                    if ((testValue >= _settings.cdReValue) && (_settings.cdReType == testType)) {
                        lapTime = 0;
                        lapDist = 0.0d;
                        finish = 0;
                        exState = STATE_EXTEND;
                    }
                }
                break;
            case STATE_EXTEND:
            default: 
        }

        // return state change
        return ((curState != exState) || (curSubstate != isRun) || (curExCount != exCount));

    }


    // increments the total and exercise time with duration
    // duration is in seconds
    public function incrementTime(duration as Lang.Number) as Boolean {

        // update lap time and total duration
        totTime += duration;
        lapTime += duration;

        // test progress and update state
        return updateState(lapTime.toDouble(), ExerciseSettings.TYPE_DURATION);
    }


    // updates the activity data
    public function updateActivity(info as Activity.Info) as Void {
        // update heart rate
        if (info.currentHeartRate != null) {
            heartRate = info.currentHeartRate;
        }
    }


    // updates the distance and pace based on an updated coordinate
    public function updatePosition(gpsInfo as Position.Info) {
        //update GPS quality
        gpsAccuracy = gpsInfo.accuracy;

        //update speed
        if (gpsAccuracy >= Position.QUALITY_POOR) {
            speed = _filter.process(gpsInfo.speed);
        }

        if (!isPaused) {
            // update distance travelled
            if (prevLocation != null) {
                var deltaDist = calcDistance(prevLocation, gpsInfo.position);
                lapDist += deltaDist;
                totDist += deltaDist;
            }
            prevLocation = gpsInfo.position;

            // test progress and update state
            return updateState(lapDist, ExerciseSettings.TYPE_DISTANCE);
        }
        else { // if paused
        
            //update previous location to new
            prevLocation = gpsInfo.position;

            return false;

        }
    }


    // starts or pauses the exercise
    public function startPauseExercise() {
        isPaused = !isPaused;
    }


}