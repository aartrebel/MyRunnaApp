import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;
import Toybox.Lang;

class ExerciseInputView extends ValueInputView {

    static public const NONE_ENTRY = "disabled";
    static public const DIST_UNIT = "m";
    static private const DIST_MAX = 99999;
    static private const DUR_MAX = 60*60*10;

    private var _currentExType as ExerciseSettings.ExType?;
    private var _updateSettingsHandler as Method?;
    private var _typeLocked as Boolean?;
    private var _title as String?;


    function initialize(title as String, currentExType as ExerciseSettings.ExType, currentValue as Number, typeLocked as Boolean, 
            updateSettingsHandler as Method, delegate as ExerciseInputDelegate) {
        _currentExType = currentExType;
        _updateSettingsHandler = updateSettingsHandler;
        _typeLocked = typeLocked;
        _title = title;

        // initialise the view according to the exercise type
        switch (_currentExType) {
            case ExerciseSettings.TYPE_DURATION:
                ValueInputView.initialize(ValueInputView.INPUT_TIME, _title, null, DUR_MAX, method(:onDone), delegate);
                break;
            case ExerciseSettings.TYPE_DISTANCE:
                ValueInputView.initialize(ValueInputView.INPUT_NUMBER, _title, DIST_UNIT, DIST_MAX, method(:onDone), delegate);
                break;
            case ExerciseSettings.TYPE_NONE:
            default:
                _currentExType = ExerciseSettings.TYPE_NONE;
                ValueInputView.initialize(ValueInputView.INPUT_NUMBER, null, null, 0, method(:onDone), delegate);
        }

        // initialise the handler
        delegate.setHandlers(method(:onPageChange));
    }


    // function changes the input mode to the next
    public function onPageChange(isNext as Boolean) as Void {
        if (!_typeLocked) {
            switch (_currentExType) {
                case ExerciseSettings.TYPE_DURATION:
                    if (isNext) {
                        _currentExType = ExerciseSettings.TYPE_DISTANCE;
                        ValueInputView.updateParams(ValueInputView.INPUT_NUMBER, _title, DIST_UNIT, DIST_MAX);
                    } else {
                        _currentExType = ExerciseSettings.TYPE_NONE;
                        ValueInputView.updateParams(ValueInputView.INPUT_NUMBER, null, null, 0);
                    }
                    break;
                case ExerciseSettings.TYPE_DISTANCE:
                    if (isNext) {
                        _currentExType = ExerciseSettings.TYPE_NONE;
                        ValueInputView.updateParams(ValueInputView.INPUT_NUMBER, null, null, 0);
                    } else {
                        _currentExType = ExerciseSettings.TYPE_DURATION;
                        ValueInputView.updateParams(ValueInputView.INPUT_TIME, _title, null, DUR_MAX);
                    }
                    break;
                case ExerciseSettings.TYPE_NONE:
                default:
                    if (isNext) {
                        _currentExType = ExerciseSettings.TYPE_DURATION;
                        ValueInputView.updateParams(ValueInputView.INPUT_TIME, _title, null, DUR_MAX);
                    } else {
                        _currentExType = ExerciseSettings.TYPE_DISTANCE;
                        ValueInputView.updateParams(ValueInputView.INPUT_NUMBER, _title, DIST_UNIT, DIST_MAX);
                    }
            }
        }
    }


    // function is called when the value is tapped
    public function onEnter() as Void {
        if (_currentExType == ExerciseSettings.TYPE_NONE) {
            onDone(0);
        } else {
            ValueInputView.onEnter();
        }
    }


    // function that is called when done
    public function onDone (value as Number) as Void {
        if (_updateSettingsHandler != null) {
            _updateSettingsHandler.invoke(_currentExType, value as Number);
        }
    } 


    // Load your resources here
    function onLayout(dc as Dc) as Void {
        ValueInputView.onLayout(dc);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        ValueInputView.onShow();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        if (_currentExType == ExerciseSettings.TYPE_NONE) {
 
            // display digitis (all disabled)
            drawDigits("", dc);

            // display title
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            var titleYPos = (SCR_SIZE - innerRadius.toNumber())/2; 
            dc.drawText(SCR_SIZE/2, titleYPos, ValueInputView.TITLE_FONT, _title, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            // display nil value
            var entryXPos = (SCR_SIZE + dc.getTextWidthInPixels(NONE_ENTRY, ENTRY_FONT))/2;
            dc.drawText(entryXPos, SCR_SIZE/2, ValueInputView.ENTRY_FONT, NONE_ENTRY, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        } else {
            ValueInputView.onUpdate(dc);
        }

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        ValueInputView.onHide();
    }

}
