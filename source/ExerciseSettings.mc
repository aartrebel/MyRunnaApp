import Toybox.Lang;
import Toybox.Application;

class ExerciseSettings {

    public enum ExType {
        TYPE_NONE = 0,
        TYPE_DURATION = 1,
        TYPE_DISTANCE = 2
    }

    // settings variables
    public var wuExType as ExType = TYPE_NONE;
    public var wuExValue as Number = 0;
    public var wuReType as ExType = TYPE_NONE;
    public var wuReValue as Number = 0;

    public var ruExType as ExType = TYPE_NONE;
    public var ruExValue as Number = 0;
    public var ruReType as ExType = TYPE_NONE;
    public var ruReValue as Number = 0;
    public var ruRepeats as Number = 0;

    public var cdExType as ExType = TYPE_NONE;
    public var cdExValue as Number = 0;
    public var cdReType as ExType = TYPE_NONE;
    public var cdReValue as Number = 0;
    

    // function presets the settings
    public function presetSettings() {
        // initialise settings for debugging only - should be set vir Garmin Connect
        Properties.setValue("wuExType",TYPE_NONE);
        Properties.setValue("wuExValue",0);
        Properties.setValue("wuReType",TYPE_DURATION);
        Properties.setValue("wuReValue",300);

        Properties.setValue("ruExType",TYPE_DURATION);
        Properties.setValue("ruExValue",240);
        Properties.setValue("ruReType",TYPE_DURATION);
        Properties.setValue("ruReValue",60);
        Properties.setValue("ruRepeats",5);

        Properties.setValue("cdExType",TYPE_NONE);
        Properties.setValue("cdExValue",0);
        Properties.setValue("cdReType",TYPE_DURATION);
        Properties.setValue("cdReValue",300);
    }


    // function loads the settings and checks that they are valid
    public function loadSettings() as Boolean {
       // load settings from Properties
        wuExType = Properties.getValue("wuExType") as ExType;
        wuExValue = Properties.getValue("wuExValue");
        wuReType = Properties.getValue("wuReType") as ExType;
        wuReValue = Properties.getValue("wuReValue");

        ruExType = Properties.getValue("ruExType") as ExType;
        ruExValue = Properties.getValue("ruExValue");
        ruReType = Properties.getValue("ruReType") as ExType;
        ruReValue = Properties.getValue("ruReValue");
        ruRepeats = Properties.getValue("ruRepeats");

        cdExType = Properties.getValue("cdExType") as ExType;
        cdExValue = Properties.getValue("cdExValue");
        cdReType = Properties.getValue("cdReType") as ExType;
        cdReValue = Properties.getValue("cdReValue");

        // check settings
        var isSettingsError =   ((wuExType == TYPE_NONE) && (wuReType == TYPE_NONE)) ||
                        ((ruExType == TYPE_NONE) && (ruReType == TYPE_NONE)) ||
                        ((cdExType == TYPE_NONE) && (cdReType == TYPE_NONE)) ||
                        ((wuExType != TYPE_NONE) && (wuExValue == 0)) ||
                        ((wuReType != TYPE_NONE) && (wuReValue == 0)) ||
                        ((ruExType != TYPE_NONE) && (ruExValue == 0)) ||
                        ((ruReType != TYPE_NONE) && (ruReValue == 0)) ||
                        ((cdExType != TYPE_NONE) && (cdExValue == 0)) ||
                        ((cdReType != TYPE_NONE) && (cdReValue == 0)) ||
                        (wuExValue < 0) ||
                        (wuReValue < 0) ||
                        (ruExValue < 0) ||
                        (ruReValue < 0) ||
                        (cdExValue < 0) ||
                        (cdReValue < 0) ||
                        (ruRepeats <= 0);
        return !isSettingsError;
    }

}