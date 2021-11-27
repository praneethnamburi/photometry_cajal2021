fdir = 'C:\Users\Praneeth\Desktop\Cajal2021\20211125EPM\data\';
fname_vid = 'F0002_02_20211125-164719behaviour_cam.mp4';
fname_pos = 'F0002_02_20211125-164719behaviour_cam.txt';
fname_photo = 'F0002_02_20211125-164719_all.csv';

channels = [415, 470, 560];
flag_415 = 17;
flag_470 = 18;
flag_560 = 20;

region_red = 'Region0R';
region_green = 'Region1G';

t_start = 39; % s
photodata_target_sr = 30; % Hz

% read photometry data
photodata_all = readtable([fdir fname_photo]);
photodata_all.Timestamp = photodata_all.Timestamp - photodata_all.Timestamp(1);

photodata_sr = round(1/(numel(channels)*mean(diff(photodata_all.Timestamp - photodata_all.Timestamp(1))))); % for each channel
assert(photodata_sr == photodata_target_sr);

t_all = (0:floor(max(photodata_all.Timestamp)*photodata_sr)-1)'/photodata_sr;
photodata = table;
photodata.GCaMP6s = interp1( ...
    photodata_all.Timestamp(photodata_all.Flags == flag_470), ...
    photodata_all.(region_green)(photodata_all.Flags == flag_470), ...
    t_all, 'spline', 'extrap');
photodata.GCaMP6s_iso = interp1( ...
    photodata_all.Timestamp(photodata_all.Flags == flag_415), ...
    photodata_all.(region_green)(photodata_all.Flags == flag_415), ...
    t_all, 'spline', 'extrap');
photodata.jRGECO1a = interp1( ...
    photodata_all.Timestamp(photodata_all.Flags == flag_560), ...
    photodata_all.(region_red)(photodata_all.Flags == flag_560), ...
    t_all, 'spline', 'extrap');
photodata.jRGECO1a_iso = interp1( ...
    photodata_all.Timestamp(photodata_all.Flags == flag_415), ...
    photodata_all.(region_red)(photodata_all.Flags == flag_415), ...
    t_all, 'spline', 'extrap');

% Get a frame from the EPM video at start time
v = VideoReader([fdir, fname_vid]);
ref_img = rgb2gray(read(v, (t_start+10)*photodata_target_sr));

% Read tracking data
track = readtable([fdir, fname_pos]);

% grapple with differing number of frames in video and photometry data
assert(v.NumFrames == height(track));
if v.NumFrames > height(photodata)
    % DISCARD FRAMES IN THE END
    track = track(1:height(photodata), :);
elseif v.NumFrames < height(photodata)
    % DISCARD END OF PHOTOMETRY DATA
    photodata = photodata(1:height(track), :);
end

% find the time vector
assert(height(photodata) == height(track));
frame_num = (0:height(track)-1)';
t_vec = frame_num/photodata_target_sr;
frame_sel = t_vec >= t_start;

% only keep data from start time
t = t_vec(frame_sel);
photodata = photodata(frame_sel, :);
track = track(frame_sel, :);

%% Plot EPM reference image and tracks
figure;
subplot(1, 2, 1);
imagesc(ref_img);
axis equal;
colormap gray;
hold all;
plot(track.mouseX, track.mouseY);
axis off;

% plot raw GCaMP6s and jRGECO1a signals
subplot(1, 2, 2);
yyaxis left;
plot(t, photodata.GCaMP6s);
yyaxis right;
plot(t, photodata.jRGECO1a);

%% detrend using airPLS algorithm
blFilter_dur = 60; % s
photodata_trend = table;
photodata_detrend = table;
for i = 1:length(photodata.Properties.VariableNames)
    dim_name = photodata.Properties.VariableNames{i};
    if ~strcmp(dim_name, 't')
        [res_sub, trend] = airPLS(photodata.(dim_name)', 10e8);
        photodata_trend.(dim_name) = trend';
        photodata_detrend.(dim_name) = res_sub';
    end
end

% plot the signal and the trend to check
figure;
ndim = length(photodata.Properties.VariableNames);
for i = 1:ndim
    subplot(ndim, 1, i);
    dim_name = photodata.Properties.VariableNames{i};
    plot(t, photodata.(dim_name));
    hold all;
    plot(t, photodata_trend.(dim_name));
    title(dim_name);
end

%% Regress the isosbestic signal from the reference
photodata_reg = table;
[b, ~, r] = regress(photodata_detrend.GCaMP6s, [photodata_detrend.GCaMP6s_iso, ones(length(t), 1)]);
photodata_reg.GCaMP6s = r+b(2);
[b, ~, r] = regress(photodata_detrend.jRGECO1a, [photodata_detrend.jRGECO1a_iso, ones(length(t), 1)]);
photodata_reg.jRGECO1a = r+b(2);

figure;
subplot(2, 1, 1);
plot(t, photodata_detrend.GCaMP6s);
hold all;
plot(t, photodata_reg.GCaMP6s);
title('GCaMP6s');

subplot(2, 1, 2);
plot(t, photodata_detrend.jRGECO1a);
hold all;
plot(t, photodata_reg.jRGECO1a);
title('jRGECO1a');
