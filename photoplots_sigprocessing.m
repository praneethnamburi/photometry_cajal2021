figure;
ndim = length(photodata_reg.Properties.VariableNames);
hax = [];
for i = 1:ndim
    hax(i) = subplot(ndim, 1, i);
    dim_name = photodata_reg.Properties.VariableNames{i};
    plot(t, photodata_reg.(dim_name));
%     hold all;
%     plot(t, photodata_trend.(dim_name));
    title(dim_name, 'Interpreter', 'none');
end
linkaxes(hax, 'x');
sgtitle(m.MouseID);
xlim([400 600]);

%%
figure;
hax1 = subplot(2, 1, 1);
plot(t, photodata_detrend.GCaMP6s);
hold all;
plot(t, photodata_reg.GCaMP6s);
title('GCaMP6s aIC-BLA');
legend({'detrend', 'detrend+regress'});

hax2 = subplot(2, 1, 2);
plot(t, photodata_detrend.jRGECO1a);
hold all;
plot(t, photodata_reg.jRGECO1a);
title('jRGECO1a aIC-CeM');
legend({'detrend', 'detrend+regress'});

linkaxes([hax1, hax2], 'x');
xlim([400 600]);

%%
figure;
hax1 = subplot(2, 1, 1);
plot(t, photodata_reg.GCaMP6s);
hold all;
plot(t, photodata_bandpass.GCaMP6s);
title('GCaMP6s aIC-BLA');
legend({'detrend+regress', 'detrend+regress+bandpass0.2-6'});

hax2 = subplot(2, 1, 2);
plot(t, photodata_reg.jRGECO1a);
hold all;
plot(t, photodata_bandpass.jRGECO1a);
title('jRGECO1a aIC-CeM');
legend({'detrend+regress', 'detrend+regress+bandpass0.2-6'});

linkaxes([hax1, hax2], 'x');
xlim([400 600]);
sgtitle(m.MouseID);

%%
figure;
hax1 = subplot(2, 1, 1);
plot(t, photodata_reg.GCaMP6s);
hold all;
plot(t, smooth(photodata_reg.GCaMP6s, 10));
title('GCaMP6s aIC-BLA');
legend({'detrend+regress', 'detrend+regress+smooth'});

hax2 = subplot(2, 1, 2);
plot(t, photodata_reg.jRGECO1a);
hold all;
plot(t, smooth(photodata_reg.jRGECO1a, 10));
title('jRGECO1a aIC-CeM');
legend({'detrend+regress', 'detrend+regress+smooth'});

linkaxes([hax1, hax2], 'x');
xlim([400 600]);
sgtitle(m.MouseID);