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
        STATE_INITIAL,
        STATE_WARMUP_RUN,
        STATE_WARMUP_WALK,
        STATE_EXERCISE_RUN,
        STATE_EXERCISE_WALK,
        STATE_COOLDOWN_RUN,
        STATE_COOLDOWN_WALK,
        STATE_EXTEND
    }
//    public enum ExState {
//        STATE_WARMUP = 1,
//        STATE_EXERCISE = 2,
//        STATE_COOLDOWN = 3,
//        STATE_EXTEND = 4
//    }


    // settings
    private var _settings as ExerciseSettings?;

    // state variabls
    public var totTime as Lang.Number = 0;
    public var totDist as Lang.Float = 0.0;
    public var preciseTotDist as Lang.Double = 0.0d;
    public var lapTime as Lang.Number = 0;
    public var lapDist as Lang.Float = 0.0;
    public var preciseLapDist as Lang.Double = 0.0d;
    public var remTime as Lang.Number = 0;
    public var remDist as Lang.Float= 0.0;
    public var speed as Lang.Float = 0.0;
    public var heartRate as Number = 0;

    public var exState as ExState = STATE_INITIAL;
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
        totTime = 0;
        preciseTotDist = 0.0d;
        lapTime = 0;
        preciseLapDist = 0.0d;
        exState = STATE_INITIAL;
        exCount = 0;

    }


    public function printStatus(caller as Lang.String) as Void {
        System.println ("Status[" + caller +"]: state=" + exState + ", count=" + exCount + ", pause=" + isPaused + 
            ", totT=" + MyRunnaView.formatTime(totTime) + ", lapT=" + MyRunnaView.formatTime(lapTime) +
            ", totD=" + MyRunnaView.formatDistance(totDist) + ", lapD=" + MyRunnaView.formatDistance(lapDist) + ", speed=" + speed.format("%1.2f") +
            ", gps=" + gpsAccuracy);
    }


    // test if distance or duration is a priority
    public function isPriority(exType as ExerciseSettings.ExType) as Boolean {
        return getCurrentTargetType() == exType;
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


    // function returns the current target type (duration, distance or none)
    private function getCurrentTargetType() as ExerciseSettings.ExType {
        switch(exState) {
            case STATE_INITIAL:
                return ExerciseSettings.TYPE_NONE;
            case STATE_WARMUP_RUN:
                return _settings.wuExType;
            case STATE_WARMUP_WALK:
                return _settings.wuReType;
            case STATE_EXERCISE_RUN:
                return _settings.ruExType;
            case STATE_EXERCISE_WALK:
                return _settings.ruReType;
            case STATE_COOLDOWN_RUN:
                return _settings.cdExType;
            case STATE_COOLDOWN_WALK:
                return _settings.cdReType;
            case STATE_EXTEND:
            default:
                return ExerciseSettings.TYPE_ANY;
        }
    }


    // function returns the current target (duration, distance or none)
    private function getCurrentTarget() as Number {
        switch(exState) {
            case STATE_INITIAL:
                return 0;
            case STATE_WARMUP_RUN:
                return _settings.wuExValue;
            case STATE_WARMUP_WALK:
                return _settings.wuReValue;
            case STATE_EXERCISE_RUN:
                return _settings.ruExValue;
            case STATE_EXERCISE_WALK:
                return _settings.ruReValue;
            case STATE_COOLDOWN_RUN:
                return _settings.cdExValue;
            case STATE_COOLDOWN_WALK:
                return _settings.cdReValue;
            case STATE_EXTEND:
            default:
                return 0;
        }
    }


    // function determines the next state based on settings
    private function setNextState() {
        var nextExState = exState;
        switch (exState) {
            case STATE_INITIAL:
                nextExState = STATE_WARMUP_RUN;
            case STATE_WARMUP_RUN:
                if (nextExState != exState) {
                    if (_settings.wuExType != ExerciseSettings.TYPE_NONE) {
                        break;
                    } else {
                        nextExState = STATE_WARMUP_WALK;
                    }
                } else {
                    nextExState = STATE_WARMUP_WALK;
                }
            case STATE_WARMUP_WALK:
                if (nextExState != exState) {
                    if (_settings.wuReType != ExerciseSettings.TYPE_NONE) {
                        break;
                    } else {
                        nextExState = STATE_EXERCISE_RUN;
                    }
                } else {
                    nextExState = STATE_EXERCISE_RUN;
                }
            case STATE_EXERCISE_RUN:
                if (nextExState != exState) {
                    if (_settings.ruExType != ExerciseSettings.TYPE_NONE) {
                        break;
                    } else {
                        nextExState = STATE_EXERCISE_WALK;
                    }
                } else {
                    nextExState = STATE_EXERCISE_WALK;
                }
            case STATE_EXERCISE_WALK:
                if (nextExState != exState) {
                    if (_settings.ruReType != ExerciseSettings.TYPE_NONE) {
                        break;
                    } else {
                        nextExState = STATE_COOLDOWN_RUN;
                    }
                } else {
                    nextExState = STATE_COOLDOWN_RUN;
                }
            case STATE_COOLDOWN_RUN:
                if (nextExState != exState) {
                    if (_settings.cdExType != ExerciseSettings.TYPE_NONE) {
                        break;
                    } else {
                        nextExState = STATE_COOLDOWN_WALK;
                    }
                } else {
                    nextExState = STATE_COOLDOWN_WALK;
                }
            case STATE_COOLDOWN_WALK:
                if (nextExState != exState) {
                    if (_settings.cdReType != ExerciseSettings.TYPE_NONE) {
                        break;
                    } else {
                        nextExState = STATE_EXTEND;
                    }
                } else {
                    nextExState = STATE_EXTEND;
                }
            case STATE_EXTEND:
            default:
        }
        exState = nextExState;
    }

    // updates the state
    private function updateState(testValue as Double) as Boolean {
        var curState = exState;
        var curExCount = exCount;

        switch (exState) {
            case STATE_INITIAL:
                break;
            case STATE_WARMUP_RUN:
                if (testValue >= _settings.wuExValue) {
                    lapTime = 0;
                    preciseLapDist = 0.0d;
                    setNextState();
                }
                break;
            case STATE_WARMUP_WALK:
                if (testValue >= _settings.wuReValue) {
                    lapTime = 0;
                    preciseLapDist = 0.0d;
                    setNextState();
                }
                break;
            case STATE_EXERCISE_RUN: 
                if (testValue >= _settings.ruExValue) {
                    lapTime = 0;
                    preciseLapDist = 0.0d;
                    if (_settings.ruReType != ExerciseSettings.TYPE_NONE) {
                            exState = STATE_EXERCISE_WALK;
                    } else {
                        exCount += 1;
                        if (exCount >= _settings.ruRepeats) {
                            setNextState();
                        }
                    }
                }
                break;
            case STATE_EXERCISE_WALK: 
                if (testValue >= _settings.ruReValue) {
                    lapTime = 0;
                    preciseLapDist = 0.0d;
                    exCount += 1;
                    if (exCount >= _settings.ruRepeats) {
                        setNextState();
                    } else {
                        if (_settings.ruExType != ExerciseSettings.TYPE_NONE) {
                            exState = STATE_EXERCISE_RUN;
                        }
                    }
                }
                break;
            case STATE_COOLDOWN_RUN: 
                if (testValue >= _settings.cdExValue) {
                    lapTime = 0;
                    preciseLapDist = 0.0d;
                    setNextState();
                }
                break;
            case STATE_COOLDOWN_WALK: 
                if (testValue >= _settings.cdReValue) {
                    lapTime = 0;
                    preciseLapDist = 0.0d;
                    setNextState();;
                }
                break;
            case STATE_EXTEND:
            default: 
        }

        // return state change
        return ((curState != exState) || (curExCount != exCount));

    }


    // function resets the remaining time and distance
    public function resetRemaining() as Void {
        if (getCurrentTargetType() == ExerciseSettings.TYPE_DURATION) {
            remTime = getCurrentTarget() - lapTime;
            remDist = 0.0;
        } else {
            remTime = 0;
            remDist = getCurrentTarget().toFloat() - lapDist;
        }
    }


    // function starts the activity
    public function startExercise() as Void {
        setNextState();
        resetRemaining();
    }


    // increments the total and exercise time with duration
    // duration is in seconds
    public function incrementTime(duration as Lang.Number) as Boolean {

        // update lap time and total duration
        totTime += duration;
        lapTime += duration;

        // test progress and update state
        var isStateChange = false;
        if (getCurrentTargetType() == ExerciseSettings.TYPE_DURATION) {
            isStateChange = updateState(lapTime.toDouble());
        }

        // update remaining time (only if type has not changed due to state change)
        if (getCurrentTargetType() == ExerciseSettings.TYPE_DURATION) {
            remTime = getCurrentTarget() - lapTime;
        } else {
            remTime = 0;
        }

        return isStateChange;
    }


    // updates the activity data
    public function updateActivity(info as Activity.Info) as Void {
        // update heart rate
        if (info.currentHeartRate != null) {
            heartRate = info.currentHeartRate;
        }
    }


    // function rounds down the double to the nearest multiple
    // and converts to a Float
    public function roundDown(value as Double, multiple as Number) as Float {
        var intDist = ((value*1000.0d).toLong());
        return ((intDist - (intDist%(1000l*multiple)))/1000l).toFloat();
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
                preciseLapDist += deltaDist;
                preciseTotDist += deltaDist;
            }
            prevLocation = gpsInfo.position;

            // test progress and update state
            var isStateChange = false;
            if (getCurrentTargetType() == ExerciseSettings.TYPE_DISTANCE) {
                isStateChange = updateState(preciseLapDist);
            }

            // update display distances
            lapDist = roundDown(preciseLapDist, 10);
            totDist = roundDown(preciseTotDist, 10);
            if (getCurrentTargetType() == ExerciseSettings.TYPE_DISTANCE) {
                remDist = getCurrentTarget() - lapDist;
            } else {
                remDist = 0.0;
            }

            return isStateChange; 
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