import Toybox.Lang;
import Toybox.WatchUi;

// Input handler for the confirmation dialog
class ExitConfirmationDelegate extends WatchUi.ConfirmationDelegate {

    private var _exitMethod as Lang.Method?;

    //! Constructor
    //! @param view The app view
    public function initialize(exitMethod as Lang.Method) {
        ConfirmationDelegate.initialize();
        _exitMethod = exitMethod;
    }

    //! Handle a confirmation selection
    //! @param value The confirmation value
    //! @return true if handled, false otherwise
    public function onResponse(value as WatchUi.Confirm) as Boolean {
        if (value == WatchUi.CONFIRM_YES) {
            _exitMethod.invoke();
        }
        return true;
    }
}