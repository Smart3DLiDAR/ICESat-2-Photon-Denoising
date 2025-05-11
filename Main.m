clear
close all;
clc
%%  1.Isolated noise photons removal based on a multi-thresholding strategy 
data = readmatrix('.\Sample\Sample1_tbl.xlsx');

[idx, dist] = knnsearch(data, data, 'k', 55);
mdist = mean(dist(:, 2:end), 2);  %
dynamic_thresh = zeros(size(mdist));
window_size = 100;  
step_size =50;    
for i = 1:step_size:length(mdist)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    
    end_idx = min(i + window_size - 1, length(mdist));

    local_mdist = mdist(i:end_idx);  
    local_thresh = multithresh(local_mdist);    
    dynamic_thresh(i:end_idx) = local_thresh(1); 
end
clean_data = data(mdist < dynamic_thresh, :);

% figure;
% scatter(data(:,1), data(:,2), 20, 'g.');
% scatter(clean_data(:,1), clean_data(:,2), 20, 'r.');
% xlabel('Along-track distance(m)','FontSize', 14);
% ylabel('Elevation(m)','FontSize', 14);
% legend('Raw photons','FontSize', 14);
% set(gca,'FontName','Times New Roman','FontSize', 14);
%% 2.Adaptive calculation of terrain slopes and removal of low-density clustered noise photons
%%----Dividing the distance along the track---------------------------------------------------------------
max_distance = max(clean_data(:, 1)); 
interval_length = 50; 
num_intervals = ceil(max_distance / interval_length);
interval_boundaries = (0:num_intervals) * interval_length; 
interval_indices = discretize(clean_data(:, 1), interval_boundaries); 

% scatter(clean_data(:, 1), clean_data(:, 2),20, 'r.');
% hold on;
% for i = 2:length(interval_boundaries) - 1
%     line([interval_boundaries(i), interval_boundaries(i)], ylim, 'Color', 'r', 'LineStyle', '--');
% end
% xlabel('Along-track distance(m)','FontSize', 14);
% ylabel('Elevation(m)','FontSize', 14);
% set(gca,'FontName','Times New Roman','FontSize', 14);
% box on
% legend('Coarse signal photons');

%%----Calculate core photon points---------------------------------------------------------------
date = clean_data;
if isempty(date)
    error('Data read failed or data is empty.');
end
max_distance = max(date(:, 1));
% interval_length =50;
num_intervals = ceil(max_distance / interval_length);
interval_boundaries = (0:num_intervals) * interval_length;
interval_indices = discretize(date(:, 1), interval_boundaries, 'IncludedEdge', 'right');
signal_centers = [];  
hist_data = {};
interval_centers = [];
for i = 1:num_intervals
    current_interval_data = date(interval_indices == i, :);
    
    if isempty(current_interval_data)
        continue;
    end
    
    elevation_bins = min(current_interval_data(:, 2)):1:max(current_interval_data(:, 2));  
    elevation_hist = histcounts(current_interval_data(:, 2), elevation_bins);
    
    [~, max_idx] = max(elevation_hist);
    center_elevation = elevation_bins(max_idx);
    
    [~, min_dist_idx] = min(abs(current_interval_data(:, 2) - center_elevation));
    signal_center = current_interval_data(min_dist_idx, :);
    
    signal_centers = [signal_centers; signal_center];
    
    if i <= 2
        hist_data{end+1} = struct('elevation_bins', elevation_bins, 'elevation_hist', elevation_hist);
        interval_centers(end+1) = (interval_boundaries(i) + interval_boundaries(i+1)) / 2;
    end
end

%%----Douglas-Peucker algorithm merges similar terrain segments---------------------------------------------------------------
signalcenter=signal_centers;
pntSet=signalcenter(:,1:2);
nPntSet=dp(pntSet,0.5);

%%----Calculate the slope of the merged terrain---------------------------------------------------------------
points =nPntSet;
num_points = size(points, 1);
angles = zeros(num_points - 1, 1);
for i = 1:num_points - 1
    delta_x = points(i+1, 1) - points(i, 1);
    delta_y = points(i+1, 2) - points(i, 2);
    angles(i) = rad2deg(atan2(delta_y, delta_x));
end
angles = mod(angles, 180);
angles = [angles(1); angles; angles(end)];
disp(angles);

date =clean_data;
split_distances = nPntSet(:, 1);
split_indices = zeros(numel(split_distances), 1);
for i = 1:numel(split_distances)
    [~, split_indices(i)] = min(abs(date(:, 1) - split_distances(i)));
end

%%----Assign the value of the angle to each segment.---------------------------------------------------------------
segments = cell(numel(split_distances) + 1, 1);
for i = 1:numel(split_distances)+1
    if i == 1
        indices = 1:split_indices(1);
    elseif i == numel(split_distances)+1
        indices = split_indices(end):size(date, 1);
    else
        indices = split_indices(i-1):split_indices(i);
    end
    segments{i} = date(indices, :);
end
for i = 1:numel(segments)
    angle = angles(i);

    segments{i} = [segments{i}, repmat(angle, size(segments{i}, 1), 1)];
end
totalRows = 0;
maxCols = 0;
for i = 1:numel(segments)
    [rows, cols] = size(segments{i});
    totalRows = totalRows + rows;
    maxCols = max(maxCols, cols);
end

bigMatrix = zeros(totalRows, maxCols);
currentRow = 1;
for i = 1:numel(segments)
    currentMatrix = segments{i};
    [rows, cols] = size(currentMatrix);
    bigMatrix(currentRow:currentRow+rows-1, 1:cols) = currentMatrix;
    currentRow = currentRow + rows;
end

%%----The iterative ellipse-based connected growth method---------------------------------------------------------------
segments = bigMatrix;
a=24;
b=a/6;
[E, I] = processSegments(segments,a,b);
minpts=8;
[IDX, isnoise, signalPoints, noisePoints]= Ellipticalclustering(E, I, minpts, segments);
% figure;
% scatter(signalPoints(:,1),signalPoints(:,2), 20, 'r.');
% hold on;
% scatter(noisePoints(:,1),noisePoints(:,2), 20, 'g.');
% xlabel('Along-track distance(m)','FontSize', 14);
% ylabel('Elevation(m)','FontSize', 14);
% legend('Iteration results','FontSize', 14);
% set(gca,'FontName','Times New Roman','FontSize', 14);
% box on
% hold off;
%% 3.Outer clustered noise photons removal based on the box plots analysis
data=signalPoints;
window_size =150; 
min_dist = min(data(:,1));
max_dist = max(data(:,1));
cleaned_data = [];
outliers_data = [];
all_window_elevations = {};
window_number = 1;

for start_dist = min_dist:window_size:max_dist
    end_dist = start_dist + window_size;
        window_indices = data(:,1) >= start_dist & data(:,1) < end_dist;
    window_photons = data(window_indices, :);
    
    if ~isempty(window_photons)
        all_window_elevations{window_number} = window_photons(:,2);
        
        Q1 = prctile(window_photons(:,2),25);
        Q3 = prctile(window_photons(:,2),75);
        IQR = Q3 - Q1;
        
        Upperlimit = Q3 + 3 * IQR;
        Lowerlimit = Q1 - 3* IQR;
        
        non_outliers = window_photons(:,2) >= Lowerlimit & window_photons(:,2) <= Upperlimit;
        cleaned_data = [cleaned_data; window_photons(non_outliers, :)];
        outliers_data = [outliers_data; window_photons(~non_outliers, :)];
    end

    window_number = window_number + 1;
end

%  Signal=1, noise=0
lable = readmatrix('.\Sample\Sample1_tbl.xlsx');
signal = signalPoints; 
% signal = cleaned_data; 
lable(:, end+1) = 0;
for i = 1:size(signal, 1)
    idx = find(lable(:, 1) == signal(i, 1) & lable(:, 2) == signal(i, 2));
    if ~isempty(idx)
        lable(idx, end) = 1;
    end
end   
figure;
hold on;
scatter(lable(lable(:, end) == 1, 1), lable(lable(:, end) == 1, 2),20, 'r.');
scatter(lable(lable(:, end) == 0, 1), lable(lable(:, end) == 0, 2),20, 'g.');
xlabel('Along-track distance(m)','FontSize', 14);
ylabel('Elevation(m)','FontSize', 14);
legend('Signal photons','Noise photons','FontSize', 14);
set(gca,'FontName','Times New Roman','FontSize', 14);
box on
xlim([0, 1500]);
% ylim([1250, 1550]);
ax = gca;
axPos = ax.Position; 
