import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class MyRunnaView extends WatchUi.View {

    private var _status as ExerciseStatus?;

    function initialize() {
        View.initialize();
    }


    // formats the time from seconds in H:MM:SS
    static public function formatTime(time as Number) as String {
        var hours = time/3600;
        var minutes = (time%3600)/60;
        var seconds = (time%3600)%60;
        return  Lang.format("$1$:$2$:$3$", [hours.format("%1u"), minutes.format("%02u"), seconds.format("%02u")]);
    }


    // formats the pace from seconds to M:SS
    static public function formatPace(pace as Number) as String {
        var minutes = (pace%3600)/60;
        var seconds = (pace%3600)%60;
        return  Lang.format("$1$:$2$", [minutes, seconds.format("%02u")]);
    }


    // formats the distance from meters in kilometers
    static public function formatDistance(meters as Number) as String {
        var kilometers = meters/1000.0;
        return kilometers.format("%1.2f");
    }


    // sets the exercise status reference
    public function setExerciseStatus(status as ExerciseStatus) as Void {
        _status = status;
    }


    // Callback for timer
    public function callback() as Void {
        WatchUi.requestUpdate();
    }


    // display formatted exercise state
    private function displayState(state as ExState, count as Number, dc as Dc) as Void {
        var stateText;
        switch (state) {
            case WARMUP:
                stateText = " WARM ";
                break;
            case EXERCISE:
                stateText = "   EX" + count.format("%2u") + "   ";
                break;
            case COOLDOWN:
                stateText = " COOL ";
                break;
            case EXTEND:
                stateText = " DONE ";
                break;
            default:
                stateText = "  ???  ";
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(120, 120-105, Graphics.FONT_MEDIUM, stateText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // display formatted lapsed time
    private function displayTime(time as Number, dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(120, 120, Graphics.FONT_NUMBER_HOT, formatTime(time), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // display substate (RUN, WALK or PAUSE)
    private function displaySubState(isRun as Boolean, isPaused as Boolean, dc as Dc) {
        var subStateText;
        if (isPaused) {
            subStateText = " STOP ";
        }
        else {
            if (isRun) {
                subStateText = "  RUN  ";
            }
            else {
                subStateText = " WALK ";
            }
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(120, 120+105, Graphics.FONT_MEDIUM, subStateText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }


    // creates initial layout of the screen
    function onLayout(dc as Dc) as Void {
        //System.println("Width = " + dc.getWidth()); //240
        //System.println("height = " + dc.getHeight()); //240

        //var distUnit = "km";
        //var distUnitSize = dc.getTextDimensions(distUnit, Graphics.FONT_MEDIUM);
        //var timeText = "0:00:00";
        //var timeTextSize = dc.getTextDimensions(timeText, Graphics.FONT_NUMBER_HOT);
        //var paceUnit = "/km";
        //var paceUnitSize = dc.getTextDimensions(paceUnit, Graphics.FONT_MEDIUM);
        //var paceText = "00:00";
        //var paceTextSize = dc.getTextDimensions(paceText, Graphics.FONT_NUMBER_HOT);
        //var distText = "0.00";
        //var distTextSize = dc.getTextDimensions(distText, Graphics.FONT_NUMBER_HOT);

        //System.println("Time text size =" + timeTextSize[0] + ";" + timeTextSize[1]); //192;76
        //System.println("Pace text size =" + paceTextSize[0] + ";" + paceTextSize[1]); //144;76
        //System.println("Pace unit text size =" + paceUnitSize[0] + ";" + paceUnitSize[1]); //51;34
        //System.println("Dist text size =" + distTextSize[0] + ";" + distTextSize[1]); //112;76
        //System.println("Dist unit text size =" + distUnitSize[0] + ";" + distUnitSize[1]); //41;34
        
        // clear screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // set colour for text 
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // display exercise state
        //var timeText = "0:00:00";
        var paceText = "00:00";
        var distText = "0.00";
        dc.drawText(120, 120+60, Graphics.FONT_NUMBER_HOT, paceText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        //dc.drawText(120, 120, Graphics.FONT_NUMBER_HOT, timeText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(120, 120-60, Graphics.FONT_NUMBER_HOT, distText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawText(120+(144/2), 120+60, Graphics.FONT_MEDIUM, " P", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(120+(192/2), 120, Graphics.FONT_MEDIUM, " T", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(120+(112/2), 120-60, Graphics.FONT_MEDIUM, " D", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(120-(192/2), 120, Graphics.FONT_MEDIUM, "> ", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(120-(112/2), 120-60, Graphics.FONT_MEDIUM, "> ", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        //var stageText = "EX 1";
        //dc.drawText(120, 120-105, Graphics.FONT_MEDIUM, stageText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        //var gpsInd = "WALK";
        //dc.drawText(120, 120+105, Graphics.FONT_MEDIUM, gpsInd, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
 
        displayState(_status.exState, _status.exCount+1, dc);
        displayTime(_status.lapTime, dc);
        displaySubState(_status.isRun, _status.isPaused, dc);
    }


    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }


    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        //View.onUpdate(dc);

        displayState(_status.exState, _status.exCount+1, dc);
        displayTime(_status.lapTime, dc);
        displaySubState(_status.isRun, _status.isPaused, dc);
    }


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
