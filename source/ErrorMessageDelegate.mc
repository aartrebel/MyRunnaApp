import Toybox.Lang;
import Toybox.WatchUi;

class ErrorMessageDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }


    // Handle the select behaviour
    public function onSelect() as Boolean {
       return false;
    }

 
    // handle the tap action
    public function onTap(click as ClickEvent) as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }


}