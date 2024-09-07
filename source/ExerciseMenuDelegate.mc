import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class ExerciseMenuDelegate extends WatchUi.Menu2InputDelegate {

    // call back methods
    private var _openMenuItem as Method?;
    private var _saveSettingsHandler as Method?;


    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }


    // function sets the call back methods to the menu
    public function setCallbackMethods(openMenuItem as Method, saveSettingsHandler as Method) as Void {
        _openMenuItem = openMenuItem;
        _saveSettingsHandler = saveSettingsHandler;
    }


    // Handle an item being selected
    public function onSelect(item as MenuItem) as Void {
        _openMenuItem.invoke(item);
    }


    // Handle the back key being pressed
    public function onBack() as Void {
        // save settings to properties
        _saveSettingsHandler.invoke();

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }


}
