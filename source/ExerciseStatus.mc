import Toybox.System;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Math;
import Toybox.UserProfile;
//import Toybox.Sensor;
import Toybox.Activity;

public enum ExState {
    WARMUP = 1,
    EXERCISE = 2,
    COOLDOWN = 3,
    EXTEND = 4
}

public enum ExSubState {
    RUN = 1,
    WALK = 2
}

public enum ExType {
    NONE = 0,
    DURATION = 1,
    DISTANCE = 2
}

class ExerciseStatus {
    // settings variables
    public var wuExType as ExType = NONE;
    public var wuExValue as Lang.Number = 0;
    public var wuReType as ExType = NONE;
    public var wuReValue as Lang.Number = 0;

    public var ruExType as ExType = NONE;
    public var ruExValue as Lang.Number = 0;
    public var ruReType as ExType = NONE;
    public var ruReValue as Lang.Number = 0;
    public var ruRepeats as Lang.Number = 0;

    public var cdExType as ExType = NONE;
    public var cdExValue as Lang.Number = 0;
    public var cdReType as ExType = NONE;
    public var cdReValue as Lang.Number = 0;
    
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

    public var exState as ExState = WARMUP;
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


    public function initialize() {
        _filter = new FIRFilter(FIR_AVERAGE_OFF_10_FILTER);
        heartRateZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_RUNNING);
    }


    public function presetSettings() {
        // initialise settings for debugging only - should be set vir Garmin Connect
        Properties.setValue("wuExType",NONE);
        Properties.setValue("wuExValue",0);
        Properties.setValue("wuReType",DURATION);
        Properties.setValue("wuReValue",300);

        Properties.setValue("ruExType",DURATION);
        Properties.setValue("ruExValue",240);
        Properties.setValue("ruReType",DURATION);
        Properties.setValue("ruReValue",60);
        Properties.setValue("ruRepeats",5);

        Properties.setValue("cdExType",NONE);
        Properties.setValue("cdExValue",0);
        Properties.setValue("cdReType",DURATION);
        Properties.setValue("cdReValue",300);

        System.println("Setting preset");
    }


    public function loadSettings() as Boolean {
       // load settings from Properties
        wuExType = Properties.getValue("wuExType") as ExType;
        wuExValue = Properties.getValue("wuExValue");
        wuReType = Properties.getValue("wuReType") as ExType;
        wuReValue = Properties.getValue("wuReValue");

        ruExType = Properties.getValue("ruExType") as ExType;
        ruExValue = Properties.getValue("ruExValue");
        ruReType = Properties.getValue("ruReType") as ExType;
        ruReValue = Properties.getValue("ruReValue");
        ruRepeats = Properties.getValue("ruRepeats");

        cdExType = Properties.getValue("cdExType") as ExType;
        cdExValue = Properties.getValue("cdExValue");
        cdReType = Properties.getValue("cdReType") as ExType;
        cdReValue = Properties.getValue("cdReValue");

        // check settings
        var isSettingsError =   ((wuExType == NONE) && (wuReType == NONE)) ||
                        ((ruExType == NONE) && (ruReType == NONE)) ||
                        ((cdExType == NONE) && (cdReType == NONE)) ||
                        ((wuExType != NONE) && (wuExValue == 0)) ||
                        ((wuReType != NONE) && (wuReValue == 0)) ||
                        ((ruExType != NONE) && (ruExValue == 0)) ||
                        ((ruReType != NONE) && (ruReValue == 0)) ||
                        ((cdExType != NONE) && (cdExValue == 0)) ||
                        ((cdReType != NONE) && (cdReValue == 0)) ||
                        (wuExValue < 0) ||
                        (wuReValue < 0) ||
                        (ruExValue < 0) ||
                        (ruReValue < 0) ||
                        (cdExValue < 0) ||
                        (cdReValue < 0) ||
                        (ruRepeats <= 0);
        if (isSettingsError) {
            return false;
        }
        else {
            // Start at run or rest for warmup
            if (wuExType != NONE) {
                finish = wuExValue;
                isRun = true;
            }
            else {
                finish = wuReValue;
                isRun = false;
            }
            return true;
        }
     
    }


    public function printStatus(caller as Lang.String) as Void {
        System.println ("Status[" + caller +"]: state=" + exState + ", run=" + isRun + ", count=" + exCount + ", pause=" + isPaused + 
            ", totT=" + MyRunnaView.formatTime(totTime) + ", lapT=" + MyRunnaView.formatTime(lapTime) +
            ", totD=" + totDist.format("%1.0f") + ", lapD=" + lapDist.format("%1.0f") + ", speed=" + speed.format("%1.2f") +
            ", gps=" + gpsAccuracy);
    }


    // test if distance or duration is a priority
    public function isPriority(exType as ExType) as Boolean {
        switch (exState) {
            case WARMUP:
                if (isRun) {
                    return (wuExType == exType);
                }
                else {
                    return (wuReType == exType);
                }
            case EXERCISE:
                if (isRun) {
                    return (ruExType == exType);
                }
                else {
                    return (ruReType == exType);
                }
            case COOLDOWN:
                if (isRun) {
                    return (cdExType == exType);
                }
                else {
                    return (cdReType == exType);
                }
            case EXTEND:
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
    private function updateState(testValue as Double, testType as ExType) as Boolean {
        var curState = exState;
        var curSubstate = isRun;
        var curExCount = exCount;

        switch (exState) {
            case WARMUP:
                if (isRun) {
                    if ((testValue >= wuExValue) && (wuExType == testType)) {
                        lapTime = 0;
                        lapDist = 0.0d;
                        if (wuReType != NONE) {
                            isRun = false;
                            finish = wuReValue;
                        }
                        else {
                            exState = EXERCISE;
                            if (ruExType != NONE) {
                                finish = ruExValue;
                            }
                            else {
                                isRun = false;
                                finish = ruReValue;
                            }
                        }
                    }
                }
                else {
                    if ((testValue >= wuReValue) && (wuReType == testType)) {
                        lapTime = 0;
                        lapDist = 0.0d;
                        exState = EXERCISE;
                        if (ruExType != NONE) {
                            isRun = true;
                            finish = ruExValue;
                        }
                        else {
                            finish = ruReValue;
                        }
                    }
                }
                break;
            case EXERCISE: 
                if (isRun) {
                    if ((testValue >= ruExValue) && (ruExType == testType)) {
                        lapTime = 0;
                        lapDist = 0.0d;
                        if (ruReType != NONE) {
                            isRun = false;
                            finish = ruReValue;
                        }
                        else {
                            exCount += 1;
                            if (exCount == ruRepeats) {
                                exState = COOLDOWN;
                                if (cdExType != NONE) {
                                    finish = cdExValue;
                                }
                                else {
                                    isRun = false;
                                    finish = cdReValue;
                                }
                            }
                        }
                    }
                }
                else {
                    if ((testValue >= ruReValue) && (ruReType == testType)) {
                        lapTime = 0;
                        lapDist = 0.0d;
                        exCount += 1;
                        if (exCount == ruRepeats) {
                            exState = COOLDOWN;
                            if (cdExType != NONE) {
                                isRun = true;
                                finish = cdExValue;
                            }
                            else {
                                finish = cdReValue;
                            }
                        }
                        else {
                            if (ruExType != NONE) {
                                isRun = true;
                                finish = ruExValue;
                            }
                            else {
                                finish = ruReValue;
                            }
                        }
                    }
                }
                break;
            case COOLDOWN: 
                if (isRun) {
                    if ((testValue >= cdExValue) && (cdExType == testType)) {
                        lapTime = 0;
                        lapDist = 0.0d;
                        isRun = false;
                        if (cdReType != NONE) {
                            finish = cdReValue;
                        }
                        else {
                            exState = EXTEND;
                            finish = 0;
                        }
                    }
                }
                else {
                    if ((testValue >= cdReValue) && (cdReType == testType)) {
                        lapTime = 0;
                        lapDist = 0.0d;
                        finish = 0;
                        exState = EXTEND;
                    }
                }
                break;
            case EXTEND:
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
        return updateState(lapTime.toDouble(), DURATION);
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
            return updateState(lapDist, DISTANCE);
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