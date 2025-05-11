function nPntSet = dp(pntSet, TH)
%--------------------------------------------------------------------------
% dp - Douglas-Peucker algorithm for simplifying a polyline
%
% pntSet : 2D data points representing the polyline
% TH     : Distance threshold
% Input:
%   pntSet : Nx2 matrix representing the 2D data points of the polyline
%   TH     : Distance threshold for simplification
%
% Output:
%   nPntSet: Mx2 matrix representing the simplified polyline
%--------------------------------------------------------------------------
% Vector operation: calculate the distance from all points to the line
% connecting the first and last points
vertV = [pntSet(end,2) - pntSet(1,2), -pntSet(end,1) + pntSet(1,1)];
baseL = abs(sum((pntSet - pntSet(1,:)) .* vertV ./ norm(vertV), 2));

if max(baseL) < TH 
    % If the distance is less than the threshold, return the first and last points
    nPntSet = [pntSet(1,:); pntSet(end,:)]; 
else
    % If the distance is greater than the threshold, divide into left and right branches
    % and recursively apply the algorithm
    maxPos = find(baseL == max(baseL), 1);
    L_PntSet = dp(pntSet(1:maxPos,:), TH);
    R_PntSet = dp(pntSet(maxPos:end,:), TH);
    nPntSet = [L_PntSet; R_PntSet(2:end,:)];
end
end
