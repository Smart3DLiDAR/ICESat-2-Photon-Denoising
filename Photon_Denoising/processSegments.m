function [E, I] = processSegments(segments,a,b)
% Get the size of segments
[numPoints, ~] = size(segments);

% % Initialize a matrix for storing counts and indices
E = zeros(numPoints, 1);
I = cell(numPoints, 1);

% Define the long semi-axis and short semi-axis of an ellipse
semiMajorAxis = a; 
semiMinorAxis = b;  

% Iterate through each photon point
for i = 1:numPoints
    xi = segments(i, 1);
    yi = segments(i, 2);

    % Calculate the standard elliptical boundary
    theta = linspace(0, 2 * pi, 100);
    xEllipse = semiMajorAxis * cos(theta);
    yEllipse = semiMinorAxis * sin(theta);

    % Get the current point's rotation angle (in radians).
    rotationAngle = deg2rad(segments(i, 3));


    % Create a rotation matrix
    rotationMatrix = [cos(rotationAngle),  -sin(rotationAngle); sin(rotationAngle), cos(rotationAngle)];

    % Rotate the ellipse to the specified angle
    rotatedEllipse = rotationMatrix * [xEllipse; yEllipse];

    % Convert the ellipse to the position of the point
    xEllipse = rotatedEllipse(1, :) + xi;
    yEllipse = rotatedEllipse(2, :) + yi;

    % Find points within the boundary of the ellipse.
    withinEllipse = inpolygon(segments(:, 1), segments(:, 2), xEllipse, yEllipse);

    % Calculate the number of points inside the ellipse
    count = sum(withinEllipse); % Including the point itself

    % Store the count in matrix E.
    E(i) = count;

    % Find the indices of neighboring photon points.
    neighborIndices = find(withinEllipse);
    I{i} = neighborIndices;
end
end

