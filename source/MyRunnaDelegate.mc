import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class MyRunnaDelegate extends WatchUi.BehaviorDelegate {
    var _buttonHandler as Lang.Method?;
    var _tapHandler as Lang.Method?;
    var _pressHandler as Lang.Method?;


    function initialize(buttonHandler as Lang.Method, tapHandler as Lang.Method, pressHandler as Lang.Method) {
        BehaviorDelegate.initialize();
        _buttonHandler = buttonHandler;
        _tapHandler = tapHandler;
        _pressHandler = pressHandler;
    }


    // Handle the button being pressed
    public function onKeyPressed(evt as KeyEvent) as Boolean {
        if (_buttonHandler != null) {
            _buttonHandler.invoke();
        }
       return true;
    }


    // Handle the screen being tapper
    public function onTap(click as ClickEvent) as Boolean {
        if ((_tapHandler != null) && (click.getType() == WatchUi.CLICK_TYPE_TAP)) {
            _tapHandler.invoke();
        }
        return true;
    }


    // Handle the screen being swiped
    public function onSwipe (swipe as SwipeEvent) as Boolean {
        System.println("Swipe " + swipe.getDirection());
        return true;
    }


    // Handle the screen being pressed
    public function onHold (click as ClickEvent) as Boolean {
        if ((_pressHandler != null) && (click.getType() == WatchUi.CLICK_TYPE_HOLD)) {
            _pressHandler.invoke();
        }
        return true;
    }
    
}