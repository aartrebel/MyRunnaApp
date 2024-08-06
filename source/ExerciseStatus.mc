import Toybox.System;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Position;

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
    public var totDist as Lang.Number = 0;
    public var lapTime as Lang.Number = 0;
    public var lapDist as Lang.Number = 0;
    public var pace as Lang.Number = 0;

    public var exState as ExState = WARMUP;
    public var isRun as Lang.Boolean = true;
    public var isPaused as Lang.Boolean = true;

    public var exCount as Lang.Number = 0;

    public function initialise() {
    }


    public function presetSettings() {
        // initialise settings for debugging only - should be set vir Garmin Connect
        Properties.setValue("wuExType",DURATION);
        Properties.setValue("wuExValue",20);
        Properties.setValue("wuReType",DISTANCE);
        Properties.setValue("wuReValue",10);

        Properties.setValue("ruExType",DURATION);
        Properties.setValue("ruExValue",21);
        Properties.setValue("ruReType",DURATION);
        Properties.setValue("ruReValue",11);
        Properties.setValue("ruRepeats",2);

        Properties.setValue("cdExType",DURATION);
        Properties.setValue("cdExValue",22);
        Properties.setValue("cdReType",DURATION);
        Properties.setValue("cdReValue",12);

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
            isRun = (wuExType != NONE);
            return true;
        }
     
    }


    public function printStatus() as Void {
        System.println ("Status: state=" + exState + ", run=" + isRun + ", count=" + exCount + ", pause=" + isPaused + 
            ", totT=" + MyRunnaView.formatTime(totTime) + ", lapT=" + MyRunnaView.formatTime(lapTime));
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


    // increments the total and exercise time with duration
    // duration is in seconds
    public function incrementTime(duration as Lang.Number) {
        if (!isPaused) {
            totTime += duration;
            lapTime += duration;
            switch (exState) {
                case WARMUP:
                    if (isRun) {
                        if ((lapTime >= wuExValue) && (wuExType == DURATION)) {
                            lapTime = 0;
                            if (wuReType != NONE) {
                                isRun = false;
                            }
                            else {
                                exState = EXERCISE;
                            }
                        }
                    }
                    else {
                        if ((lapTime >= wuReValue) && (wuReType == DURATION)) {
                            lapTime = 0;
                            exState = EXERCISE;
                            isRun = (ruExType != NONE);
                        }
                    }
                    break;
                case EXERCISE: 
                    if (isRun) {
                        if ((lapTime >= ruExValue) && (ruExType == DURATION)) {
                            lapTime = 0;
                            if (ruReType != NONE) {
                                isRun = false;
                            }
                            else {
                                exCount += 1;
                                if (exCount == ruRepeats) {
                                    exState = COOLDOWN;
                                }
                            }
                        }
                    }
                    else {
                        if ((lapTime >= ruReValue) && (ruReType == DURATION)) {
                            lapTime = 0;
                            exCount += 1;
                            if (exCount == ruRepeats) {
                                exState = COOLDOWN;
                                isRun = (cdExType != NONE);
                            }
                            else {
                                isRun = (ruExType != NONE);
                            }
                        }
                    }
                    break;
                case COOLDOWN: 
                    if (isRun) {
                        if ((lapTime >= cdExValue) && (cdExType == DURATION)) {
                            lapTime = 0;
                            isRun = false;
                            if (cdReType == NONE) {
                                exState = EXTEND;
                            }
                        }
                    }
                    else {
                        if ((lapTime >= cdReValue) && (cdReType == DURATION)) {
                            lapTime = 0;
                            exState = EXTEND;
                        }
                    }
                    break;
                case EXTEND:
                default: 
            }
        }
    }


    // updates the distance and pace based on an updated coordinate
    public function updatePosition(position as Position.Info) {

    }


    // starts or pauses the exercise
    public function startPauseExercise() {
        isPaused = !isPaused;
    }


}