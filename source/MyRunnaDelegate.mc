import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class MyRunnaDelegate extends WatchUi.BehaviorDelegate {
    var _buttonHandler as Lang.Method?;
    var _tapHandler as Lang.Method?;

    function initialize() {
        BehaviorDelegate.initialize();
    }


    // function sets the handler when the watch button is pressed
    public function setHandlers(buttonHandler as Lang.Method, tapHandler as Lang.Method) as Void {
        _buttonHandler = buttonHandler;
        _tapHandler = tapHandler;
    }


    //function onMenu() as Boolean {
    //    WatchUi.pushView(new Rez.Menus.MainMenu(), new MyRunnaMenuDelegate(), WatchUi.SLIDE_UP);
    //    return true;
    //}

    // Handle the button being pressed
    public function onKeyPressed(evt as KeyEvent) as Boolean {
        if (_buttonHandler != null) {
            _buttonHandler.invoke();
        }
       return true;
    }

    // Handler the screen being tapper
    public function onTap(click as ClickEvent) as Boolean {
        if (_tapHandler != null) {
            _tapHandler.invoke();
        }
        return true;
    }

}