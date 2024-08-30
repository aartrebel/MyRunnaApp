import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;
import Toybox.Lang;

class ExerciseInputView extends ValueInputView {

    static public const NONE_TITLE = "NONE";
    static public const DIST_TITLE = "Distance";
    static public const DIST_UNIT = "m";
    static private const DIST_MAX = 99999;
    static public const DUR_TITLE = "Duration";
    static public const DUR_UNIT = "s";
    static private const DUR_MAX = 60*60*10;
    //const SCR_SIZE = 240;
    //const FONT_WIDTH = 30;
    //const FONT_HEIGHT = 43;
    //const DIGITS  =  ["7", "6", "5", "4", "3", "2", "1", "0", "9", "8"];
    private const TITLE_FONT = Graphics.FONT_SMALL;
    //const EMPTY_ENTRY = " _ _ _ _ _ _ _ _ _ _ ";
    //const NIL_ERROR = "VALUE";
    //const MAX_ERROR = "> MAX";
    //const NO_ERROR = "             ";

    //private var _coords as Lang.Array?;
    //private var _delegate as ExerciseInputDelegate?;
    //private var _unit as String?;
    //private var _max as Number?;
    //private var _entry as String = "";
    //private var _entryXPos as Number = 0;
    private var _titleYPos as Number = 0;
    //private var _error as String = NO_ERROR;
    //private var _innerRadius as Float = 0.0;
    //private var _indexOf0 as Number = 0;

    private var _currentExType as ExType?;
    private var _currentTitle as String?;


    function initialize(currentExType as ExType, delegate as ExerciseInputDelegate) {
        _currentExType = currentExType;

        switch (_currentExType) {
            case DURATION:
                _currentTitle = DUR_TITLE;
                ValueInputView.initialize(ValueInputView.INPUT_TIME, DUR_TITLE, DUR_UNIT, DUR_MAX, method(:onDone), delegate);
                break;
            case DISTANCE:
                _currentTitle = DIST_TITLE;
                ValueInputView.initialize(ValueInputView.INPUT_NUMBER, DIST_TITLE, DIST_UNIT, DIST_MAX, method(:onDone), delegate);
                break;
            case NONE:
            default:
                _currentTitle = NONE_TITLE;
                _currentExType = NONE;
                //ValueInputView.initialize(null, null, null, delegate);
        }

        _titleYPos = (SCR_SIZE - innerRadius.toNumber())/2; 
    }


    // function changes the input mode to the next
    public function onNextPage() as Void {
        switch (_currentExType) {
            case DURATION:
                _currentExType = DISTANCE;
                ValueInputView.updateParams(ValueInputView.INPUT_TIME, DIST_TITLE, DIST_UNIT, DIST_MAX);
                break;
            case DISTANCE:
                _currentExType = NONE;
                //ValueInputView.updateParams(null, null, null);
                break;
            case NONE:
            default:
                _currentExType = DURATION;
                ValueInputView.updateParams(ValueInputView.INPUT_NUMBER, DUR_TITLE, DUR_UNIT, DUR_MAX);
        }
    }


    // function changes the input mode to the previous
    public function onPreviousPage() as Void {
        switch (_currentExType) {
            case DURATION:
                _currentExType = NONE;
                //ValueInputView.updateParams(null, null, null);
                break;
            case DISTANCE:
                _currentExType = DURATION;
                ValueInputView.updateParams(ValueInputView.INPUT_TIME, DUR_TITLE, DUR_UNIT, DUR_MAX);
                break;
            case NONE:
            default:
                _currentExType = DISTANCE;
                ValueInputView.updateParams(ValueInputView.INPUT_NUMBER, DIST_TITLE, DIST_UNIT, DIST_MAX);
        }
    }

    // function that is called when done
    public function onDone (result as Number) as Void {
        System.println("Result = " + result);
    } 


    // Load your resources here
    function onLayout(dc as Dc) as Void {

        // clear display
        //dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        //dc.clear();

        // place digits
        //for (var n=0; n<10; n++) {
        //    var coord = _coords[n] as Array<Number>;
            // initially "0" is invalid
        //    if (DIGITS[n].equals("0")) {
        //        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_WHITE);
        //        _indexOf0 = n;
        //    } else {
        //        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        //    }
        //    dc.drawText(coord[0]+SCR_SIZE/2, coord[1]+SCR_SIZE/2, Graphics.FONT_SYSTEM_NUMBER_HOT, DIGITS[n], 
        //        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        //}

        // draw seperation circle
        //_innerRadius = SCR_SIZE/2 - Math.sqrt(FONT_WIDTH*FONT_WIDTH + FONT_HEIGHT*FONT_HEIGHT);
        //dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        //dc.setPenWidth(2);
        //dc.drawCircle(SCR_SIZE/2, SCR_SIZE/2, _innerRadius-1);

        // draw seperation lines
        //var outerRadius = SCR_SIZE/2;
        //for (var n = 0; n < 10; n++) {
        //    var angle = (36*n)-90;
        //    var xi = _innerRadius * Math.sin(Math.toRadians(angle)) + SCR_SIZE/2;
        //    var yi = _innerRadius * Math.cos(Math.toRadians(angle)) + SCR_SIZE/2;
        //    var xo = (outerRadius+1) * Math.sin(Math.toRadians(angle)) + SCR_SIZE/2;
        //    var yo = (outerRadius+1) * Math.cos(Math.toRadians(angle)) + SCR_SIZE/2;
        //    if ((n==0) || (n==5)) {
        //        yo = yi;
        //    }
        //    dc.drawLine(xi, yi, xo, yo);
        //}

        switch (_currentExType) {
            case DURATION:
                ValueInputView.onLayout(dc);
                break;
            case DISTANCE:
                ValueInputView.onLayout(dc);
                break;
            case NONE:
            default: {
                
            }
        }

        // calculate the position of the title text
        //_entryXPos = (SCR_SIZE + dc.getTextWidthInPixels(_max.toString() + _unit, ENTRY_FONT))/2;
        //SCR_SIZE/2 - (innerRadius/3)


    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {

        ValueInputView.onShow();

    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // replace "0" digit
        //var coord = _coords[_indexOf0] as Array<Number>;
        //if (_entry.length()==0) {
        //    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_WHITE);
        //} else {
        //    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        //}
        //dc.drawText(coord[0]+SCR_SIZE/2, coord[1]+SCR_SIZE/2, Graphics.FONT_SYSTEM_NUMBER_HOT, DIGITS[_indexOf0], 
        //    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // redraw seperation circle
        //dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        //dc.setPenWidth(2);
        //dc.drawCircle(SCR_SIZE/2, SCR_SIZE/2, _innerRadius-1);

        // display entry value
        //var displayText = EMPTY_ENTRY.substring(0, (_max.toString().length() - _entry.length())*2) + _entry;
        //dc.drawText(_entryXPos, SCR_SIZE/2, ENTRY_FONT, displayText + _unit, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        ValueInputView.onUpdate(dc);

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        ValueInputView.onHide();
    }

}
