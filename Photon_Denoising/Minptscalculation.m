%%  Adaptive computation minpts
data = readmatrix('.\Sample\Sample1_tbl.xlsx');
along_track = data(:,1);  
elevation = data(:,2);    

% (A) Vertically divided into M segments
M = 50;
min_elevation = min(elevation); 
max_elevation = max(elevation); 
Rg = max_elevation - min_elevation;  
h = Rg / M;  % The elevation length of each vertical segment

% Divide the elevation into M segments
edges = linspace(min_elevation, max_elevation, M+1);  % Boundary of segment M
[counts, ~] = histcounts(elevation, edges);  % The number of photons in each vertical segment

Nt = length(elevation);  % Total number of photons
avg_photon_count = Nt / M;  % The average number of photons per segment

% figure;
% histogram('BinEdges', edges, 'BinCounts', counts);
% xlabel('Elevation (m)');
% ylabel('Photon Count');
% title('Photon Count Per Vertical Segment');

% (B) Calculate M1, M2, N1, N2
M2 = sum(counts < avg_photon_count);  % The number of segments M2 where the photon count is below the average value.
M1 = M - M2;  % The number of segments M1 where the photon count is greater than the average value.

N2 = sum(counts(counts < avg_photon_count));  % Total number of photons N2 in stage M2
N1 = Nt - N2;  % Total number of photons in segment M1, N1

% (C) Calculate the photon densities ρ1 and ρ2.
l = max(along_track) - min(along_track);  
rho2 = N2 / (h * l * M2);  % Photon density of noise photons
rho1 = N1 / (h * l * M1);  % Photon density of signals and noise photons

% (D) Calculate the expected number of noise photons and signal photons
a=24;
b=a/6;
S=pi *a*b;

SN2 = rho2 * S;  % Expected number of noise photons
SN1 = rho1 * S;  % The expected number of signal and noise photons
expected_signal = SN1 - SN2;  % Expected number of signals

% (E) Calculate MinPts
MinPts = (2 * SN1 - SN2 + log(M2)) / log(2 * SN1 / SN2);

fprintf('Photon count threshold (MinPts): %.2f\n', MinPts);
