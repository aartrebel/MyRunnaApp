import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class MyRunnaDelegate extends WatchUi.BehaviorDelegate {
    var _pauseHandler as Method?;
    var _displayModeChangeHandler as Method?;
    var _discardSessionHandler as Method?;
    var _endActivityHandler as Method?;
    var _menuHandler as Method?;


    function initialize(pauseHandler as Method, displayModeChangeHandler as Method, endActivityHandler as Method, menuHandler as Method) {
        BehaviorDelegate.initialize();
        _pauseHandler = pauseHandler;
        _displayModeChangeHandler = displayModeChangeHandler;
        _endActivityHandler = endActivityHandler;
        _menuHandler = menuHandler;
    }


    // Handle the menu behavious
    public function onMenu() as Boolean {
        if (_menuHandler != null) {
            _menuHandler.invoke();
        }       
        return false;
    }


    // Handle the touch screen hold event
    public function onHold(evt as ClickEvent) as Boolean {
        return true;
    }

    // Handle the touch screen release event
    public function onRelease(evt as ClickEvent) as Boolean {
        return true;
    }

    // Handle the select behaviour
    public function onSelect() as Boolean {
       return false;
    }


    // Handle a screen tap event
    public function onTap(evt as ClickEvent) as Boolean {
        return true;
    }


    // Handle the next page behaviour
    public function onNextPage() as Boolean {
        if (_displayModeChangeHandler != null) {
            _displayModeChangeHandler.invoke(true);
        }
        return false;
    }


    // Handle the previous page behaviour
    public function onPreviousPage() as Boolean {
        if (_displayModeChangeHandler != null) {
            _displayModeChangeHandler.invoke(false);
        }
        return false;
    }


    // Handle the touch screen swipe event
    public function onSwipe(evt as SwipeEvent) as Boolean {
        return true;
    }


    // Handle the back behaviour
    public function onBack() as Boolean {
        if (_endActivityHandler != null) {
            _endActivityHandler.invoke();
        }

        return false;
    }


    // Handle a physical button being pressed
    public function onKeyPressed(evt as KeyEvent) as Boolean {
        return true;
    }


    // Handle a physical button being released
    public function onKeyReleased(evt as KeyEvent) as Boolean {
        return true;
    }

    // Handle a physical button being pressed and released
    public function onKey(evt as KeyEvent) as Boolean {

        switch (evt.getKey()) {
            case KEY_ENTER:
                if (_pauseHandler != null) {
                    _pauseHandler.invoke();
                }
                break;
            case KEY_ESC:
                break;
            default:
        }

        return true;
    }
}