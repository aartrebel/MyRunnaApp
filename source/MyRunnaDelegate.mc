import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class MyRunnaDelegate extends WatchUi.BehaviorDelegate {
    var _pauseHandler as Lang.Method?;
    var _displayModeChangeHandler as Lang.Method?;
    var _discardSessionHandler as Lang.Method?;


    function initialize(pauseHandler as Lang.Method, displayModeChangeHandler as Lang.Method, discardSessionHandler as Lang.Method) {
        BehaviorDelegate.initialize();
        _pauseHandler = pauseHandler;
        _displayModeChangeHandler = displayModeChangeHandler;
        _discardSessionHandler = discardSessionHandler;
    }


    // Handle the menu behavious
    public function onMenu() as Boolean {
        if (_discardSessionHandler != null) {
            _discardSessionHandler.invoke();
        }       return true;
    }


    // Handle the select behaviour
    public function onSelect() as Boolean {
        if (_pauseHandler != null) {
            _pauseHandler.invoke();
        }
       return true;
    }


    // Handle the next page behaviour
    public function onNextPage() as Boolean {
        if (_displayModeChangeHandler != null) {
            _displayModeChangeHandler.invoke(true);
        }
        return true;
    }


    // Handle the previous page behaviour
    public function onPreviousPage() as Boolean {
        if (_displayModeChangeHandler != null) {
            _displayModeChangeHandler.invoke(true);
        }
        return true;
    }


    // Handle the back behaviour
    //public function onBack() as Boolean {
    //    if (_discardSessionHandler != null) {
    //        _discardSessionHandler.invoke();
    //    }
    //    return true;
    //}
    
}