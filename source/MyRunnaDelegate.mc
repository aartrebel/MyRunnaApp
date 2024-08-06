import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class MyRunnaDelegate extends WatchUi.BehaviorDelegate {
    var _buttonHandler as Lang.Method?;

    function initialize() {
        BehaviorDelegate.initialize();
    }


    // function sets the handler when the watch button is pressed
    public function setButtonHandler(handler as Lang.Method) as Void {
        _buttonHandler = handler;
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

}