import Toybox.Lang;
import Toybox.WatchUi;

// Input handler for the confirmation dialog
class MyRunnaConfirmationDelegate extends WatchUi.ConfirmationDelegate {

    private var _method as Lang.Method?;

    //! Constructor
    //! @param view The app view
    public function initialize(method as Lang.Method) {
        ConfirmationDelegate.initialize();
        _method = method;
    }

    //! Handle a confirmation selection
    //! @param value The confirmation value
    //! @return true if handled, false otherwise
    public function onResponse(value as WatchUi.Confirm) as Boolean {
        if (value == WatchUi.CONFIRM_YES) {
            _method.invoke();
        }
        return true;
    }
}