%==========================================================================
%  Large detector  pencil beam in semi infinite medium.  This should be the
%  simplest MC case that I can compare with an analytical solution in order
%  to test diffuse reflectance calculations
%==========================================================================
clear cfg
clear cfgVec
addpath(genpath('D:\Work\RoblyerLab\mcxlab'))
cfg.nphoton=1e9;
cfg.vol=uint8(ones(60,60,100));
%cfg.vol(:,:,10:24)=2;    % add an inclusion
%cfg.vol(:,:,25:60) = 0;
cfg.prop=[0 0 1 1; 0 10 0.9 1.4]; % [mua,mus,g,n]
cfg.srcpos=[18 30 1];
cfg.srcdir=[0 0 1];
cfg.detpos=[43,30,2,2.3/2];
cfg.vol(:,:,1)=0;   % pad a layer of 0s to get diffuse reflectance
cfg.gpuid=1;
cfg.autopilot=1;
cfg.unitinmm = 1;
cfg.tstart=0;
cfg.tend=5e-9;
cfg.tstep=5e-9;
cfg.gpuid='1'; %GPU ID
cfg.autopilot=1; %Automatically choose how many threads, etc.


cfg.maxdetphoton=1e7; %save up to this many photons
cfg.issaveexit=1; %Save the position and direction of detected photons (can't hurt)
cfg.issaveref=1; %Also save diffuse reflectance

%%%I don't think timing information is used in the simulation
cfg.tstart=0;   %Time the simulation starts
cfg.tstep=5e-9; %Steps to take
cfg.tend = 5e-9; %When to end.  The output will have [tstart:tstep:tend] slices at each of the different time points

%cfg.detpos = [30,30,20,1]; %detector at center, 1 mm radius (3.14 mm^2 area)
cfg.isreflect=0; %Don't reflect from outside the boundary
cfg.isrefint=1; %Do consider internal reflections
%cfg.prop=[0 0 1 1;  %Properties of the materials.  anywhere cfg.vol == 0 will have properties in the first row (medium type 0)
%0 0 1 1;            
%0,10,.9,1.4];


muaRange = 0; %White monte carlo --Will scale partial path lengths to account for mua
muspRange = 1:1:20; %This is mus NOT musp!
%muspRange = 10;
iter = 0;
for i = 1:length(muaRange)
    for j = 1:length(muspRange)
        iter = iter+1;
        if i == 1 && j == 1
            cfgVec = cfg;
            cfgVec.prop=[0 0 1 1;  %Properties of the materials.  anywhere cfg.vol == 0 will have properties in the first row (medium type 0)
            muaRange(i),muspRange(j),.9,1.4]; %This is to replicate the work by Fang 2009
        else
       
         cfgVec(iter) = cfgVec(1);
         cfgVec(iter).prop=[0 0 1 1;  %Properties of the materials.  anywhere cfg.vol == 0 will have properties in the first row (medium type 0)  
         muaRange(i),muspRange(j),.9,1.4]; %This is to replicate the work by Fang 2009
        end
    end
end

for k = 1:length(cfgVec)
	[flux,det]=mcxlab(cfgVec(k));
	thisFname = sprintf('semiInfRef_%02d_of_%02d.mat',k,length(cfgVec));
	save(fullfile('D:\Work\RoblyerLab\reflectanceModel\SD_25mm',thisFname),'det','cfgVec','-v7.3');
end

%figure
%imagesc(squeeze(flux.data(:,30,:,3)));
% %%%%%%%%This is the analysis part%%%%%%%%%%%
%  load('slabTransmission10mm.mat')
%  
%  tVec = 0:1e-12:1e-9-1e-12;
%  
%  sampFreq = 1/1e-12;
% 
%  padFlux = [squeeze(flux.data(30,30,10,:));zeros(2^16-length(tVec),1)];
%  bins = [0:length(padFlux)-1]*sampFreq / length(padFlux);
%  spectrum = fft(padFlux);
%  amp = abs(padFlux);
%  phase = angle(padFlux);
%  
%  figure
%  plot(bins,abs(fft(padFlux)))
%  xlim([0,1e9]
%  
%  am
%  
%  figure
%  plot(tVec,squeeze(flux.data(30,30,10,:)))
