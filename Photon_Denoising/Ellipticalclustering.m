function [IDX, isnoise, signalPoints, noisePoints] = Ellipticalclustering(E, I, minpts, bigMatrix)
    n = size(E, 1);          % Get the number of points
    IDX = zeros(n, 1);       % Initialize cluster class labels
    isnoise = false(n, 1);   % Initialize exception point label
    signalPoints = [];       % Initialize the coordinate matrix for the storage signal points.
    noisePoints = [];        % Initialize the coordinate matrix for storing noise points.

    C = 0;                   % Initialize the number of clusters

    visited = false(n, 1);   % Initialize access token

    for i = 1:n              % Traverse all points
        if ~visited(i)       
            visited(i) = true;  % Marked as visited

            if E(i) >=minpts  % If the number of field points at the current point is greater than or equal to mpts.
                C = C + 1;  % New cluster type
                IDX(i) = C; % Mark this point as the core point of the current cluster.
                signalPoints = [signalPoints; bigMatrix(i,:)]; 

                ExpandCluster(i, C);  % Expand cluster type
            else
                isnoise(i) = true;  % Marked as noise point
                noisePoints = [noisePoints; bigMatrix(i,:)]; % Add the coordinates of the noise points to the noise point matrix.
            end
        end
    end

    function ExpandCluster(i, C)
        queue = {i};  % Used to save points that are to be expanded.

        while ~isempty(queue)  
            point = queue{1}; 
            queue(1) = [];      

            neighbors = I{point};  % Obtain the indices of the neighboring points of this point

            for j = 1:numel(neighbors)  % Traverse the neighboring points of this point.
                if ~visited(neighbors(j))  
                    visited(neighbors(j)) = true;  

                    if E(neighbors(j)) >= minpts  
                        IDX(neighbors(j)) = C;   % Mark this point as part of the current cluster.
                        queue{end+1} = neighbors(j);  % Add this point to the expansion queue.
                        signalPoints = [signalPoints; bigMatrix(neighbors(j),:)];
                    else
                        isnoise(neighbors(j)) = true;  % Marked as noise point
                        noisePoints = [noisePoints; bigMatrix(neighbors(j),:)]; 
                    end
                end
            end
        end
    end
end

