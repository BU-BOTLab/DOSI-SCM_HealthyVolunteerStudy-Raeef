%This code reads the post analyzed data from excel sheet
%(2020_12_18_HealthyVolunteerResultsFDVer13) can be FD or CW or FD+CW
%and plots the data

clear all
close all
wavelengths = [  730  850];

%cd('\\ad\eng\users\r\a\raeef\My Documents')
cd ('X:\My Documents')
%read data
[filename, pathname]=uigetfile('*.*','pick signal file');
cd(pathname)

Baseline= xlsread(filename,1);
Long_flexion =xlsread(filename,2);
Short_flexion =xlsread(filename,3);
Long_OP = xlsread(filename,4);

%define subjects
subjects= 10;
male = [1 2 3 4 5 6 7 8 13 14]; %subjects 1 2 3 4 7
female = [9 10 11 12 15 16 17 18 19 20]; %subjects 5 6 8 9 10
max_force = Baseline (:,2);

%baseline metrics
baseline_mua = Baseline (:, 3:4);
baseline_musp = Baseline (:, 5:6);
baseline_oxy = Baseline (:, 7);
baseline_deoxy = Baseline (:, 8);
baseline_total = Baseline (:, 9);
baseline_o2sat =Baseline (:, 10);

lipidlayer.us = Baseline (:,12);
lipidlayer.caliper = Baseline (:,13);

%longflexion (sustained) metrics
longflexion.baseline = Long_flexion (:, 2:4);
longflexion.flexion = Long_flexion (:, 5:7);
longflexion.recovery = Long_flexion (:, 8:10);
longflexion.flexionstart = Long_flexion(:, 11);
longflexion.flexionend = Long_flexion(:, 12);
longflexion.flexiontime= Long_flexion(:, 13:15);

longflexion.raw.start = Long_OP (:, 2:5);
longflexion.OP.start = Long_OP (:, 6:9);
longflexion.raw.end = Long_OP (:, 12:15);
longflexion.OP.end = Long_OP (:, 18:21);

% longflexion.baseline= Long_flexion(:, 2);
% longflexion.baseline.total = Long_flexion(:, 3);
% longflexion.baseline.oxy = Long_flexion(:, 4);
% longflexion.flexion.deoxy = Long_flexion(:, 5);
% longflexion.flexion.total = Long_flexion(:, 6);
% longflexion.flexion.oxy = Long_flexion(:, 7);
% longflexion.recovery.deoxy = Long_flexion(:, 8);
% longflexion.recovery.total = Long_flexion(:, 9);
% longflexion.recovery.oxy = Long_flexion(:, 10);
% longflexion.flexionstart = Long_flexion(:, 11);
% longflexion.flexionend = Long_flexion(:, 12);
% longflexion.timedelta.deoxy = Long_flexion(:, 13);
% longflexion.timedelta.total = Long_flexion(:, 14);
% longflexion.timedelta.oxy = Long_flexion(:, 15);

longflexion.delta= longflexion.flexion - longflexion.baseline;
longflexion.raw.delta= longflexion.raw.end- longflexion.raw.start;
longflexion.OP.delta= longflexion.OP.end- longflexion.OP.start;


%shortflexion (intermittant) metrics
shortflexion.flexionstart = Short_flexion(:, 2:4);
shortflexion.flexionend = Short_flexion(:, 5:7);
shortflexion.firstmax = Short_flexion(:, 8:10);
shortflexion.overallmax = Short_flexion(:, 11:13);
shortflexion.flexiontime = Short_flexion(:, 14:15);
shortflexion.timedelta_firstmax = Short_flexion(:, 16:18);
shortflexion.timedelta_overallmax = Short_flexion(:, 19:21);


shortflexion.delta.end = shortflexion.flexionend - shortflexion.flexionstart;
shortflexion.delta.firstmax = shortflexion.firstmax - shortflexion.flexionstart;
shortflexion.delta.overallmax = shortflexion.overallmax - shortflexion.flexionstart;



%statistics
avg.long.all = mean (Long_flexion);
avg.short.all = mean (Short_flexion);
avg.OP.long.all = mean(Long_OP);

avg.long.delta.all = mean (longflexion.delta);
avg.short.delta.end.all = mean (shortflexion.delta.end);
avg.short.delta.firstmax.all = mean (shortflexion.delta.firstmax);
avg.short.delta.overallmax.all = mean (shortflexion.delta.overallmax);
avg.OP.long.delta.all = mean(longflexion.OP.delta);
avg.raw.long.delta.all = mean(longflexion.raw.delta);


SD.long.all = std (Long_flexion);
SD.short.all = std (Short_flexion);
SD.OP.long.all = std(Long_OP);

SD.long.delta.all = std (longflexion.delta);
SD.short.delta.end.all = std (shortflexion.delta.end);
SD.short.delta.firstmax.all = std (shortflexion.delta.firstmax);
SD.short.delta.overallmax.all = std (shortflexion.delta.overallmax);
SD.OP.long.delta.all = std(longflexion.OP.delta);
SD.raw.long.delta.all = std(longflexion.raw.delta);



%male/female
%male
avg.long.male= mean (Long_flexion (male, :));
avg.short.male = mean (Short_flexion(male, :));
avg.OP.long.male = mean(Long_OP(male, :));

avg.long.delta.male = mean (longflexion.delta(male, :));
avg.short.delta.end.male = mean (shortflexion.delta.end(male, :));
avg.short.delta.firstmax.male = mean (shortflexion.delta.firstmax(male, :));
avg.short.delta.overallmax.male = mean (shortflexion.delta.overallmax(male, :));
avg.OP.long.delta.male = mean(longflexion.OP.delta(male, :));
avg.raw.long.delta.male = mean(longflexion.raw.delta(male, :));


SD.long.male = std (Long_flexion (male, :));
SD.short.male = std (Short_flexion(male, :));
SD.OP.long.male = std(Long_OP(male, :));

SD.long.delta.male = std (longflexion.delta(male, :));
SD.short.delta.end.male = std (shortflexion.delta.end(male, :));
SD.short.delta.firstmax.male = std (shortflexion.delta.firstmax(male, :));
SD.short.delta.overallmax.male = std (shortflexion.delta.overallmax(male, :));
SD.OP.long.delta.male = std(longflexion.OP.delta(male, :));
SD.raw.long.delta.male = std(longflexion.raw.delta(male, :));

%female
avg.long.female= mean (Long_flexion (female, :));
avg.short.female = mean (Short_flexion(female, :));
avg.OP.long.female = mean(Long_OP(female, :));

avg.long.delta.female = mean (longflexion.delta(female, :));
avg.short.delta.end.female = mean (shortflexion.delta.end(female, :));
avg.short.delta.firstmax.female = mean (shortflexion.delta.firstmax(female, :));
avg.short.delta.overallmax.female = mean (shortflexion.delta.overallmax(female, :));
avg.OP.long.delta.female = mean(longflexion.OP.delta(female, :));
avg.raw.long.delta.female = mean(longflexion.raw.delta(female, :));


SD.long.female = std (Long_flexion (female, :));
SD.short.female = std (Short_flexion(female, :));
SD.OP.long.female = std(Long_OP(female, :));


SD.long.delta.female = std (longflexion.delta(female, :));
SD.short.delta.end.female = std (shortflexion.delta.end(female, :));
SD.short.delta.firstmax.female = std (shortflexion.delta.firstmax(female, :));
SD.short.delta.overallmax.female = std (shortflexion.delta.overallmax(female, :));
SD.OP.long.delta.female = std(longflexion.OP.delta(female, :));
SD.raw.long.delta.female = std(longflexion.raw.delta(female, :));



%statistics

for i= 1:3
[plong(i), hlong(i)] = ranksum (longflexion.delta (male, i), longflexion.delta(female,i));
[pshortearly(i), hshortearly(i)] = ranksum (shortflexion.delta.firstmax(male,i), shortflexion.delta.firstmax(female,i));
[pshortend(i), hshortend(i)] = ranksum (shortflexion.delta.end (male,i), shortflexion.delta.end(female,i)); 
end

%Force and Gender correlation plots

% %custom corrlation
% x = short_delta_total;
% y=short_delta_deoxy;
% %x = [x x];
% p=polyfit(x,y,1);
% bestfit= p(1).*x+p(2);
% yresidual= y - bestfit;
% rsq= 1- sum(yresidual.^2)/((length(y)-1)*var(y));
% 
% figure
% plot (x(male, :), y(male, :), 'bo')
% hold on 
% plot (x(female, :), y(female, :), 'mo')
% hold on
% plot(x, bestfit, 'k-')
% ylabel('\Delta Deoxy (\muM)')
% xlabel('\Delta Total (\muM)')
% set(gca, 'FontName', 'Arial', 'FontSize' ,24)
% 

%bar/scatter plots (not used)
for n = 1:3
figure
plot ([1 2], [longflexion.baseline(male, n), longflexion.flexion(male, n)], 'b-o')
hold on
plot ([1 2], [longflexion.baseline(female, n), longflexion.flexion(female, n)], 'm-*')
ylabel ('Hb+Mb (\muM)')
xticks([1 2])
xticklabels ({'Flexion Start', 'Flexion Max'})
xlim ([0.5 2.5])
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
end

%not used
for n = 1:3
figure
plot ([1 2], [shortflexion.flexionstart(male, n), shortflexion.flexionend(male, n)], 'b-o')
hold on
plot ([1 2], [shortflexion.flexionstart(female, n), shortflexion.flexionend(female, n)], 'm-*')
ylabel ('Hb+Mb (\muM)')
xticks([1 2])
xticklabels ({'Flexion Start', 'Flexion End'})
xlim ([0.5 2.5])
ylim ([0 200])
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
end

%not used
for n = 1:3
figure
plot ([1 2], [shortflexion.flexionstart(male, n), shortflexion.firstmax(male, n)], 'b-o')
hold on
plot ([1 2], [shortflexion.flexionstart(female, n), shortflexion.firstmax(female, n)], 'm-*')
ylabel ('Hb+Mb (\muM)')
xticks([1 2])
xticklabels ({'Flexion Start', 'Early Max'})
xlim ([0.5 2.5])
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
end

%not used
for n = 1:3
figure
plot ([1 2], [shortflexion.flexionstart(male, n), shortflexion.overallmax(male, n)], 'b-o')
hold on
plot ([1 2], [shortflexion.flexionstart(female, n), shortflexion.overallmax(female, n)], 'm-*')
ylabel ('Hb+Mb (\muM)')
xticks([1 2])
xticklabels ({'Flexion Start', 'Overall Max'})
xlim ([0.5 2.5])
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
end

%not used
for n = 1:3
figure
plot ([1 2 3], [shortflexion.flexionstart(male, n), shortflexion.firstmax(male, n), shortflexion.flexionend(male, n)], 'b-o' )
hold on
plot ([1 2 3], [shortflexion.flexionstart(female, n), shortflexion.firstmax(female, n), shortflexion.flexionend(female, n)], 'm-*')
ylabel ('Hb+Mb (\muM)')
xticks([1 2 3])
xticklabels ({'Flexion Start', 'Early Max', 'Flexion End'})
xlim ([0.5 3.5])
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
end


%paired bars
%grouped bar plot skin absorption
% y = [avg.long.delta_deoxy_male avg.long.delta_deoxy_female avg.long.delta_deoxy; ...
%     avg.long.delta_oxy_male avg.long.delta_oxy_female avg.long.delta_oxy; ...
%     avg.long.delta_total_male avg.long.delta_total_female avg.long.delta_total;];
% 
% y_SD = [SD.long.delta_deoxy_male SD.long.delta_deoxy_female SD.long.delta_deoxy; ...
%     SD.long.delta_oxy_male SD.long.delta_oxy_female SD.long.delta_oxy; ...
%     SD.long.delta_total_male SD.long.delta_total_female SD.long.delta_total;];




%Short Flexion Start to finish
% y = [avg.short.delta.end.male; avg.short.delta.end.female; avg.short.delta.end.all];
% y_SD = [SD.short.delta.end.male; SD.short.delta.end.female; SD.short.delta.end.all];

% %short Flexion Delta Early max
% y = [avg.short.delta.firstmax.male; avg.short.delta.firstmax.female; avg.short.delta.firstmax.all];
% y_SD = [SD.short.delta.firstmax.male; SD.short.delta.firstmax.female; SD.short.delta.firstmax.all];
% 
% %short Flexion Delta Overall max
% y = [avg.short.delta.overallmax.male; avg.short.delta.overallmax.female; avg.short.delta.overallmax.all];
% y_SD = [SD.short.delta.overallmax.male; SD.short.delta.overallmax.female; SD.short.delta.overallmax.all];



%sustained flexion paper (Figure 6 left)***************************
%Long Flexion Delta
ylong = [avg.long.delta.male; avg.long.delta.female; avg.long.delta.all];
ylong_SD = [SD.long.delta.male; SD.long.delta.female; SD.long.delta.all];

figure
b= bar([1 2 3],  ylong(:, [1 3 2])' );
hold on
nbars= size(ylong,2);
% Get the x coordinate of the bars
x = [];
for i = 1:nbars
    x = [x ; b(i).XEndPoints];
end
% Plot the errorbars
errorbar(x',ylong(:, [1 3 2])', ylong_SD(:, [1 3 2])','k','linestyle','none')
hold off
ylabel ('\Delta Hb+Mb (\muM)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410; 0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;  0.8500 0.3250 0.0980; 0.6350 0.0780 0.1840]);
%c= colororder([ 1.00,1.00,0.00;0.93,0.69,0.13; 1.00, 0.41, 0.16;0.85,0.33,0.10;1.00,0.00,0.00;0.64,0.08,0.18]);
c= colororder([ 0 0.8 0.9; 0.55 0.3 0.65; 0 0.4 0.8;0.3 0.95 1; 0.75 0.5 0.85; 0.3 0.4 1]);
xticks([1 2 3])
xticklabels ({'Deoxy', 'Oxy', 'Total'})
ylim([-200 200])


%versus "time" (not used)
for n=1:3

    y = [avg.short.delta.firstmax.male(n), avg.short.delta.firstmax.female(n), avg.short.delta.firstmax.all(n); ...
     avg.short.delta.end.male(n), avg.short.delta.end.female(n), avg.short.delta.end.all(n)];

    y_SD = [SD.short.delta.firstmax.male(n), SD.short.delta.firstmax.female(n), SD.short.delta.firstmax.all(n);...
        SD.short.delta.end.male(n), SD.short.delta.end.female(n), SD.short.delta.end.all(n)];
    
    figure
    b= bar([1 2],  y );
    hold on
    nbars= size(y,2);
    % Get the x coordinate of the bars
    x = [];
    for i = 1:nbars
        x = [x ; b(i).XEndPoints];
    end
    % Plot the errorbars
    errorbar(x',y, y_SD,'k','linestyle','none')
    hold off
    ylabel ('\Delta Hb+Mb (\muM)')
    set(gca, 'FontName', 'Arial', 'FontSize' ,24)
    %c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410; 0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;  0.8500 0.3250 0.0980; 0.6350 0.0780 0.1840]);
    c= colororder([ 1.00,1.00,0.00;0.93,0.69,0.13; 1.00, 0.41, 0.16;0.85,0.33,0.10;1.00,0.00,0.00;0.64,0.08,0.18]);
    xticks([1 2])
    xticklabels ({'Early Changes', 'End Flexion'})
end

%versus time no gender (not used)
y = [avg.short.delta.firstmax.all; avg.short.delta.end.all];
y_SD = [SD.short.delta.firstmax.all; SD.short.delta.end.all];

figure
b= bar([1 2 ],  y(:,[1 3 2]) );
hold on
nbars= size(y,2);
% Get the x coordinate of the bars
x = [];
for i = 1:nbars
    x = [x ; b(i).XEndPoints];
end
% Plot the errorbars
errorbar(x',y(:,[1 3 2]), y_SD(:,[1 3 2 ]),'k','linestyle','none')
hold off
ylabel ('\Delta Hb+Mb (\muM)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410; 0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;  0.8500 0.3250 0.0980; 0.6350 0.0780 0.1840]);
c= colororder([0 0.2 0.7410; 0.8 0.2 0.2; 0.75, 0.41, 0.16]);
xticks([1 2 ])
xticklabels ({'Early Changes', 'End Flexion'})



%all on one 
y = [avg.short.delta.firstmax.male, avg.short.delta.end.male;...
    avg.short.delta.firstmax.female, avg.short.delta.end.female;...
    avg.short.delta.firstmax.all, avg.short.delta.end.all];

y_SD = [SD.short.delta.firstmax.male; SD.short.delta.firstmax.female; SD.short.delta.firstmax.all;...
    SD.short.delta.end.male; SD.short.delta.end.female; SD.short.delta.end.all];

figure
b= bar([1 2 3 4 5 6],  y(:,[1 4 3 6 2 5]) );
hold on
nbars= size(y,1);
% Get the x coordinate of the bars
x = [];
for i = 1:nbars
    x = [x ; b(i).XEndPoints];
end
% Plot the errorbars
errorbar(x,y(:,[1 4 3 6 2 5]), y_SD([1 4 3 6 2 5],:)','k','linestyle','none')
hold off
ylabel ('\Delta Hb+Mb (\muM)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410; 0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;  0.8500 0.3250 0.0980; 0.6350 0.0780 0.1840]);
%c= colororder([ 1.00,1.00,0.00;0.93,0.69,0.13; 1.00, 0.41, 0.16;0.85,0.33,0.10;1.00,0.00,0.00;0.64,0.08,0.18]);
c= colororder([ 0 0.8 0.9; 0.55 0.3 0.65; 0 0.4 0.8;0.3 0.95 1; 0.75 0.5 0.85; 0.3 0.4 1]);
xticks([1.5 3.5 5.5])
xticklabels ({'Deoxy', 'Oxy', 'Total'})
ylim([-100 100])


%separate bars
%Intermittant flexion Paper  (Figure 6 Right) ************
y = y(:,[1 4 3 6 2 5]);
y_SD = y_SD([1 4 3 6 2 5],:);

figure
for j = 1:6
b= bar(j,  y(:,j) );
hold on
nbars= size(y,1);
% Get the x coordinate of the bars
x = [];
for i = 1:nbars
    x = [x ; b(i).XEndPoints];
end
% Plot the errorbars
errorbar(x,y(:,j), y_SD(j,:)','k','linestyle','none')

end
hold off
ylabel ('\Delta Hb+Mb (\muM)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410; 0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;  0.8500 0.3250 0.0980; 0.6350 0.0780 0.1840]);
%c= colororder([ 1.00,1.00,0.00;0.93,0.69,0.13; 1.00, 0.41, 0.16;0.85,0.33,0.10;1.00,0.00,0.00;0.64,0.08,0.18]);
c= colororder([ 0 0.8 0.9; 0.55 0.3 0.65; 0 0.4 0.8;0 0 0]); %;0.7 0.95 1; 0.85 0.6 0.95; 0.5 0.6 1; 0 0 0]);
xticks([1.5 3.5 5.5])
xticklabels ({'Deoxy', 'Oxy', 'Total'})
ylim([-100 100])


%nothing is used for the paper below here, these are  OP plots
%OP Bar plots
yOP = [avg.OP.long.delta.male;avg.OP.long.delta.female;avg.OP.long.delta.all];
yOP_SD =[SD.OP.long.delta.male;SD.OP.long.delta.female;SD.OP.long.delta.all];

figure
b= bar([1 2 3 4],  yOP);
hold on
nbars= size(yOP,1);
% Get the x coordinate of the bars
x = [];
for i = 1:nbars
    x = [x ; b(i).XEndPoints];
end
% Plot the errorbars
errorbar(x,yOP, yOP_SD,'k','linestyle','none')
hold off
ylabel ('OP (mm^-^1)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410; 0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;  0.8500 0.3250 0.0980; 0.6350 0.0780 0.1840]);
%c= colororder([ 1.00,1.00,0.00;0.93,0.69,0.13; 1.00, 0.41, 0.16;0.85,0.33,0.10;1.00,0.00,0.00;0.64,0.08,0.18]);
c= colororder([ 0 0.8 0.9; 0.55 0.3 0.65; 0 0.4 0.8;0.3 0.95 1; 0.75 0.5 0.85; 0.3 0.4 1]);
xticks([1.5 3.5])
xticklabels ({'\mu_a', '\mu_s'''})

%phase Bar plots (not used)
yphase = [avg.raw.long.delta.male(3:4);avg.raw.long.delta.female(3:4);avg.raw.long.delta.all(3:4)];
yphase_SD =[SD.raw.long.delta.male(3:4);SD.raw.long.delta.female(3:4);SD.raw.long.delta.all(3:4)];

figure
b= bar([1 2 ],  yphase);
hold on
nbars= size(yphase,1);
% Get the x coordinate of the bars
x = [];
for i = 1:nbars
    x = [x ; b(i).XEndPoints];
end
% Plot the errorbars
errorbar(x,yphase, yphase_SD,'k','linestyle','none')
hold off
ylabel ('Phase (degrees)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410; 0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;  0.8500 0.3250 0.0980; 0.6350 0.0780 0.1840]);
%c= colororder([ 1.00,1.00,0.00;0.93,0.69,0.13; 1.00, 0.41, 0.16;0.85,0.33,0.10;1.00,0.00,0.00;0.64,0.08,0.18]);
c= colororder([ 0 0.8 0.9; 0.55 0.3 0.65; 0 0.4 0.8;0.3 0.95 1; 0.75 0.5 0.85; 0.3 0.4 1]);
xticks([1 2])
xticklabels ({'730 nm', '850 nm'})

%amp Bar plots (not used)
yamp = [avg.raw.long.delta.male(1:2);avg.raw.long.delta.female(1:2);avg.raw.long.delta.all(1:2)];
yamp_SD =[SD.raw.long.delta.male(1:2);SD.raw.long.delta.female(1:2);SD.raw.long.delta.all(1:2)];

figure
b= bar([1 2 ],  yamp);
hold on
nbars= size(yamp,1);
% Get the x coordinate of the bars
x = [];
for i = 1:nbars
    x = [x ; b(i).XEndPoints];
end
% Plot the errorbars
errorbar(x,yamp, yamp_SD,'k','linestyle','none')
hold off
ylabel ('Amplitude (-)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410; 0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;  0.8500 0.3250 0.0980; 0.6350 0.0780 0.1840]);
%c= colororder([ 1.00,1.00,0.00;0.93,0.69,0.13; 1.00, 0.41, 0.16;0.85,0.33,0.10;1.00,0.00,0.00;0.64,0.08,0.18]);
c= colororder([ 0 0.8 0.9; 0.55 0.3 0.65; 0 0.4 0.8;0.3 0.95 1; 0.75 0.5 0.85; 0.3 0.4 1]);
xticks([1 2])
xticklabels ({'730 nm', '850 nm'})

