import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;
import Toybox.Lang;
import Toybox.Time;

class ValueInputView extends WatchUi.View {

    public enum InputType {
        INPUT_NUMBER,
        INPUT_DECIMAL,
        INPUT_TIME
    }

    const SCR_SIZE = 240;
    const FONT_WIDTH = 30;
    const FONT_HEIGHT = 43;
    const DIGIT_FONT = Graphics.FONT_NUMBER_MEDIUM;
    const DIGITS  =  ["7", "6", "5", "4", "3", "2", "1", "0", "9", "8"];
    public static const ENTRY_FONT = Graphics.FONT_LARGE;
    const EMPTY_ENTRY = " _ _ _ _ _ _ _ _ _ _ ";
    const NIL_ERROR = "VALUE";
    const MAX_ERROR = "> MAX";
    public static const TITLE_FONT = Graphics.FONT_XTINY;


    private var _coords as Lang.Array?;
    private var _delegate as ValueInputDelegate?;
    private var _unit as String?;
    private var _max as Number?;
    private var _entryType as InputType = INPUT_TIME;
    private var _title as String?;
    private var _onDoneHandler as Method?;

    private var _entry as String = "";
    private var _error as String?;
    protected var innerRadius as Float = 0.0;

    // initialises the class instance
    public function initialize(entryType as InputType, title as String?, unit as String?, max as Number, onDoneHandler as Method, delegate as ValueInputDelegate) {
        View.initialize();
        _delegate = delegate;
        _entryType = entryType;
        _title = title;
        _unit = unit;
        _max = max;
        _onDoneHandler = onDoneHandler;

        // calculate coordinates of digits
        var fontDiameter = Math.sqrt(FONT_WIDTH*FONT_WIDTH + FONT_HEIGHT*FONT_HEIGHT);
        _coords = new [10];
        for (var n = 0; n < 10; n++) {
            var angle = (36*n)-72;
            var x = (SCR_SIZE - fontDiameter)/2 * Math.sin(Math.toRadians(angle));
            var y = (SCR_SIZE - fontDiameter)/2 * Math.cos(Math.toRadians(angle));
            var coord = [x.toNumber(), y.toNumber()];
            _coords[n] = coord;
        }

        // set radius of inner circle
        innerRadius = SCR_SIZE/2 - Math.sqrt(FONT_WIDTH*FONT_WIDTH + FONT_HEIGHT*FONT_HEIGHT);

        // initialise delegate
        _delegate.setViewParams(SCR_SIZE/2 - fontDiameter, _coords, DIGITS, method(:onDigit), method(:onEnter), method(:onBackSpace));
   }

   // function updates the title, unit and the maximum value
   protected function updateParams (entryType as InputType, title as String?, unit as String?, max as Number) as Void {
        _entryType = entryType;
        _title = title;
        _unit = unit;
        _max = max;

        // reset entry
        _entry = "";

        WatchUi.requestUpdate();
   }

    // function is called when a digit is tapped
    public function onDigit(digit as String) as Void {
        switch(_entryType) {
            case INPUT_NUMBER:
            case INPUT_DECIMAL:
                if ((_entry.length() > 0) || (!digit.equals ("0"))) {
                    var newEntry = _entry + digit;
                    if (newEntry.toNumber() > _max) {
                        _error = MAX_ERROR;
                    } else {
                        _error = null;
                        _entry = newEntry;
                    }
                }
                break;
            case INPUT_TIME:
                if (((_entry.length() != 1) || (digit.toNumber() <= 5)) && ((_entry.length() != 3) || (digit.toNumber() <= 5))) {
                    if (_entry.length() == 5) {
                        _error = MAX_ERROR;
                    } else {
                        _error = null;
                        _entry += digit;
                    }
                }
        }
        WatchUi.requestUpdate();
    }

    // function is called when the value is tapped
    public function onEnter() as Void {
        switch(_entryType) {
            case INPUT_NUMBER:
            case INPUT_DECIMAL:
                if (_entry.length()>0) {
                    if (_onDoneHandler != null) {
                        _onDoneHandler.invoke(_entry.toNumber());
                    }
                } else {
                    _error = NIL_ERROR;
                    WatchUi.requestUpdate();
                }
                break;
            case INPUT_TIME:
                if (_entry.length() == 5) {
                    // convert to time
                    var seconds = _entry.substring(3, 5).toNumber();
                    var minutes = _entry.substring(1, 3).toNumber();
                    var hours = _entry.substring(0, 1).toNumber();
                    var duration = hours*3600 + minutes*60 + seconds;
                    if (_onDoneHandler != null) {
                        _onDoneHandler.invoke(duration);
                    }
                } else {
                    _error = NIL_ERROR;
                    WatchUi.requestUpdate();
                }
        }
    }

    // function is called on a left swipe
    public function onBackSpace() as Void {
        if (_entry.length() > 0) {
            _entry = _entry.substring(0,_entry.length()-1);
        }
        _error = null;
        WatchUi.requestUpdate();
    }


    // function draws the digits
    protected function drawDigits(enabledDigits as String, dc as Dc) {
        for (var n=0; n<10; n++) {
            var coord = _coords[n] as Array<Number>;
            if (enabledDigits.find(DIGITS[n]) == null) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_WHITE);
            } else {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
            }
            dc.drawText(coord[0]+SCR_SIZE/2, coord[1]+SCR_SIZE/2, DIGIT_FONT, DIGITS[n], 
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // redraw seperation circle
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.setPenWidth(2);
        dc.fillCircle(SCR_SIZE/2, SCR_SIZE/2, innerRadius-1);

    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {

        // clear display
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.clear();

        // draw seperation lines
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.setPenWidth(2);
        var outerRadius = SCR_SIZE/2;
        for (var n = 0; n < 10; n++) {
            var angle = (36*n)-90;
            var xi = (innerRadius-1) * Math.sin(Math.toRadians(angle)) + SCR_SIZE/2;
            var yi = (innerRadius-1) * Math.cos(Math.toRadians(angle)) + SCR_SIZE/2;
            var xo = (outerRadius+1) * Math.sin(Math.toRadians(angle)) + SCR_SIZE/2;
            var yo = (outerRadius+1) * Math.cos(Math.toRadians(angle)) + SCR_SIZE/2;
            if ((n==0) || (n==5)) {
                yo = yi;
            }
            dc.drawLine(xi, yi, xo, yo);
        }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {

    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // replace digits
        switch(_entryType) {
            case INPUT_NUMBER:
            case INPUT_DECIMAL:
                if (_entry.length()==0) {
                    drawDigits("123456789", dc);
                } else {
                    drawDigits("0123456789", dc);
                }
                break;
            case INPUT_TIME:
                if ((_entry.length()==1) || (_entry.length()==3)) {
                    drawDigits("012345", dc);
                } else {
                    drawDigits("0123456789", dc);
                }
        }

        // display title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (_title != null) {
            var titleYPos = (SCR_SIZE - innerRadius.toNumber())/2; 
            dc.drawText(SCR_SIZE/2, titleYPos, TITLE_FONT, _title, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } 

        // display entry value
        var displayText = "";
        var entryXPos = 0;
        switch (_entryType) {
            case INPUT_NUMBER:
            case INPUT_DECIMAL:
                    if (_unit != null) {
                        //displayText = EMPTY_ENTRY.substring(0, (_max.toString().length() - _entry.length())*2) + _entry + _unit;
                        displayText = _entry + _unit;
                        entryXPos = (SCR_SIZE + dc.getTextWidthInPixels(_max.toString() + _unit, ENTRY_FONT))/2;
                    } else {
                        //displayText = EMPTY_ENTRY.substring(0, (_max.toString().length() - _entry.length())*2) + _entry;
                        displayText = _entry;
                        entryXPos = (SCR_SIZE + dc.getTextWidthInPixels(_max.toString(), ENTRY_FONT))/2;
                    }
                break;
            case INPUT_TIME:
                // break up the time
                switch (_entry.length()) {
                    case 0:
                        displayText = _entry + "_:_ _:_ _";
                        break;
                    case 1:
                        displayText = _entry + ":_ _:_ _";
                        break;
                    case 2:
                        displayText = _entry.substring(0, 1) + ":" + _entry.substring(1, 2) + "_:_ _";
                        break;
                    case 3:
                        displayText = _entry.substring(0, 1) + ":" + _entry.substring(1, 3) + ":_ _";
                        break;
                    case 4:
                        displayText = _entry.substring(0, 1) + ":" + _entry.substring(1, 3) + ":" + _entry.substring(3, 4) + "_";
                        break;
                    case 5:
                        displayText = _entry.substring(0, 1) + ":" + _entry.substring(1, 3) + ":" + _entry.substring(3, 5);
                }
                entryXPos = (SCR_SIZE + dc.getTextWidthInPixels("0:00:00", ENTRY_FONT))/2;
        }
        dc.drawText(entryXPos, SCR_SIZE/2, ENTRY_FONT, displayText, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        // display error value
        if (_error != null) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
            var errorYPos = (SCR_SIZE + innerRadius.toNumber())/2;
            dc.drawText(SCR_SIZE/2, errorYPos, ENTRY_FONT, _error, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
