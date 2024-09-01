import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Math;

class ExerciseInputDelegate extends ValueInputDelegate {

    //const SCR_SIZE = 240;
    //const TOP_LEFT_DIGITS = [7, 8, 9];
    //const BOTTUM_LEFT_DIGITS = [0, 1, 2];
    //const BOTTUM_RIGHT_DIGITS = [2, 3, 4];
    //const TOP_RIGHT_DIGITS = [5, 6, 7];

    //private var _innerRadius as Double?;
    //private var _coords as Array?;
    //private var _digits as Array?;
    //private var _onDigit as Method?;
    //private var _onEnter as Method?;
    //private var _onBackSpace as Method?;

    private var _inputModeChangeHandler as Method?;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    //public function setViewParams(innerRadius as Double, coords as Array, digits as Array, onDigit as Method, 
    //        onEnter as Method, onBackSpace as Method) as Void {
    //    _coords = coords;
    //    _digits = digits;
    //    _onDigit = onDigit;
    //    _onEnter = onEnter;
    //    _onBackSpace = onBackSpace;
    //    _innerRadius = innerRadius;
    //}

    //private function findNearest(x as Number, y as Number, digitIndexes as Array) as String {
    //    var nearestD = SCR_SIZE;
    //    var nearestI = 0;
    //    for (var n=0; n<digitIndexes.size(); n++) {
    //        var coord = _coords[digitIndexes[n]] as Array<Number>;
    //        var d = Math.sqrt((coord[0]-x)*(coord[0]-x) + (coord[1]-y)*(coord[1]-y));
    //        if (d < nearestD) {
    //            nearestD = d;
    //            nearestI = digitIndexes[n];
    //        }
    //    }
    //    return _digits[nearestI];
    //}


    // Handle the select behaviour
    //public function onSelect() as Boolean {
    //   return false;
    //}


    // handle the tap action
    //public function onTap(click as ClickEvent) as Boolean {
    //    var tapCoord = click.getCoordinates();
    //    var x = tapCoord[0] - SCR_SIZE/2;
    //    var y = tapCoord[1] - SCR_SIZE/2; 

        // confirm inside inner circle
    //    var vector = Math.sqrt(x*x + y*y);
    //    if (vector < _innerRadius) {
    //        _onEnter.invoke();
    //    } else {
            //confirm top of bottum half
    //        if (y > 0) { //bottum
                // confirm left or right
    //            if (x > 0) { //right
    //                _onDigit.invoke(findNearest(x, y, BOTTUM_RIGHT_DIGITS));
    //            } else { //left
    //                _onDigit.invoke(findNearest(x, y, BOTTUM_LEFT_DIGITS));
    //            }
    //        } else { //top
    //            if (x > 0) { //right
    //                _onDigit.invoke(findNearest(x, y, TOP_RIGHT_DIGITS));
    //            } else { //left
    //                _onDigit.invoke(findNearest(x, y, TOP_LEFT_DIGITS));
    //            }
    //        }
    //    }
    //    return true;
    //}


    // Handle the back behaviour
    //public function onBack() as Boolean {
    //    return false;
    //}


    // Handle the touch screen swipe event
    //public function onSwipe(evt as SwipeEvent) as Boolean {
        //if (evt.getDirection() == SWIPE_LEFT) {
        //    _onBackSpace.invoke();
        //    return true;
        //} else {
        //    return false;
        //}
    //    return ValueInputDelegate.onSwipe(evt);
    //}


    // Handle the next page behaviour
    public function onNextPage() as Boolean {
        if (_inputModeChangeHandler != null) {
            _inputModeChangeHandler.invoke(true);
        }
        return true;
    }


    // Handle the previous page behaviour
    public function onPreviousPage() as Boolean {
        if (_inputModeChangeHandler != null) {
            _inputModeChangeHandler.invoke(false);
        }
        return true;
    }


}