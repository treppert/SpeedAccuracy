function [ octant ] = convert_tgt_angle_to_octant( angle )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

NUM_TRIAL = length(angle);
octant = NaN(NUM_TRIAL,1);

octLim = pi/8 * [(-7:2:-1) , (1:2:7)]

idx_oct1 = ( (angle > octLim(4)) & (angle < octLim(5)) );
idx_oct2 = ( (angle > octLim(5)) & (angle < octLim(6)) );
idx_oct3 = ( (angle > octLim(6)) & (angle < octLim(7)) );
idx_oct4 = ( (angle > octLim(7)) & (angle < octLim(8)) );
idx_oct5 = ( (angle > octLim(8)) | (angle < octLim(1)) );
idx_oct6 = ( (angle > octLim(1)) & (angle < octLim(2)) );
idx_oct7 = ( (angle > octLim(2)) & (angle < octLim(3)) );
idx_oct8 = ( (angle > octLim(3)) & (angle < octLim(4)) );

octant(idx_oct1) = 1;
octant(idx_oct2) = 2;
octant(idx_oct3) = 3;
octant(idx_oct4) = 4;
octant(idx_oct5) = 5;
octant(idx_oct6) = 6;
octant(idx_oct7) = 7;
octant(idx_oct8) = 8;

end%fxn:convert_tgt_angle_to_octant()

