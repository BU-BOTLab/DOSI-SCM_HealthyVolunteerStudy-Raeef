%The script loads and plots the Monte Carlos Simulation Results into figure
%4 of the paper
%REI 5/19/2021

clear all 
close all

%load  data
%cd('\\ad\eng\users\r\a\raeef\My Documents')
cd ('X:\My Documents')
%read data
[filename, pathname]=uigetfile('*.*','pick signal file');
cd(pathname)
sheet =2;
initial_photon_weight = 10e9;
lipid_thickness = [1 2 3 4 5 6 7 8 9 10];
SD =[10 15 20 25 30 35];
o_sat= [70 67.94 62];
o_sat_corrected= abs(o_sat - o_sat(1));

%read data from sheets
data= xlsread(filename,sheet);

%read mean and std of data
for i = 1:6
    for j = 1:10
        mean_baseline (i, j) = data (12,i+7*(j-1));
        std_baseline(i, j) = data (13, i+7*(j-1));
    end

end

for i = 1:6 %SD sep
    for j = 1:10 
        mean_flexion (i, j) = data (29,i+7*(j-1));
        std_flexion(i, j) = data (30, i+7*(j-1));
    end
end

for i = 1:6 %SD sep
    for j = 1:10 
        mean_inspiratory (i, j) = data (46,i+7*(j-1));
        std_inspiratory(i, j) = data (47, i+7*(j-1));
    end

end

Means (:,:,1) = mean_baseline;
Means (:,:,2) = mean_flexion;
Means (:,:,3) = mean_inspiratory;

Sdev (:,:,1) = std_baseline;
Sdev(:,:,2) = std_flexion;
Sdev(:,:,3) = std_inspiratory;


flexion_diff = mean_flexion - mean_baseline;
insp_diff = mean_inspiratory - mean_baseline;

%SNR
SNR = mean_baseline./initial_photon_weight;
SNR_dB = 20*log10(SNR);



% % percent difference for mean and +- one standard deviation 
for i = 1:3
    pdiff_mean (:,:,i) =  (Means (:,:,i) - Means (:,:,1))./Means (:,:,1)*100;
    pdiff_upper (:,:,i) =  abs(((Means (:,:,i) + Sdev (:,:,i) - Means (:,:,1))./Means (:,:,1)*100) - pdiff_mean(:,:,i));
    pdiff_lower (:,:,i) =  abs(((Means (:,:,i) - Sdev(:,:,i) - Means (:,:,1))./Means (:,:,1)*100) - pdiff_mean(:,:,i));
end

% %%%%%%%%%%%%%%%%%%graphing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for i= 1: 6
%     for j= 1:4
%         figure
%         errorbar([80 74]', permute(mean_baseline(i,j,:), [3 2 1]), permute(std_baseline(i,j,:), [3 2 1]), permute(std_baseline(i,j,:), [3 2 1]), 'ko')
%         xlabel ('SCM Blood Oxygen Saturation (%)')
%         ylabel ('Detected Light')
%         set(gca, 'FontName', 'Arial', 'FontSize' ,24)
%         xlim ([70 85])
%     end
% end
% 

%Bar plots (not used)
for i= 1: 6
    for j= 3 %1:10
        figure
        bar(o_sat, permute(pdiff_mean(i,j,:), [3 2 1]))
        hold on
        errorbar(o_sat, permute(pdiff_mean(i,j,:), [3 2 1]), permute(pdiff_lower(i,j,:), [3 2 1]), permute(pdiff_upper(i,j,:), [3 2 1]), 'ko')
        xlabel ('SCM Blood Oxygen Saturation (%)')
        ylabel ('Detected Light Difference (%)')
        set(gca, 'FontName', 'Arial', 'FontSize' ,24)
        xlim ([60 75])
        ylim([-30 0])
    end
end

%bar plots (not used)
n=3;
for i= 1: 6
    figure
    bar(lipid_thickness, abs(permute(pdiff_mean(i,:,n), [3 2 1])))
    hold on
    h= errorbar(lipid_thickness, abs(permute(pdiff_mean(i,:,n), [3 2 1])), permute(pdiff_lower(i,:,n), [3 2 1]), permute(pdiff_upper(i,:,n), [3 2 1]));
    h.Color = [0 0 0];                            
    h.LineStyle = 'none';
    xlabel ('Lipid Layer Thickness (mm)')
    ylabel ('Detected Photon Weight Difference(%)')
    set(gca, 'FontName', 'Arial', 'FontSize' ,24)
    ylim([0 80])
end

for j= 1: 10
    figure
    bar(SD, permute(pdiff_mean(:,j,n), [3 1 2]))
    hold on
    h= errorbar(SD, permute(pdiff_mean(:,j,n), [3 1 2]), permute(pdiff_lower(:,j,n), [3 1 2]), permute(pdiff_upper(:,j,n), [3 1 2]));
    h.Color = [0 0 0];                            
    h.LineStyle = 'none';
    xlabel ('Source Detector Separation (mm)')
    ylabel ('Detected Photon Weight Difference(%)')
    set(gca, 'FontName', 'Arial', 'FontSize' ,24)
    ylim([-20 0])
end

for i= 1: 6
    figure
    bar(lipid_thickness, flexion_diff(i,:))
%     h.Color = [0 0 0];                            
%     h.LineStyle = 'none';
    xlabel ('Lipid Layer Thickness (mm)')
    ylabel ('Detected Photon Weight Difference(%)')
    set(gca, 'FontName', 'Arial', 'FontSize' ,24)
    ylim([-20 0])
end


%all in one plot
figure
for i= 1: 6
    for j= 3 %1:10
        plot(o_sat_corrected, permute(abs(pdiff_mean(i,j,:)), [3 2 1]), '-o')
        hold on
        errorbar(o_sat_corrected, permute(abs(pdiff_mean(i,j,:)), [3 2 1]), permute(pdiff_lower(i,j,:), [3 2 1]), permute(pdiff_upper(i,j,:), [3 2 1]))
        xlabel ('SCM Blood Oxygen Saturation [Absolute Difference from Baseline](%)')
        ylabel ('Detected Photon Weight Difference (%)')
        set(gca, 'FontName', 'Arial', 'FontSize' ,24)
    end
end
c= colororder([ 0.4940 0.1840 0.5560; 0.4940 0.1840 0.5560; 0 0.4470 0.7410; 0 0.4470 0.7410; 0.4660 0.6740 0.1880; 0.4660 0.6740 0.1880; 0.9290 0.6940 0.1250;  0.9290 0.6940 0.1250; 0.8500 0.3250 0.0980; 0.8500 0.3250 0.0980; 0.6350 0.0780 0.1840;0.6350 0.0780 0.1840]);
xlim ([0 10])
ylim([0 50])


figure
for j= 1: 10
    plot(SD, permute(pdiff_mean(:,j,n), [3 1 2]), '-o')
    hold on
    h= errorbar(SD, permute(pdiff_mean(:,j,n), [3 1 2]), permute(pdiff_lower(:,j,n), [3 1 2]), permute(pdiff_upper(:,j,n), [3 1 2]));
    h.Color = [0 0 0];                            
    h.LineStyle = 'none';
    xlabel ('Source Detector Separation (mm)')
    ylabel ('Detected Photon Weight Difference(%)')
    set(gca, 'FontName', 'Arial', 'FontSize' ,24)
    ylim([-80 0])
    xlim ([5 40])
end


%plot for Figure 4
figure
for i= 1: 6
    plot(lipid_thickness, permute(abs(pdiff_mean(i,:,n)), [3 2 1]), '-o', 'LineWidth', 2.0)
    hold on
    scatter(lipid_thickness, permute(abs(pdiff_mean(i,:,n)), [3 2 1]), 'o', 'filled', 'LineWidth', 2.0)
    hold on
    h= errorbar(lipid_thickness, permute(abs(pdiff_mean(i,:,n)), [3 2 1]), permute(pdiff_lower(i,:,n), [3 2 1]), permute(pdiff_upper(i,:,n), [3 2 1]));
    %h.Color = [0 0 0];                            
    h.LineStyle = 'none';
    xlabel ('Lipid Layer Thickness (mm)')
    ylabel ('|Detected Photon Weight Difference|(%)')
    set(gca, 'FontName', 'Arial', 'FontSize' ,24)
end
hold on
%plot( [3 3 3], [14.1 16.3 15.1], 'k.')
c= colororder([ 0.4940 0.1840 0.5560; 0.4940 0.1840 0.5560; 0.4940 0.1840 0.5560; 0 0.4470 0.7410; 0 0.4470 0.7410; 0 0.4470 0.7410; 0.4660 0.6740 0.1880; 0.4660 0.6740 0.1880; 0.4660 0.6740 0.1880; 0.8 0.6 0.1;  0.8 0.6 0.1; 0.8 0.6 0.1; 0.8500 0.3250 0.0980; 0.8500 0.3250 0.0980; 0.8500 0.3250 0.0980; 0.6350 0.0780 0.1840;0.6350 0.0780 0.1840; 0.6350 0.0780 0.1840]);
ylim([0 50])
xlim ([0 11])