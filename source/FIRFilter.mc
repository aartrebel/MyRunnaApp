import Toybox.Lang;
import Toybox.System;

public const FIR_AVERAGE_OFF_10_FILTER = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1];

// class implements a FIR filter
class FIRFilter {
    private var _coefficients as Lang.Array?;
    private var _data as Lang.Array?;

    // initialises the FIR filter
    public function initialize(coefficients as Lang.Array) {
        _coefficients = coefficients;
        _data = new [_coefficients.size()];
        for (var n = 0; n < _data.size(); n++) {
            _data[n] = 0;
        }
    }

    // filter data as doubles

    // filter data as floats
    public function process(dataPoint as Lang.Float) as Lang.Float {
        var sum = 0;
        for (var n = _data.size()-1 ; n > 0; n--) {
            _data[n] = _data[n-1];
            sum += _coefficients[n] * _data[n];
        }
        _data[0] = dataPoint;
        return sum + (_coefficients[0] * dataPoint);
    }

}