import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class ErrorMessageView extends WatchUi.View {

    // instruction under error message
    static private const ACTION_MSG = "tap to\ncontinue"; 

    // error message to display
    private var _errorMsg as String?;


    function initialize(errorMsg as String) {
        View.initialize();
        _errorMsg = errorMsg;
    }


    // Load your resources here
    function onLayout(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.clear();
        var message = _errorMsg + "\n" + ACTION_MSG;
        dc.drawText(120, 120, Graphics.FONT_LARGE, message, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }


    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }


    // Update the view
    function onUpdate(dc as Dc) as Void {
    }


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
