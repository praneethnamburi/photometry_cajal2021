m = mDb(strcmp({mDb.MouseID}, 'F0002'));

GCaMP_color = [0.4660, 0.6740, 0.1880];
jRGECO_color = [0.6350, 0.0780, 0.1840];

BLA_color = [0, 0.4470, 0.7410];
CeM_color = [0.6350, 0.0780, 0.1840]; %[0.8500, 0.3250, 0.0980];

track_line_color = [0.9290, 0.6940, 0.1250];
centroid_color = [0.3010, 0.7450, 0.9330];

roi_names = {'open_arm', 'closed_arm', 'center'};
% roi_names = {'open_arm_top', 'open_arm_bottom', 'closed_arm_left', 'closed_arm_right', 'center'};
figure('Units','normalized','OuterPosition',[0, 0, 1, 1]);
axEntry = subplot(3, 1, 1);
for roiCount = 1:length(roi_names)
    plot(m.EPM.t, m.EPM.track.(roi_names{roiCount}) - 1.2*roiCount); 
    hold all;
end
ylim([-1.2*roiCount-0.2, 0]);
legend(roi_names, 'Interpreter', 'none');
xlabel('Time(s)');
title(m.MouseID);

axBLA = subplot(3, 1, 2);
if strcmp(m.GCaMP6s, 'aIC_BLA')
    yl_prefix = 'GCaMP6s';
else
    yl_prefix = 'jRGECO1a';
end
plot(m.EPM.t, m.EPM.aIC_BLA, LineWidth=1.5, color=BLA_color);
xlabel('Time (s)');
ylabel([yl_prefix '  Fluorescence (a.u.)']);
title('aIC-BLA');

axCeM = subplot(3, 1, 3);
if strcmp(m.GCaMP6s, 'aIC_CeM')
    yl_prefix = 'GCaMP6s';
else
    yl_prefix = 'jRGECO1a';
end
plot(m.EPM.t, m.EPM.aIC_CeM, LineWidth=1.5, color=CeM_color);
xlabel('Time (s)');
ylabel([yl_prefix '  Fluorescence (a.u.)']);
title('aIC-CeM');

linkaxes([axEntry, axBLA, axCeM], 'x');