import Toybox.Lang;
import Toybox.WatchUi;

class MyRunnaDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new MyRunnaMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}