import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.ActivityRecording;

// Input handler for the confirmation dialog
class DiscardConfirmationDelegate extends WatchUi.ConfirmationDelegate {

    private var _discardMethod as Lang.Method?;

    //! Constructor
    //! @param view The app view
    public function initialize(discardMethod as Lang.Method) {
        ConfirmationDelegate.initialize();
        _discardMethod = discardMethod;
    }

    //! Handle a confirmation selection
    //! @param value The confirmation value
    //! @return true if handled, false otherwise
    public function onResponse(value as WatchUi.Confirm) as Boolean {
        if (value == WatchUi.CONFIRM_YES) {
            _discardMethod.invoke();
        }
        return true;
    }
}