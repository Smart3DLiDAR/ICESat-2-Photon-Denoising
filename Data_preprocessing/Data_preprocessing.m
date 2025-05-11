clear
close all;
clc
%%
atl03path = "F:\lunwen\code\h5_data\ATL03_20190603025340_10050314_002_01.h5"; % ATL03 filepath
atl08path = "F:\lunwen\code\h5_data\ATL08_20190603025340_10050314_002_01.h5"; % ATL08 filepath

% creates Atl03 and Atl08 objects 
a3 = Atl03(atl03path);
a8 = Atl08(atl08path);

% ATL03 - basic attributes  
disp(a3)
a3.showinfo() % detailed attributes/values
% ATL08
disp(a8)
a8.showinfo()

% Display structural track structure
gt = gtrack('gt1r',a3,a8);
disp(gt)
format('bank') % for presentation purposes only - values formatted with 2 decimal places
rpc = gt.getrawpc(); % gets the raw point cloud  

% display table columns
disp(string(rpc.Properties.VariableNames)')
disp(rpc(1:5,1:7))
 
% % Filter data
% lat_range = rpc{:,6} >= 44.886 & rpc{:,6} <= 44.900;
% filtered_rpc = rpc(lat_range, :);
% orig_dist = filtered_rpc{:,3};
% new_dist = orig_dist - orig_dist(1);
% filtered_rpc{:,3} = new_dist;
% disp(filtered_rpc(1:5, :))

figure;
scatter(rpc{:,3}, rpc{:,7}, 10, '.');
xlabel('Along-track Distance');
ylabel(rpc.Properties.VariableNames{7});

% Saving attribute data
sample=rpc{:, [3, 7]};
pc_fn = './Sample/Sample_tbl.csv'; 
writematrix(sample,pc_fn) % writes the classified pc
