import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class ExerciseMenuDelegate extends WatchUi.Menu2InputDelegate {

    static public const DISCARD_ITEM = "discard";
    static public const WARMUP_RUN_ITEM = "wuru";
    static public const WARMUP_WALK_ITEM = "wure";
    static public const EXERCISE_RUN_ITEM = "exru";
    static public const EXERCISE_WALK_ITEM = "exre";
    static public const EXERCISE_REPEATS_ITEM = "repeats";
    static public const COOLDOWN_RUN_ITEM = "cdru";
    static public const COOLDOWN_WALK_ITEM = "cdre";

    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    //! Handle an item being selected
    public function onSelect(item as MenuItem) as Void {
        var menuItem = item.getId() as String;
        System.println("selected " + menuItem);

        // action menu iten selected
        if (menuItem.equals(DISCARD_ITEM)) {
        } else if (menuItem.equals(WARMUP_RUN_ITEM)) {
            var delegate = new ExerciseInputDelegate();
            var view = new ExerciseInputView(DISTANCE, delegate);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_UP);
        } else if (menuItem.equals(WARMUP_WALK_ITEM)) {

        } else if (menuItem.equals(EXERCISE_RUN_ITEM)) {

        } else if (menuItem.equals(EXERCISE_WALK_ITEM)) {

        } else if (menuItem.equals(EXERCISE_REPEATS_ITEM)) {

        } else if (menuItem.equals(COOLDOWN_RUN_ITEM)) {

        } else if (menuItem.equals(COOLDOWN_WALK_ITEM)) {

        } else {
            WatchUi.requestUpdate();
        }
    }

    //! Handle the back key being pressed
    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
