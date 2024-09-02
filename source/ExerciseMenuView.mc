import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class ExerciseMenuView extends WatchUi.Menu2 {

    // menu item IDs
    static public const DISCARD_ITEM = "discard";
    static public const WARMUP_RUN_ITEM = "wuru";
    static public const WARMUP_WALK_ITEM = "wure";
    static public const EXERCISE_RUN_ITEM = "exru";
    static public const EXERCISE_WALK_ITEM = "exre";
    static public const EXERCISE_REPEATS_ITEM = "repeats";
    static public const COOLDOWN_RUN_ITEM = "cdru";
    static public const COOLDOWN_WALK_ITEM = "cdre";

    // exercise repeat defaults
    static private const REPEATS_MAX = 100;
    static private const REPEATS_TITLE = "Repeats";

    // preset menu subtext
    static private const SUBTITLE_SESSION_OPEN = "logging activity";
    static private const SUBTITLE_SESSION_CLOSED = "activity log empty";

    // menu items
    private var _discardActivityItem as MenuItem?;
    private var _wuExItem as MenuItem?;
    private var _wuReItem as MenuItem?;
    private var _ruExItem as MenuItem?;
    private var _ruReItem as MenuItem?;
    private var _ruRepeatsItem as MenuItem?;
    private var _cdExItem as MenuItem?;
    private var _cdReItem as MenuItem?;

    // exercise settings
    private var _settings as ExerciseSettings?;

    // exercise menu delegate
    private var _delegate as ExerciseMenuDelegate?;

    // callback methods
    private var _discardSessionHandler as Method?;
    private var _isSessionOpenHandler as Method?;

    // other variables
    private var _lastMenuItemId as String?;
    private var _isSettingsUpdated as Boolean = false;

    // Constructor
    public function initialize(settings as ExerciseSettings, discardSessionHandler as Method, isSessionOpenHandler as Method, 
            delegate as ExerciseMenuDelegate) {

        _settings = settings;
        _discardSessionHandler = discardSessionHandler;
        _isSessionOpenHandler = isSessionOpenHandler;
        _delegate = delegate;
        _delegate.setCallbackMethods(method(:openMenuItem), method(:saveSettings));

        // create exercise menu
        Menu2.initialize({:title=>"Exercise Menu"});

        // Add menu items for the configurables
        if (_isSessionOpenHandler.invoke()) {
            _discardActivityItem = new WatchUi.MenuItem("Discard activity", SUBTITLE_SESSION_OPEN, DISCARD_ITEM, null);
        } else {
            _discardActivityItem = new WatchUi.MenuItem("Discard activity", SUBTITLE_SESSION_CLOSED, DISCARD_ITEM, null);
        }
        addItem(_discardActivityItem);
        _wuExItem = new WatchUi.MenuItem("Warmup - run", subMenuText(_settings.wuExType, _settings.wuExValue), WARMUP_RUN_ITEM, null);
        addItem(_wuExItem);
        _wuReItem = new WatchUi.MenuItem("Warmup - walk", subMenuText(_settings.wuReType, _settings.wuReValue), WARMUP_WALK_ITEM, null);
        addItem(_wuReItem);
        _ruExItem = new WatchUi.MenuItem("Exercise - run", subMenuText(_settings.ruExType, _settings.ruExValue), EXERCISE_RUN_ITEM, null);
        addItem(_ruExItem);
        _ruReItem = new WatchUi.MenuItem("Exercise - walk", subMenuText(_settings.ruReType, _settings.ruReValue), EXERCISE_WALK_ITEM, null);
        addItem(_ruReItem);
        _ruRepeatsItem = new WatchUi.MenuItem("Exercise - repeats", _settings.ruRepeats.toString(), EXERCISE_REPEATS_ITEM, null);
        addItem(_ruRepeatsItem);
        _cdExItem = new WatchUi.MenuItem("Cooldown - run", subMenuText(_settings.cdExType, _settings.cdExValue), COOLDOWN_RUN_ITEM, null);
        addItem(_cdExItem);
        _cdReItem = new WatchUi.MenuItem("Cooldown - walk", subMenuText(_settings.cdReType, _settings.cdReValue), COOLDOWN_WALK_ITEM, null);
        addItem(_cdReItem);
    }


    // function formats the submenu text
    // uses the exercise type and value
    private function subMenuText(exType as ExerciseSettings.ExType, value as Number) as String{
        switch (exType) {
            case ExerciseSettings.TYPE_NONE:
                return ExerciseInputView.NONE_TITLE;
            case ExerciseSettings.TYPE_DURATION:
                // format duration
                var seconds = value%60;
                var minutes = (value/60)%60;
                var hours = value/3600;
                return ExerciseInputView.DUR_TITLE + " = " + hours.toString() + ":" + minutes.format("%02u") +
                    ":" + seconds.format("%02u");
            case ExerciseSettings.TYPE_DISTANCE:
            default:
                return ExerciseInputView.DIST_TITLE + " = " + value.toString() + ExerciseInputView.DIST_UNIT;
        }
    }


    // function handles a request to discard the session
    // opens a dialogue to confirm to discard
    public function confirmDiscardSession() as Void {
        if (_isSessionOpenHandler.invoke()) {
            var dialog = new WatchUi.Confirmation("Discard activity?");
            WatchUi.pushView(dialog, new MyRunnaConfirmationDelegate(method(:discardSession)), WatchUi.SLIDE_LEFT);
        }
    }


    // function haldes the confirmation to discard a session
    public function discardSession() as Void {
        _discardActivityItem.setSubLabel(SUBTITLE_SESSION_CLOSED);
        _discardSessionHandler.invoke();
    }


    // function opens the input vie for a specific menu item
    public function openMenuItem(item as MenuItem) as Void {
        _lastMenuItemId = item.getId() as String;
        System.println("selected " + _lastMenuItemId);

        // action menu iten selected
        if (_lastMenuItemId.equals(DISCARD_ITEM)) {
            confirmDiscardSession();
        } else {
            if (_lastMenuItemId.equals(WARMUP_RUN_ITEM)) {
                var delegate = new ExerciseInputDelegate();
                var view = new ExerciseInputView(_settings.wuExType, 0, method(:updateSettings), delegate);
                WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
            } else if (_lastMenuItemId.equals(WARMUP_WALK_ITEM)) {
                var delegate = new ExerciseInputDelegate();
                var view = new ExerciseInputView(_settings.wuReType, 0, method(:updateSettings), delegate);
                WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
            } else if (_lastMenuItemId.equals(EXERCISE_RUN_ITEM)) {
                var delegate = new ExerciseInputDelegate();
                var view = new ExerciseInputView(_settings.ruExType, 0, method(:updateSettings), delegate);
                WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
            } else if (_lastMenuItemId.equals(EXERCISE_WALK_ITEM)) {
                var delegate = new ExerciseInputDelegate();
                var view = new ExerciseInputView(_settings.ruReType, 0, method(:updateSettings), delegate);
                WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
            } else if (_lastMenuItemId.equals(EXERCISE_REPEATS_ITEM)) {
                var delegate = new ValueInputDelegate();
                var view = new ValueInputView(ValueInputView.INPUT_NUMBER, REPEATS_TITLE, null, REPEATS_MAX, method(:updateRepeats), delegate);
                WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
            } else if (_lastMenuItemId.equals(COOLDOWN_RUN_ITEM)) {
                var delegate = new ExerciseInputDelegate();
                var view = new ExerciseInputView(_settings.cdExType, 0, method(:updateSettings), delegate);
                WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
            } else if (_lastMenuItemId.equals(COOLDOWN_WALK_ITEM)) {
                var delegate = new ExerciseInputDelegate();
                var view = new ExerciseInputView(_settings.cdReType, 0, method(:updateSettings), delegate);
                WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
            }
        }
    }


    // function sets the menu sublabels in accordance with the settings
    private function updateSubLabels() {
            _wuExItem.setSubLabel(subMenuText(_settings.wuExType, _settings.wuExValue));
            _wuReItem.setSubLabel(subMenuText(_settings.wuReType, _settings.wuReValue));
            _ruExItem.setSubLabel(subMenuText(_settings.ruExType, _settings.ruExValue));
            _ruReItem.setSubLabel(subMenuText(_settings.ruReType, _settings.ruReValue));
            _cdExItem.setSubLabel(subMenuText(_settings.cdExType, _settings.cdExValue));
            _cdReItem.setSubLabel(subMenuText(_settings.cdReType, _settings.cdReValue));
    } 


    // function handles the update to the settings
    // it is call when the setting has been entered
    public function updateSettings(exType as ExerciseSettings.ExType, value as Number) as Void {
        System.println("updateSettings called " + exType + ", " + value);
        System.println("lastMenuItem " + _lastMenuItemId);

        // backup settings for restore if required
        _settings.backup();

        // update setting according to menu item
        if (_lastMenuItemId.equals(WARMUP_RUN_ITEM)) {
            _settings.wuExType = exType;
            _settings.wuExValue = value;
        } else if (_lastMenuItemId.equals(WARMUP_WALK_ITEM)) {
            _settings.wuReType = exType;
            _settings.wuReValue = value;
        } else if (_lastMenuItemId.equals(EXERCISE_RUN_ITEM)) {
            _settings.ruExType = exType;
            _settings.ruExValue = value;
        } else if (_lastMenuItemId.equals(EXERCISE_WALK_ITEM)) {
            _settings.ruReType = exType;
            _settings.ruReValue = value;
        } else if (_lastMenuItemId.equals(COOLDOWN_RUN_ITEM)) {
            _settings.cdExType = exType;
            _settings.cdExValue = value;
        } else if (_lastMenuItemId.equals(COOLDOWN_WALK_ITEM)) {
            _settings.cdReType = exType;
            _settings.cdReValue = value;
        }

        // check if settings as are valid and restore if not
        if (_settings.areValid()) {
            _isSettingsUpdated = true;

            // update menu subtitle
            updateSubLabels(); 

            // pop input view
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        } else {
            // restore settings
            _settings.restore();

            // pop input view
            WatchUi.popView(WatchUi.SLIDE_RIGHT);

            // display error message
            WatchUi.pushView(new ErrorMessageView("INVALID\nSETTING\n and not applied"), new ErrorMessageDelegate(), WatchUi.SLIDE_IMMEDIATE);
        }

    }


    // function closes the error view and settings view
    // it is called by the ErrorMessageDialogue when the user acknoledges the error
    public function closeErrorMessage() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }


    // function handles the update t0 the repeats setting
    public function updateRepeats (value as Number) as Void {
        System.println("updateRepeats called " + value);
        System.println("lastMenuItem " + _lastMenuItemId);

        // update repeats settings
        _settings.ruRepeats = value;
        _isSettingsUpdated = true;
        _ruRepeatsItem.setSubLabel(_settings.ruRepeats.toString());

        // pop input view
        WatchUi.popView(WatchUi.SLIDE_RIGHT);

    } 


    // function saves the settings to the properties if settings have been updated
    public function saveSettings() {
        if (_isSettingsUpdated) {
            _settings.save();
        }
    }


    // Load your resources here
    public function onLayout(dc as Dc) {
        Menu2.onLayout(dc);
    }


    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    public function onShow() as Void {
        Menu2.onShow();
    }


    // Update the view
    public function onUpdate(dc as Dc) as Void {
        System.println("ExercisemenuView.onUpdate");
        // update menu subtext according to last update
        if (_lastMenuItemId != null) {
            if (_lastMenuItemId.equals(DISCARD_ITEM)) {
                if (_isSessionOpenHandler.invoke()) {
                    _discardActivityItem.setSubLabel(SUBTITLE_SESSION_OPEN);
                } else {
                    _discardActivityItem.setSubLabel(SUBTITLE_SESSION_CLOSED);
                }
            } else if (_lastMenuItemId.equals(WARMUP_RUN_ITEM)) {
            } else if (_lastMenuItemId.equals(WARMUP_WALK_ITEM)) {
            } else if (_lastMenuItemId.equals(EXERCISE_RUN_ITEM)) {
            } else if (_lastMenuItemId.equals(EXERCISE_WALK_ITEM)) {
            } else if (_lastMenuItemId.equals(EXERCISE_REPEATS_ITEM)) {
            } else if (_lastMenuItemId.equals(COOLDOWN_RUN_ITEM)) {
            } else if (_lastMenuItemId.equals(COOLDOWN_WALK_ITEM)) {
            }
        }

        // Call the parent onUpdate function to redraw the layout
        Menu2.onUpdate(dc);
    }


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    public function onHide() as Void {
        Menu2.onHide();
    }

}
