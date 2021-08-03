%This script reads data from 2021_01_15_FDvsCW_ver02 and plots figure 8

clear all
close all
wavelengths = [730  850];

%cd('\\ad\eng\users\r\a\raeef\My Documents')
cd ('X:\My Documents')
%read data
[filename, pathname]=uigetfile('*.*','pick signal file');
cd(pathname)

%reads data
Data= xlsread(filename,1);

long.avg= Data (:,1:3);
long.SD= Data (:,4:6);
short.early.avg= Data (:,7:9);
short.early.SD= Data (:,10:12);
short.end.avg= Data (:,13:15);
short.end.SD= Data (:,16:18);

%long flexion
ylong= long.avg ([1 3], [1 3 2]);
ylongSD = long.SD ([1 3], [1 3 2]);


%figure 8 left*********************
figure
b= bar([1 2 3],  ylong' );
hold on
nbars= size(ylong,1);
% Get the x coordinate of the bars
x = [];
for i = 1:nbars
    x = [x ; b(i).XEndPoints];
end
% Plot the errorbars
errorbar(x',ylong', ylongSD','k','linestyle','none')
hold off
ylabel ('\Delta Hb+Mb (\muM)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410; 0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;  0.8500 0.3250 0.0980; 0.6350 0.0780 0.1840]);
%c= colororder([ 1.00,1.00,0.00;0.93,0.69,0.13; 1.00, 0.41, 0.16;0.85,0.33,0.10;1.00,0.00,0.00;0.64,0.08,0.18]);
c= colororder([0.93,0.69,0.13; 0.9, 0.41, 0.16; 0, 0, 0; 1,0.8,0.1;1,0.7,0.7; 0,0,0]);
%c= colororder([ 0 0.8 0.9; 0.55 0.3 0.65; 0 0.4 0.8;0.3 0.95 1; 0.75 0.5 0.85; 0.3 0.4 1]);
xticks([1 2 3])
xticklabels ({'Deoxy', 'Oxy', 'Total'})
ylim([-150 150])


%separate bars
%Intermittant flexion Paper figure 8 right *****
yshort = [short.early.avg([1 3], [1 3 2]) short.end.avg([1 3], [1 3 2])];
yshortSD = [short.early.SD([1 3], [1 3 2]) short.end.SD([1 3], [1 3 2])];

yshort = yshort(:, [1 4 2 5 3 6]);
yshortSD = yshortSD(:, [1 4 2 5 3 6]);

figure
for j = 1:6
    b= bar(j,  yshort(:,j) );
    hold on
    nbars= size(yshort,1);
    % Get the x coordinate of the bars
    x = [];
    for i = 1:nbars
        x = [x ; b(i).XEndPoints];
    end
    % Plot the errorbars
    errorbar(x,yshort(:,j)', yshortSD(:,j)','k','linestyle','none')
    
end
hold off
ylabel ('\Delta Hb+Mb (\muM)')
set(gca, 'FontName', 'Arial', 'FontSize' ,24)
%c= colororder([ 0.4940 0.1840 0.5560; 0 0.4470 0.7410; 0.4660 0.6740 0.1880;  0.9290 0.6940 0.1250;  0.8500 0.3250 0.0980; 0.6350 0.0780 0.1840]);
%c= colororder([ 1,1,0.00;0.93,0.69,0.13; 0.9, 0.41, 0.16; 0, 0, 0; 1,1,0.5;1,0.8,0.1;1,0.7,0.7; 0,0,0]);
c= colororder([0.93,0.69,0.13; 0.9, 0.41, 0.16; 0, 0, 0]); %; 1,0.8,0.1;1,0.7,0.7; 0,0,0]);
%c= colororder([ 0 0.8 0.9; 0.55 0.3 0.65; 0 0.4 0.8;0 0 0;0.7 0.95 1; 0.85 0.6 0.95; 0.5 0.6 1; 0 0 0]);
xticks([1.5 3.5 5.5])
xticklabels ({'Deoxy', 'Oxy', 'Total'})
ylim([-100 100])


%statistics
Deltas= xlsread(filename,2);
long.FD= Deltas (:,2:4);
long.CW= Deltas (:,5:7);
short.early.FD= Deltas (:,8:10);
short.early.CW= Deltas (:,11:13);
short.end.FD= Deltas (:,14:16);
short.end.CW= Deltas (:,17:19);

for i=1:3
    [plong(i), hlong(i)] = ranksum (long.FD (:,i), long.CW(:,i));
    [pshortearly(i), hshortearly(i)] = ranksum (short.early.FD (:,i), short.early.CW(:,i));
    [pshortend(i), hshortend(i)] = ranksum (short.end.FD (:,i), short.end.CW(:,i)); 
end
