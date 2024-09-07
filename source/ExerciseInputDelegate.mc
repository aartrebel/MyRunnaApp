import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Math;

class ExerciseInputDelegate extends ValueInputDelegate {

    private var _pageChangeHandler as Method?;


    function initialize() {
        ValueInputDelegate.initialize();
    }


    // functions sets the handler for the next and previous page
    public function setHandlers(pageChangeHandler as Method) {
        _pageChangeHandler = pageChangeHandler;
    }


    // Handle the next page behaviour
    public function onNextPage() as Boolean {
        if (_pageChangeHandler != null) {
            _pageChangeHandler.invoke(true);
        }
        return true;
    }


    // Handle the previous page behaviour
    public function onPreviousPage() as Boolean {
        if (_pageChangeHandler != null) {
            _pageChangeHandler.invoke(false);
        }
        return true;
    }


}