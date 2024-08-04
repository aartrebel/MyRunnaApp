import Toybox.Graphics;
import Toybox.WatchUi;

class MyRunnaView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }


    // Callback for timer
    public function callback() as Void {
        WatchUi.requestUpdate();
    }


    // Load your resources here
    function onLayout(dc as Dc) as Void {
        //setLayout(Rez.Layouts.MainLayout(dc));
        System.println("Width = " + dc.getWidth()); //240
        System.println("height = " + dc.getHeight()); //240

        var distUnit = "km";
        var distUnitSize = dc.getTextDimensions(distUnit, Graphics.FONT_SMALL);
        var timeText = "0:00:00";
        var timeTextSize = dc.getTextDimensions(timeText, Graphics.FONT_NUMBER_HOT);
        var paceUnit = "/km";
        var paceUnitSize = dc.getTextDimensions(paceUnit, Graphics.FONT_SMALL);
        var paceText = "00:00";
        var paceTextSize = dc.getTextDimensions(paceText, Graphics.FONT_NUMBER_HOT);
        var distText = "0.00";
        var distTextSize = dc.getTextDimensions(distText, Graphics.FONT_NUMBER_HOT);

        System.println("Time text size =" + timeTextSize[0] + ";" + timeTextSize[1]); //192;76
        System.println("Pace text size =" + paceTextSize[0] + ";" + paceTextSize[1]); //144;76
        System.println("Pace unit text size =" + paceUnitSize[0] + ";" + paceUnitSize[1]); //45;30
        System.println("Dist text size =" + distTextSize[0] + ";" + distTextSize[1]); //112;76
        System.println("Dist unit text size =" + distUnitSize[0] + ";" + distUnitSize[1]); //36;30

        var timer = new Timer.Timer();
        timer.start(method(:callback), 1000, true);        
    }


    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }


    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        //View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var timeText = "0:00:00";
        var paceText = "00:00";
        var distText = "0.00";
        dc.drawText(120, 120+60, Graphics.FONT_NUMBER_HOT, paceText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(120, 120, Graphics.FONT_NUMBER_HOT, timeText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(120, 120-60, Graphics.FONT_NUMBER_HOT, distText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawText(120+(144/2), 120+60, Graphics.FONT_MEDIUM, " P", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(120+(192/2), 120, Graphics.FONT_MEDIUM, " T", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(120+(112/2), 120-60, Graphics.FONT_MEDIUM, " D", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(120-(192/2), 120, Graphics.FONT_MEDIUM, "> ", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(120-(112/2), 120-60, Graphics.FONT_MEDIUM, "> ", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        var stageText = "EX 1";
        dc.drawText(120, 120-105, Graphics.FONT_MEDIUM, stageText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        var gpsInd = "WALK";
        dc.drawText(120, 120+105, Graphics.FONT_MEDIUM, gpsInd, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
