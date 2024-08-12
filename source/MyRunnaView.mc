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

    private const SCR_H_SIZE = 240;
    private const SCR_V_SIZE = 240;
    private const PACE_VAL_SIZE = 144;
    private const PACE_UNIT_SIZE = 45;
    private const DIST_VAL_SIZE = 144;
    private const DIST_UNIT_SIZE = 36;
    private const TIME_H_POS = SCR_H_SIZE/2;
    private const TIME_V_POS = SCR_V_SIZE/2;
    private const STATE_H_POS = SCR_H_SIZE/2;
    private const STATE_V_POS = SCR_V_SIZE/2-105;
    private const SUBSTATE_H_POS = SCR_H_SIZE/2;
    private const SUBSTATE_V_POS = SCR_V_SIZE/2+105;
    private const DIST_H_POS = (SCR_H_SIZE+DIST_VAL_SIZE-DIST_UNIT_SIZE)/2+10;
    private const DIST_V_POS = SCR_V_SIZE/2-60;
    private const DIST_UNIT_V_POS = DIST_V_POS+15;
    private const PACE_H_POS = (SCR_H_SIZE+PACE_VAL_SIZE-PACE_UNIT_SIZE)/2+10;
    private const PACE_V_POS = SCR_V_SIZE/2+60;
    private const PACE_UNIT_V_POS = PACE_V_POS-10;

    private var _status as ExerciseStatus?;
    private var _displayMode as DisplayMode = DISPLAY_REMAINDER;

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
    private function displayState(state as ExState, count as Number, dc as Dc) as Void {
        var stateText;
        switch (state) {
            case WARMUP:
                stateText = "WARM";
                break;
            case EXERCISE:
                stateText = "EX" + count.format("%2u");
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
    private function displayPace(speed as Float, dc as Dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        
        if (speed > (1.0/6.0)) {
            var pace = 1000.0/speed;
            dc.drawText(PACE_H_POS, PACE_V_POS, Graphics.FONT_NUMBER_HOT, formatPace(pace.toNumber()), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        else {
            dc.drawText(PACE_H_POS, PACE_V_POS, Graphics.FONT_NUMBER_HOT, "99:59", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        dc.drawText(PACE_H_POS, PACE_UNIT_V_POS, Graphics.FONT_TINY, "kph", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }


    // display formatted speed in km/h
    private function displaySpeed(speed as Float, dc as Dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        
        var scaledSpeed = speed*3.6;
        dc.drawText(PACE_H_POS, PACE_V_POS, Graphics.FONT_NUMBER_HOT, formatSpeed(speed), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(PACE_H_POS, PACE_UNIT_V_POS, Graphics.FONT_TINY, "kph", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
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


    // changes the display mode to the next
    public function nextDisplayMode() as Void {
        switch (_displayMode) {
            case DISPLAY_TOTALS:
                _displayMode = DISPLAY_LAP;
                break;
            case DISPLAY_REMAINDER:
                _displayMode = DISPLAY_TOTALS;
                break;
            case DISPLAY_LAP:
            default:
                _displayMode = DISPLAY_REMAINDER;
        }
    }
    

    // changes the display mode to the previous
    public function previousDisplayMode() as Void {
        switch (_displayMode) {
            case DISPLAY_LAP:
                _displayMode = DISPLAY_TOTALS;
                break;
            case DISPLAY_REMAINDER:
                _displayMode = DISPLAY_LAP;
                break;
            case DISPLAY_TOTALS:
            default:
                _displayMode = DISPLAY_REMAINDER;
        }
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

        displaySpeed(_status.speed, dc);
        displayTime(_status.totTime, _status.finish, _status.lapTime, _status.isPriority(DURATION), dc);
        displayDistance(_status.totDist, _status.finish.toDouble(), _status.lapDist, _status.isPriority(DISTANCE), dc);
        displayState(_status.exState, _status.exCount+1, dc);
        displaySubState(_status.isRun, _status.isPaused, _status.gpsAccuracy, dc);
    }


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
