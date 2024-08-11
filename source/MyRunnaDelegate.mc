import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class MyRunnaDelegate extends WatchUi.BehaviorDelegate {
    var _pauseHandler as Lang.Method?;
    var _displayModeChangeHandler as Lang.Method?;
    var _discardSessionHandler as Lang.Method?;
    var _endActivityHandler as Lang.Method?;


    function initialize(pauseHandler as Lang.Method, displayModeChangeHandler as Lang.Method, 
            discardSessionHandler as Lang.Method, endActivityHandler as Lang.Method) {
        BehaviorDelegate.initialize();
        _pauseHandler = pauseHandler;
        _displayModeChangeHandler = displayModeChangeHandler;
        _discardSessionHandler = discardSessionHandler;
        _endActivityHandler = endActivityHandler;
    }


    // Handle the menu behavious
    public function onMenu() as Boolean {
        System.println("onMenu");
        if (_discardSessionHandler != null) {
            _discardSessionHandler.invoke();
        }       
        return false;
    }


    // Handle the touch screen hold event
    public function onHold(evt as ClickEvent) as Boolean {
        System.println("onHold");
        return true;
    }

    // Handle the touch screen release event
    public function onRelease(evt as ClickEvent) as Boolean {
        System.println("onRelease");
        return true;
    }

    // Handle the select behaviour
    public function onSelect() as Boolean {
        System.println("onSelect");
       return false;
    }


    // Handle a screen tap event
    public function onTap(evt as ClickEvent) as Boolean {
        System.println("onTap");
        return true;
    }


    // Handle the next page behaviour
    public function onNextPage() as Boolean {
        System.println("OnNextPage");
        if (_displayModeChangeHandler != null) {
            _displayModeChangeHandler.invoke(true);
        }
        return false;
    }


    // Handle the previous page behaviour
    public function onPreviousPage() as Boolean {
        System.println("OnPreviousPage");
        if (_displayModeChangeHandler != null) {
            _displayModeChangeHandler.invoke(false);
        }
        return false;
    }


    // Handle the touch screen swipe event
    public function onSwipe(evt as SwipeEvent) as Boolean {
        System.println("onSwipe"+evt.getDirection());
        return true;
    }


    // Handle the back behaviour
    public function onBack() as Boolean {
        System.println("onBack");

        if (_endActivityHandler != null) {
            _endActivityHandler.invoke();
        }

        return false;
    }


    // Handle a physical button being pressed
    public function onKeyPressed(evt as KeyEvent) as Boolean {
        System.println("onKeyPressed"+evt.getKey());
        return true;
    }


    // Handle a physical button being released
    public function onKeyReleased(evt as KeyEvent) as Boolean {
        System.println("onKeyReleased"+evt.getKey());
        return true;
    }

    // Handle a physical button being pressed and released
    public function onKey(evt as KeyEvent) as Boolean {
        System.println("onKey=" + evt.getKey());

        switch (evt.getKey()) {
            case KEY_ENTER:
                if (_pauseHandler != null) {
                    _pauseHandler.invoke();
                }
                break;
            case KEY_ESC:
                //if (_endActivityHandler != null) {
                //    _endActivityHandler.invoke();
                //}
                break;
            default:
        }

        return true;
    }
}