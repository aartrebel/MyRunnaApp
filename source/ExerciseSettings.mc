import Toybox.Lang;
import Toybox.Application;
import Toybox.System;

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


    // constricts the class instance and loads the settings from properties
    public function initialize() {
        load();
    }
    

    // function presets the settings
    // initialise settings for debugging only
    public function preset() {
        wuExType = TYPE_NONE;
        wuExValue = 0;
        wuReType = TYPE_DURATION;
        wuReValue = 300;

        ruExType = TYPE_DISTANCE;
        ruExValue = 1234;
        ruReType = TYPE_DURATION;
        ruReValue = 60;
        ruRepeats = 3;

        cdExType = TYPE_NONE;
        cdExValue = 0;
        cdReType = TYPE_DURATION;
        cdReValue = 300;
   }


    // function loads the settings from storage in properties
    public function load() as Void {
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
    }


    // function checks that the settings are valie
    public function areValid() as Boolean {
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


    // function saves the settings to storage in the properties
    public function save() as Void {
        System.println("save settings ...");
        Properties.setValue("wuExType",wuExType);
        Properties.setValue("wuExValue",wuExValue);
        Properties.setValue("wuReType",wuReType);
        Properties.setValue("wuReValue",wuReValue);

        Properties.setValue("ruExType",ruExType);
        Properties.setValue("ruExValue",ruExValue);
        Properties.setValue("ruReType",ruReType);
        Properties.setValue("ruReValue",ruReValue);
        Properties.setValue("ruRepeats",ruRepeats);

        Properties.setValue("cdExType",cdExType);
        Properties.setValue("cdExValue",cdExValue);
        Properties.setValue("cdReType",cdReType);
        Properties.setValue("cdReValue",cdReValue);
    }

}