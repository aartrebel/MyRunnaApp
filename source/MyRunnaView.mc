import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Position;

class MyRunnaView extends WatchUi.View {

    enum DisplayMode {
        DISPLAY_TOTALS,
        DISPLAY_REMAINDER,
        DISPLAY_LAP
    }

    // sizing constants
    private const SCR_H_SIZE = 240;
    private const SCR_V_SIZE = 240;
    private const PACE_VAL_SIZE = 144;
    private const PACE_UNIT_SIZE = 45;
    private const DIST_VAL_SIZE = 144;
    private const DIST_UNIT_SIZE = 36;

    // display position constants
    private const TIME_H_POS = SCR_H_SIZE/2 + 10; // slight offset to right to make space for heartrate
    private const TIME_V_POS = SCR_V_SIZE/2;
    private const STATE_H_POS = SCR_H_SIZE/2;
    private const STATE_V_POS = SCR_V_SIZE/2-105;
    private const SUBSTATE_H_POS = SCR_H_SIZE/2;
    private const SUBSTATE_V_POS = SCR_V_SIZE/2+105;
    private const DIST_H_POS = (SCR_H_SIZE+DIST_VAL_SIZE-DIST_UNIT_SIZE)/2+20;
    private const DIST_V_POS = SCR_V_SIZE/2-60;
    private const DIST_UNIT_V_POS = DIST_V_POS+15;
    private const PACE_H_POS = (SCR_H_SIZE+PACE_VAL_SIZE-PACE_UNIT_SIZE)/2+15;
    private const PACE_V_POS = SCR_V_SIZE/2+60;
    private const PACE_UNIT_V_POS = PACE_V_POS-10;
    private const SPEED_H_POS = (SCR_H_SIZE+PACE_VAL_SIZE-PACE_UNIT_SIZE)/2+15;
    private const SPEED_V_POS = SCR_V_SIZE/2+60;
    private const SPEED_UNIT_V_POS = PACE_V_POS-10;
    private const HR_H_POS = (SCR_H_SIZE+PACE_VAL_SIZE-PACE_UNIT_SIZE)/2+5;
    private const HR_V_POS = SCR_V_SIZE/2+60;
    private const HR_UNIT_V_POS = PACE_V_POS-10;

    // Heartrate display constants
    private const HR_BAR_WIDTH = 11;
    private const HR_RADIUS_GAP = 2;
    private const HR_BAR_RADIUS = (SCR_H_SIZE - HR_BAR_WIDTH)/2 - HR_ZONE_BAR_WIDTH - HR_RADIUS_GAP;
    private const HR_ZONE_GAP = 1;
    private const HR_ZONE_BAR_WIDTH = 5;
    private const HR_ZONE_BAR_RADIUS = (SCR_H_SIZE - HR_ZONE_BAR_WIDTH)/2;
    private const HR_BAR_START = 240.0;
    private const HR_BAR_END = 120.0;
    private const HR_ZONE_COLORS = [Graphics.COLOR_WHITE, Graphics.COLOR_BLUE, Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, 
        Graphics.COLOR_RED];


    private var _status as ExerciseStatus?;
    private var _displayMode as DisplayMode = DISPLAY_REMAINDER;
    private var _isDisplaySpeed as Boolean = true;

    function initialize(status as ExerciseStatus) {
        View.initialize();
        _status = status;
    }


    // formats the time from seconds in H:MM:SS
    static public function formatTime(time as Number) as String {
        var hours = time/3600;
        var minutes = (time%3600)/60;
        var seconds = time%60;
        return  Lang.format("$1$:$2$:$3$", [hours.format("%1u"), minutes.format("%02u"), seconds.format("%02u")]);
    }


    // formats the pace from seconds to M:SS
    static public function formatPace(pace as Number) as String {
        var minutes = pace/60;
        var seconds = pace%60;
        return  Lang.format("$1$:$2$", [minutes, seconds.format("%02u")]);
    }


    // formats the speed from m/s to km/h
    static public function formatSpeed(speed as Float) as String {
        var kph = speed*3.6;
        return kph.format("%1.1f");
    }


    // formats the distance from meters in kilometers
    static public function formatDistance(meters as Double) as String {
        var kilometers = meters/1000.0;
        return kilometers.format("%1.2f");
    }


    // display formatted exercise state
    private function displayState(state as ExState, count as Number, target as Number, dc as Dc) as Void {
        var stateText;
        switch (state) {
            case WARMUP:
                stateText = "WARM";
                break;
            case EXERCISE:
                stateText = "EX " + count.format("%1u") + "/" + target.format("%1u");
                break;
            case COOLDOWN:
                stateText = "COOL";
                break;
            case EXTEND:
                stateText = "DONE";
                break;
            default:
                stateText = "???";
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(STATE_H_POS, STATE_V_POS, Graphics.FONT_MEDIUM, stateText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }


    // display formatted lapsed distance in km
    private function displayDistance(totDist as Double, finDist as Double, lapDist as Double, isPriority as Boolean, dc as Dc) as Void {
        if ((!isPriority) || (_displayMode == DISPLAY_TOTALS)) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.drawText(DIST_H_POS, DIST_V_POS, Graphics.FONT_NUMBER_HOT, formatDistance(totDist), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
                //dc.drawText(DIST_H_POS, DIST_V_POS, Graphics.FONT_NUMBER_HOT, "10.00", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        else {
            if (_displayMode == DISPLAY_LAP) {
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
                dc.drawText(DIST_H_POS, DIST_V_POS, Graphics.FONT_NUMBER_HOT, formatDistance(lapDist), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
            }
            else {
                _displayMode = DISPLAY_REMAINDER;
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
                dc.drawText(DIST_H_POS, DIST_V_POS, Graphics.FONT_NUMBER_HOT, formatDistance(finDist-lapDist), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }
        dc.drawText(DIST_H_POS, DIST_UNIT_V_POS, Graphics.FONT_TINY, "km", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }


    // display formatted lapsed time
    private function displayTime(totTime as Number, finTime as Number, lapTime as Number, isPriority as Boolean, dc as Dc) as Void {
        if ((!isPriority) || (_displayMode == DISPLAY_TOTALS)) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.drawText(TIME_H_POS, TIME_V_POS, Graphics.FONT_NUMBER_HOT, formatTime(totTime), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        else {
            if (_displayMode == DISPLAY_LAP) {
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
                dc.drawText(TIME_H_POS, TIME_V_POS, Graphics.FONT_NUMBER_HOT, formatTime(lapTime), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
            else {
                _displayMode = DISPLAY_REMAINDER;
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
                dc.drawText(TIME_H_POS, TIME_V_POS, Graphics.FONT_NUMBER_HOT, formatTime(finTime-lapTime), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }
        dc.drawText(DIST_H_POS, DIST_UNIT_V_POS, Graphics.FONT_TINY, "km", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }


    // display formatted pace in min/km
    //private function displayPace(speed as Float, dc as Dc) {
    //    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    //    
    //    if (speed > (1.0/6.0)) {
    //        var pace = 1000.0/speed;
    //        dc.drawText(PACE_H_POS, PACE_V_POS, Graphics.FONT_NUMBER_HOT, formatPace(pace.toNumber()), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    //    }
    //    else {
    //        dc.drawText(PACE_H_POS, PACE_V_POS, Graphics.FONT_NUMBER_HOT, "99:59", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    //    }
    //    dc.drawText(PACE_H_POS, PACE_UNIT_V_POS, Graphics.FONT_TINY, "kph", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    //}


    // display formatted heartrate in bpm
    private function displayHeartRate(heartRate as Number, dc as Dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        
        dc.drawText(HR_H_POS, HR_V_POS, Graphics.FONT_NUMBER_HOT, heartRate.format("%1u"), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(HR_H_POS, HR_UNIT_V_POS, Graphics.FONT_TINY, "bpm", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }


    // display formatted speed in km/h
    private function displaySpeed(speed as Float, dc as Dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        
        dc.drawText(SPEED_H_POS, SPEED_V_POS, Graphics.FONT_NUMBER_HOT, formatSpeed(speed), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        //dc.drawText(SPEED_H_POS, SPEED_V_POS, Graphics.FONT_NUMBER_HOT, "15.0", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(SPEED_H_POS, SPEED_UNIT_V_POS, Graphics.FONT_TINY, "kph", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }


    // display substate (RUN, WALK or PAUSE)
    private function displaySubState(isRun as Boolean, isPaused as Boolean, gpsAccuracy as Position.Quality,  dc as Dc) {
        var subStateText;
        if (isPaused) {
            if (gpsAccuracy >= Position.QUALITY_POOR) {
                subStateText = "PSE";
            }
            else {
                subStateText = "GPS";
            }
        }
        else {
            if (isRun) {
                subStateText = "RUN";
            }
            else {
                subStateText = "WALK";
            }
        }
        switch (gpsAccuracy) {
            case Position.QUALITY_GOOD:
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                break;
            case Position.QUALITY_USABLE:
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
                break;
            case Position.QUALITY_POOR:
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
                break;
            default:
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        }
        dc.drawText(SUBSTATE_H_POS, SUBSTATE_V_POS, Graphics.FONT_MEDIUM, subStateText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }


    // function displays a bar representing the current heart rate
    // it is divided in the different heart rate zones
    // the length of bar represents to heart rate from Zone 1 min to max heart rate
    private function graphHeartRate(heartRate as Number, heartRateZones as Array<Number>, dc as Dc) as Void {
        // determine heartrate zone
        var zone = 5;
        var found = false;
        do {
            found = (heartRate > heartRateZones[zone-1]);
            if (!found) {
                zone -= 1;
            }
        } while ((zone > 0) && !found);

        // draw heartrate zone bar
        dc.setPenWidth(HR_ZONE_BAR_WIDTH);
        var angleFactor = (HR_BAR_END - HR_BAR_START)/(heartRateZones[5]-heartRateZones[0]);
        var startAngle = HR_BAR_START;
        for (var n=0; n<5; n++) {
            var endAngle = HR_BAR_START + (heartRateZones[n+1]-heartRateZones[0])*angleFactor + HR_ZONE_GAP;
            dc.setColor(HR_ZONE_COLORS[n], Graphics.COLOR_BLACK);
            dc.drawArc(SCR_H_SIZE/2, SCR_V_SIZE/2, HR_ZONE_BAR_RADIUS, Graphics.ARC_CLOCKWISE, startAngle.toNumber(), endAngle.toNumber());
            startAngle = endAngle - 2*HR_ZONE_GAP;
        }

        // draw heartrate bar
        if (heartRate > heartRateZones[0]) {
            dc.setPenWidth(HR_BAR_WIDTH);
            if (heartRate < heartRateZones[5]) {
                var hrAngle = HR_BAR_START + (heartRate-heartRateZones[0])*angleFactor;
                dc.setColor(HR_ZONE_COLORS[zone-1], Graphics.COLOR_BLACK);
                dc.drawArc(SCR_H_SIZE/2, SCR_V_SIZE/2, HR_BAR_RADIUS, Graphics.ARC_CLOCKWISE, HR_BAR_START, hrAngle.toNumber());
            } else {
                dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_BLACK);
                dc.drawArc(SCR_H_SIZE/2, SCR_V_SIZE/2, HR_BAR_RADIUS, Graphics.ARC_CLOCKWISE, HR_BAR_START, HR_BAR_END);
            }
        }
    } 


    // changes the display mode to the next
    public function nextDisplayMode() as Void {
        switch (_displayMode) {
            case DISPLAY_TOTALS:
                _displayMode = DISPLAY_REMAINDER;
                break;
            case DISPLAY_REMAINDER:
                _displayMode = DISPLAY_LAP;
                break;
            case DISPLAY_LAP:
            default:
                _displayMode = DISPLAY_TOTALS;
        }
    }
    

    // changes the display mode to the previous
    //public function previousDisplayMode() as Void {
    //    switch (_displayMode) {
    //        case DISPLAY_LAP:
    //            _displayMode = DISPLAY_TOTALS;
    //            break;
    //        case DISPLAY_REMAINDER:
    //            _displayMode = DISPLAY_LAP;
    //            break;
    //        case DISPLAY_TOTALS:
    //        default:
    //            _displayMode = DISPLAY_REMAINDER;
    //    }
    //}


    // toggles the display between pace and heartrate
    public function toggleSpeedOrHR () as Void {
        _isDisplaySpeed = !_isDisplaySpeed;
    }
    

    // creates initial layout of the screen
    function onLayout(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }


    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }


    // Update the view
    function onUpdate(dc as Dc) as Void {
        // clear screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (_isDisplaySpeed) {
            displaySpeed(_status.speed, dc);
        } else {
            displayHeartRate(_status.heartRate, dc);
        }
        displayTime(_status.totTime, _status.finish, _status.lapTime, _status.isPriority(DURATION), dc);
        displayDistance(_status.totDist, _status.finish.toDouble(), _status.lapDist, _status.isPriority(DISTANCE), dc);
        displayState(_status.exState, _status.exCount+1, _status.ruRepeats, dc);
        displaySubState(_status.isRun, _status.isPaused, _status.gpsAccuracy, dc);
        graphHeartRate(_status.heartRate, _status.heartRateZones, dc);
    }


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
