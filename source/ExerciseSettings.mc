import Toybox.Lang;
import Toybox.Application;
import Toybox.System;

class ExerciseSettings {

    public enum ExType {
        TYPE_NONE = 0,
        TYPE_DURATION = 1,
        TYPE_DISTANCE = 2,
        TYPE_ANY = 3
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

    // backup of settings
    private var prevWuExType as ExType = TYPE_NONE;
    private var prevWuExValue as Number = 0;
    private var prevWuReType as ExType = TYPE_NONE;
    private var prevWuReValue as Number = 0;
    private var prevRuExType as ExType = TYPE_NONE;
    private var prevRuExValue as Number = 0;
    private var prevRuReType as ExType = TYPE_NONE;
    private var prevRuReValue as Number = 0;
    private var prevRuRepeats as Number = 0;
    private var prevCdExType as ExType = TYPE_NONE;
    private var prevCdExValue as Number = 0;
    private var prevCdReType as ExType = TYPE_NONE;
    private var prevCdReValue as Number = 0;


    // constricts the class instance and loads the settings from properties
    public function initialize() {
        load();
    }
    

    // function presets the settings
    // initialise settings for debugging only
    public function preset() {
        wuExType = TYPE_DISTANCE;
        wuExValue = 10;
        wuReType = TYPE_DISTANCE;
        wuReValue = 10;

        ruExType = TYPE_DISTANCE;
        ruExValue = 10;
        ruReType = TYPE_DISTANCE;
        ruReValue = 10;
        ruRepeats = 2;

        cdExType = TYPE_DISTANCE;
        cdExValue = 10;
        cdReType = TYPE_DISTANCE;
        cdReValue = 10;
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
        var isSettingsError =   
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


    // function creates a back copy of the settings
    // enables the restoration to a previous state
    public function backup() {
        prevWuExType = wuExType;
        prevWuExValue = wuExValue;
        prevWuReType = wuReType;
        prevWuReValue = wuReValue;
        prevRuExType = ruExType;
        prevRuExValue = ruExValue;
        prevRuReType = ruReType;
        prevRuReValue = ruReValue;
        prevRuRepeats = ruRepeats;
        prevCdExType = cdExType;
        prevCdExValue = cdExValue;
        prevCdReType = cdReType;
        prevCdReValue = cdReValue;
    }


    // function restores the settings to a previous backup
    public function restore() {
        wuExType = prevWuExType;
        wuExValue = prevWuExValue;
        wuReType = prevWuReType;
        wuReValue = prevWuReValue;
        ruExType = prevRuExType;
        ruExValue = prevRuExValue;
        ruReType = prevRuReType;
        ruReValue = prevRuReValue;
        ruRepeats = prevRuRepeats;
        cdExType = prevCdExType;
        cdExValue = prevCdExValue;
        cdReType = prevCdReType;
        cdReValue = prevCdReValue;
    } 


}