function [ octant ] = convert_angle_to_octant( angle )
%convert_angle_to_octant Summary of this function goes here
%   Detailed explanation goes here


if ((angle > -pi/8) && (angle <= pi/8))
  octant = 1;
elseif ((angle > pi/8) && (angle <= 3*pi/8))
  octant = 2;
elseif ((angle > 3*pi/8) && (angle <= 5*pi/8))
  octant = 3;
elseif ((angle > 5*pi/8) && (angle <= 7*pi/8))
  octant = 4;
elseif (abs(angle) > 7*pi/8)
  octant = 5;
elseif ((angle > -7*pi/8) && (angle <= -5*pi/8))
  octant = 6;
elseif ((angle > -5*pi/8) && (angle <= -3*pi/8))
  octant = 7;
else
  octant = 8;
end


end

