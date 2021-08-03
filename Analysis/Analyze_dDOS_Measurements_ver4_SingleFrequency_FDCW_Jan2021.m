%This code loads the processed OP/amp/phase/ data from the healthy
%volunteer study and plots the resulting changes in OP/chromophores over
%the selcted trial. The trail must be manually selected by chooseing the
%start and sweep parameters 
%The resutls from the script were used to calculate changes in
%oxy./doexy/total during intermittant and sustained flexions
%also figure 7 (subject 9 sustained flexion 2 (starts at 2601))
%figure 5 (sustained flexion -> suject 2 flexion2, intermittant flexion
%subject 1 -> 1st flexion
%last updated REI 5/11/2021

clear all
close all
%wavelengths  = [ 690 730  785 808 830 850];
wavelengths = [ 730  850];

%adjustable parameters
start=9801;
sweep =5999; %1199 for sustained 5999 for intermittant
span= 600; % filter span ( 20 for sustained 600 for intermittant)
SDsep = 25;
deltamua =0;
fs= 10;
flexion_start = 0; %350;

begin=362;
flexend=540;


%loading processed data
%cd 'U:\dDOSI\Data\SCM Test\Paired Down Results'
%cd 'U:\dDOSI\Data\SCM Healthy Volunteer Study 2020\Paired Down OPs'
cd 'U:\dDOSI\Data\SCM Healthy Volunteer Study 2020\Data\Processed\MC LUT OPs'
%cd 'U:\eng_research_roblyer\dDOSI\Data\SCM Test\Paired Down Results'
load Subject02
% mua = FinalData.mua';
% musp =FinalData.musp';
% amp =FinalData.amp';

mua = OP_Data.mua';
musp = OP_Data.musp';
amp =OP_Data.amp';
phase = rad2deg(OP_Data.phase');

%if delta mua is check uses CW to clauclate changes delta mua
if deltamua == 1
    %calcualte delta mua using constant 4 DPF
    DPF =4;  
    L_eff = SDsep*DPF;
%     %calculate delta mua using raw amplitude
 % L_eff =3.*musp(start,:)*SDsep^2./(2*(SDsep*(sqrt(3*mua(start,:).*musp(start,:)))+1));
%   
%     DPF = L_eff ./SDsep;
%     DPF2= sqrt(3.*musp(start,:))./(2.*sqrt(mua(start,:))); %infinite
%     DPF3 = sqrt(3*musp(start,:))./(2*sqrt(mua(start,:))).*(1-1./(1+SDsep.*sqrt(3.*mua(start,:).*musp(start,:))));
   
    for i = start: start+sweep
        l_eff (i,:) =3.*musp(i,:)*SDsep^2./(2*(SDsep*(sqrt(3*mua(i,:).*musp(i,:)))+1));
        dpf(i,:) = l_eff(i,:)./SDsep;
        
        DeltaMua(i,:) = 1./L_eff.*log(amp(start,:)./amp(i,:));
        mua(i,:) = mua(start,:) + DeltaMua(i,:);
    end
end


%calculate chromophores
%assume X% water and Y% lipids"
extinction  = getExtinctionCoefs('Chromophores_ZijlstraKouVanVeen.txt', wavelengths);
extinction (:,1:2)  = extinction(:,1:2) /1000; % convert to uM

%water: Kou (mm-1)
waterfraction = (0.73+0.52)/2; %Bashkatov 2011
water730 = waterfraction * 0.00197441;
water850 = waterfraction * 0.004199792 ;

%lipid: ZijstraVanVeen (mm-1)
lipidfraction = 0.2;
lipid730 = lipidfraction * extinction(1,4);
lipid850 = lipidfraction * extinction(2,4) ;

%subtract water and lipid to provide a better fit
corrected_mua(:,1) = mua(:,1) - water730 - lipid730;
corrected_mua(:,2) = mua(:,2) - water850 - lipid850;

if deltamua == 1
    %subtract water and lipid to provide a better fit
    corrected_deltamua(:,1) = DeltaMua(:,1) - water730 - lipid730;
    corrected_deltamua(:,2) = DeltaMua(:,2) - water850 - lipid850;
end


%fit for oxty and deoxy
chromophores= extinction(:,1:2) \corrected_mua'; %either mua or corrected mua for water lipid subtraction
%chromophores= extinction(:,1:2) \corrected_deltamua'; %either mua or corrected mua for water lipid subtraction
oxy = chromophores(1,:);
deoxy = chromophores(2,:);
total = oxy+ deoxy;
osat = oxy./total *100;

time = 100/1000:100/1000:10000;
%time = 31/100:31/100:1000;

%post processing analysis
oxy_smoothed = smooth (oxy(start:start+sweep),span);
deoxy_smoothed = smooth (deoxy(start:start+sweep),span );
total_smoothed = smooth (total(start:start+sweep),span );

%loess filer (not used)
oxy_loess = smooth (oxy(start:start+sweep),span,  'loess');
deoxy_loess = smooth (deoxy(start:start+sweep),span, 'loess');
total_loess = smooth (total(start:start+sweep),span, 'loess');

%lowess filer *****
oxy_lowess = smooth (oxy(start+flexion_start:start+sweep),span,  'lowess');
deoxy_lowess = smooth (deoxy(start+flexion_start:start+sweep),span, 'lowess');
total_lowess = smooth (total(start+flexion_start:start+sweep),span, 'lowess');

%findpeaks method (not used)
[deoxy_peaks, deoxy_locations] = findpeaks(deoxy(start:start+sweep),'MinPeakDistance', 50);
[total_peaks, total_locations] = findpeaks(total(start:start+sweep),'MinPeakDistance', 50);

time_deoxypeaks = deoxy_locations/fs;
time_totalpeaks =total_locations/fs;

deoxy_peaks_lowess = smooth (deoxy(start+deoxy_locations-1),20, 'lowess');
total_peaks_lowess = smooth (total(start+total_locations-1),20, 'lowess');

%stats
baseline_length = 101:200;
recovery_length = 300;

%calculated average values at baseline and recovery (not used)
baseline.oxy = mean(oxy(start+baseline_length(1):start+baseline_length(end)));
baseline.deoxy = mean(deoxy(start+baseline_length(1):start+baseline_length(end)));
baseline.total = mean(total(start+baseline_length(1):start+baseline_length(end)));
recovery.oxy = mean(oxy(start+sweep-recovery_length:start+sweep));
recovery.deoxy = mean(deoxy(start+sweep-recovery_length:start+sweep));
recovery.total = mean(total(start+sweep-recovery_length:start+sweep));
flexion.oxy = min(oxy_lowess);


%max - average baseline
delta_oxy.method1 = min(oxy_lowess) - mean (oxy(start+baseline_length(1):start+baseline_length(end)));
delta_deoxy.method1 = max(deoxy_lowess) - mean (deoxy(start+baseline_length(1):start+baseline_length(end)));
delta_total.method1 = max(total_lowess) - mean (total(start+baseline_length(1):start+baseline_length(end)));
delta_deoxy.method2 = max(deoxy_peaks_lowess) - mean (deoxy(start+baseline_length(1):start+baseline_length(end)));
delta_total.method2 = max(total_peaks_lowess) - mean (total(start+baseline_length(1):start+baseline_length(end)));

%find maximum and index

[maximum.deoxy1, time_index_deoxy.method1] = max(deoxy_lowess);
[maximum.total, time_index_total.method1] = max(total_lowess);
[maximum.oxy, time_index_oxy.method1] = min(oxy_lowess); %this is a minimum
% [deoxymaximum.method2, time_index_deoxy.method2] = max(deoxy_peaks_lowess);
% [totalmaximum.method2, time_index_total.method2] = max(total_peaks_lowess);

%convert to seconds
time_delta.deoxy = time_index_deoxy.method1/10; 
time_delta.total = time_index_total.method1/10; 
time_delta.oxy = time_index_oxy.method1/10;
% time_delta_deoxy.method2 = time_deoxypeaks(time_index_deoxy.method2) - 30;
% time_delta_total.method2 = time_totalpeaks(time_index_total.method2) - 30;

%(baseline) averages and SDs
avg.mua = mean(mua(start:start+sweep,:));
avg.musp = mean(musp(start:start+sweep,:));
avg.oxy = mean(oxy(start:start+sweep));
avg.deoxy = mean(deoxy(start:start+sweep));
avg.total = mean(total(start:start+sweep));
avg.osat = mean(osat(start:start+sweep));
SD.mua = std(mua(start:start+sweep,:));
SD.musp = std(musp(start:start+sweep,:));
SD.oxy = std(oxy(start:start+sweep));
SD.deoxy = std(deoxy(start:start+sweep));
SD.total = std(total(start:start+sweep));
SD.osat = std(osat(start:start+sweep));

%flexion start
flexion_baseline.deoxy = deoxy_lowess(1);
flexion_baseline.total = total_lowess(1);
flexion_baseline.oxy = oxy_lowess(1);



% relative SNR
dark = mean(amp(end-99:end,:));
%dark = mean(amp(3801:3899,:)); %subject04
SNR = amp./dark;

%plotting**********%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%relative SNR
figure
plot(time(1:sweep+1), SNR(start:start+sweep, :))
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410;  0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;   0.8500 0.3250 0.0980;  0.6350 0.0780 0.1840]);
% hold on
% plot(time(1:sweep+1), 10, 'k--')
legend('730nm', '850nm')
xlabel('Time (s)')
ylabel('SNR')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)

%amplitude (figure 7)
figure
plot(time(1:sweep+1), amp(start:start+sweep, :))
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410;  0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;   0.8500 0.3250 0.0980;  0.6350 0.0780 0.1840]);
c= colororder([ 0.8 0.5 0; 0.6 0 0.3]);
legend('730nm', '850nm')
xlabel('Time (s)')
ylabel('Amplitude')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)

%phase 
figure
plot(time(1:sweep+1), abs(phase(start:start+sweep, 1)))
hold on
ylabel('Phase (degrees)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
plot(time(1:sweep+1), abs(phase(start:start+sweep, 2)))
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410;  0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;   0.8500 0.3250 0.0980;  0.6350 0.0780 0.1840]);
c= colororder([ 0.8 0.5 0; 0.6 0 0.3]);
xlabel('Time (s)')
ylabel('Phase (degrees)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24,'yticklabel', []);

%phase (figure 7)
figure
plot(time(1:sweep+1), phase(start:start+sweep, 1)- phase(start, 1))
hold on
ylabel('Phase (degrees)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
c= colororder([ 0.8 0.5 0; 0.6 0 0.3]);
plot(time(1:sweep+1), phase(start:start+sweep, 2) - phase(start, 2)+2)
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410;  0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;   0.8500 0.3250 0.0980;  0.6350 0.0780 0.1840]);
%c= colororder([0.8 0.5 0]);
xlabel('Time (s)')
ylabel('Phase (degrees)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24,'yticklabel', []);

%mua (figure 7)
figure
plot(time(1:sweep+1), mua(start:start+sweep, :))
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410;  0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;   0.8500 0.3250 0.0980;  0.6350 0.0780 0.1840]);
c= colororder([ 0.8 0.5 0; 0.6 0 0.3]);
legend('730nm', '850nm')
xlabel('Time (s)')
ylabel('\mu_a (mm^-^1)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)

%musp (figure 7)
figure
plot(time(1:sweep+1), musp(start:start+sweep,:))
legend('730nm', '850nm')
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410;  0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;   0.8500 0.3250 0.0980;  0.6350 0.0780 0.1840]);
c= colororder([ 0.8 0.5 0; 0.6 0 0.3]);
xlabel('Time (s)')
ylabel('\mu_s'' (mm^-^1)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)

% oxy and deoxy (figure 7 for both CW and CS modalities)
figure
plot(time(1:sweep+1), oxy(start:start+sweep), 'r-')
hold on
plot(time(1:sweep+1), deoxy(start:start+sweep), 'b-')
xlabel('Time (s)')
ylabel('Hb + Mb (\muM)')
legend('oxy', 'deoxy')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
ylim([0 200])

%just deoxy
figure
plot(time(1:sweep+1), deoxy(start:start+sweep), 'b-')
xlabel('Time (s)')
ylabel('Hb + Mb (\muM)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)

%total 
figure
plot(time(1:sweep+1), total(start:start+sweep))
xlabel('Time (s)')
ylabel('Total (\muM)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)

%oxygen saturation
figure
plot(time(1:sweep+1), osat(start:start+sweep))
xlabel('Time (s)')
ylabel('StO_2 (%)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)


% figure
% plot(time(1:sweep+1), deoxy_smoothed)
% xlabel('Time (s)')
% ylabel('Deoxy (\muM)')
% set(gca, 'FontName', 'Arial', 'FontSize' ,24)
% 
% figure
% plot(time(1:sweep+1), total_smoothed)
% xlabel('Time (s)')
% ylabel('Total (\muM)')
% set(gca, 'FontName', 'Arial', 'FontSize' ,24)

%Deoxy (figure 5)
figure
plot(time(1:sweep+1), deoxy(start:start+sweep), 'b-')
hold on
plot(time(flexion_start+1:sweep+1), deoxy_lowess, 'k-', 'LineWidth', 3)
% hold on
% plot(time_deoxypeaks, deoxy_peaks_lowess, 'm-', 'LineWidth', 3)
xlabel('Time (s)')
ylabel('Deoxy[Hb+Mb] (\muM)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)

%total (figure 5)
figure
plot(time(1:sweep+1), total(start:start+sweep), '-')
hold on
plot(time(flexion_start+1:sweep+1), total_lowess, 'k-', 'LineWidth', 3)
% hold on
% plot(time_totalpeaks, total_peaks_lowess, 'm-', 'LineWidth', 3)
xlabel('Time (s)')
ylabel('Total[Hb+Mb] (\muM)')
c= colororder([0.3 0 0; 0 0 0]);
set(gca, 'FontName', 'Arial', 'FontSize' ,24)

%oxy (figure 5)
figure
plot(time(1:sweep+1), oxy(start:start+sweep), 'r-')
hold on
plot(time(flexion_start+1:sweep+1), oxy_lowess, 'k-', 'LineWidth', 3)
% hold on
% plot(time_totalpeaks, total_peaks_lowess, 'm-', 'LineWidth', 3)
xlabel('Time (s)')
ylabel('Oxy[Hb+Mb](\muM)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)

%all on one plot
figure
plot(time(1:sweep+1), oxy(start:start+sweep), 'r-')
hold on
plot(time(flexion_start+1:sweep+1), oxy_lowess, 'b-', 'LineWidth', 3)
hold on
plot(time(1:sweep+1), deoxy(start:start+sweep), 'b-')
hold on
plot(time(flexion_start+1:sweep+1), deoxy_lowess, 'r-', 'LineWidth', 3)
hold on 
plot(time(1:sweep+1), total(start:start+sweep), 'k-')
hold on
plot(time(flexion_start+1:sweep+1), total_lowess, 'r-', 'LineWidth', 3)
% plot(time_totalpeaks, total_peaks_lowess, 'm-', 'LineWidth', 3)
xlabel('Time (s)')
ylabel('Hb+Mb (\muM)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)


%DPF
if deltamua ==1
    figure
    plot(time(1:sweep+1), dpf( start:start+sweep, :), '-')
    xlabel('Time (s)')
    ylabel('DPF')
    set(gca, 'FontName', 'Arial', 'FontSize' ,24)
    c= colororder([ 0.8 0.5 0; 0.6 0 0.3]);
    legend('730nm', '850nm')
end





%stats
% start = 1;
% sweeps = 99;
% nphantoms = 6;
% nwv =2;
% 
% for i = 1:nwv
%     for j = 1: nphantoms
%         mua_avg(j,i) = mean(mua(start+(j-1)*(sweeps+1):start+(j-1)*(sweeps+1)+sweeps , i));
%         musp_avg(j,i) = mean(musp(start+(j-1)*(sweeps+1):start+(j-1)*(sweeps+1)+sweeps, i));
%         
%     end
% end


stat.start.amp = amp(start+begin,:);
stat.start.phase = phase(start+begin,:);
stat.start.mua = mua(start+begin,:);
stat.start.musp= musp(start+begin,:);
stat.start.deoxy= deoxy_lowess(1+begin,:);
stat.start.total= total_lowess(1+begin,:);
stat.start.oxy= oxy_lowess(1+begin,:);
%stat.start.dpf= dpf(start+begin,:);
stat.end.amp = amp(start+flexend,:);
stat.end.phase = phase(start+flexend,:);
stat.end.mua = mua(start+flexend,:);
stat.end.musp= musp(start+flexend,:);
stat.end.deoxy= deoxy_lowess(1+flexend,:);
stat.end.total= total_lowess(1+flexend,:);
stat.end.oxy= oxy_lowess(1+flexend,:);
%stat.end.dpf= dpf(start+flexend,:);

% stat.start.deoxy= deoxy_lowess(1,:);
% stat.start.total= total_lowess(1,:);
% stat.start.oxy= oxy_lowess(1,:);
% stat.end.deoxy= deoxy_lowess(end,:);
% stat.end.total= total_lowess(end,:);
% stat.end.oxy= oxy_lowess(end,:);

