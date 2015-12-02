classdef viscoStatus
    properties
        motorStatus  %Staus for motor. true if on, else off
        FSRStatus    %Full scale range status. True if over FSR, else valid
        ValueLimitsStatus %True if outside limits, else within
        calibrationError  % True if error in calibration
    end
end