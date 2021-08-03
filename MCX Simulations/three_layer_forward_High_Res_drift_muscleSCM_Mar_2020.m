%==========================================================================
%  Large detector  pencil beam in semi infinite medium.  This should be the
%  simplest MC case that I can compare with an analytical solution in order
%  to test diffuse reflectance calculations
%==========================================================================
clear cfg
clear all
close all

%number of photons to launch
cfg.nphoton=1e9; 
%Dimension of domain
dim=120;

%Generate voxel positions
%[xi,yi,zi]=meshgrid(1:dim,1:dim,1:0.5*dim);
% ijv_dist =sqrt((xi-120).^2+ (zi -32).^2);
% ca_dist = sqrt((xi -100).^2 + (zi -42).^2);


%Set the volume 
cfg.vol=zeros(120, 120, 60);
cfg.vol(:,:,1)=0; %top (air layer)
% cfg.vol(ijv_dist < 9) = 2; % internal jugular
% cfg.vol(ca_dist < 7) = 3; % carotid artery

% %1 mm lipid layer
% cfg.shapes=['{"Shapes":[{"ZLayers":[[2,3,1],[4,4,2],[5,9,3],[10,60,4] ]},' ...
%     '{"Cylinder": {"Tag":5, "C0": [0,60,14], "C1": [120,60,14], "R": 5}},'...
%     '{"Cylinder": {"Tag":6, "C0": [0,52,16], "C1": [120,52,16], "R": 3.5}}]}'];
% %2 mm lipid layer
% cfg.shapes=['{"Shapes":[{"ZLayers":[[2,3,1],[4,5,2],[6,10,3],[11,60,4] ]},' ...
%     '{"Cylinder": {"Tag":5, "C0": [0,60,15], "C1": [120,60,15], "R": 5}},'...
%     '{"Cylinder": {"Tag":6, "C0": [0,52,17], "C1": [120,52,17], "R": 3.5}}]}'];
% %3 mm lipid layer
cfg.shapes=['{"Shapes":[{"ZLayers":[[2,3,1],[4,6,2],[7,11,3],[12,60,4] ]},' ...
    '{"Cylinder": {"Tag":5, "C0": [0,60,16], "C1": [120,60,16], "R": 5}},'...
    '{"Cylinder": {"Tag":6, "C0": [0,52,18], "C1": [120,52,18], "R": 3.5}}]}'];
%4mm
% cfg.shapes=['{"Shapes":[{"ZLayers":[[2,3,1],[4,7,2],[8,12,3],[13,60,4] ]},' ...
%     '{"Cylinder": {"Tag":5, "C0": [0,60,17], "C1": [120,60,17], "R": 5}},'...
%     '{"Cylinder": {"Tag":6, "C0": [0,52,19], "C1": [120,52,19], "R": 3.5}}]}'];
%5 mm lipid layer
% cfg.shapes=['{"Shapes":[{"ZLayers":[[2,3,1],[4,8,2],[9,13,3],[14,60,4] ]},' ...
%     '{"Cylinder": {"Tag":5, "C0": [0,60,18], "C1": [120,60,18], "R": 5}},'...
%     '{"Cylinder": {"Tag":6, "C0": [0,52,20], "C1": [120,52,20], "R": 3.5}}]}'];
% %6 mm lipid layer
% cfg.shapes=['{"Shapes":[{"ZLayers":[[2,3,1],[4,9,2],[10,14,3],[15,60,4] ]},' ...
%     '{"Cylinder": {"Tag":5, "C0": [0,60,19], "C1": [120,60,19], "R": 5}},'...
%     '{"Cylinder": {"Tag":6, "C0": [0,52,21], "C1": [120,52,21], "R": 3.5}}]}'];
% %7 mm lipid layer
% cfg.shapes=['{"Shapes":[{"ZLayers":[[2,3,1],[4,10,2],[11,15,3],[16,60,4] ]},' ...
%     '{"Cylinder": {"Tag":5, "C0": [0,60,20], "C1": [120,60,20], "R": 5}},'...
%     '{"Cylinder": {"Tag":6, "C0": [0,52,22], "C1": [120,52,22], "R": 3.5}}]}'];
% %8 mm lipid layer
% cfg.shapes=['{"Shapes":[{"ZLayers":[[2,3,1],[4,11,2],[12,16,3],[17,60,4] ]},' ...
%     '{"Cylinder": {"Tag":5, "C0": [0,60,21], "C1": [120,60,21], "R": 5}},'...
%     '{"Cylinder": {"Tag":6, "C0": [0,52,23], "C1": [120,52,23], "R": 3.5}}]}'];
% %9 mm lipid layer
% cfg.shapes=['{"Shapes":[{"ZLayers":[[2,3,1],[4,12,2],[13,17,3],[18,60,4] ]},' ...
%     '{"Cylinder": {"Tag":5, "C0": [0,60,22], "C1": [120,60,22], "R": 5}},'...
%     '{"Cylinder": {"Tag":6, "C0": [0,52,24], "C1": [120,52,24], "R": 3.5}}]}'];
% %10 mm lipid layer
% cfg.shapes=['{"Shapes":[{"ZLayers":[[2,3,1],[4,13,2],[14,18,3],[19,60,4] ]},' ...
%     '{"Cylinder": {"Tag":5, "C0": [0,60,23], "C1": [120,60,23], "R": 5}},'...
%     '{"Cylinder": {"Tag":6, "C0": [0,52,25], "C1": [120,52,25], "R": 3.5}}]}'];


cfg.vol=uint8(cfg.vol);

figure
imagesc(squeeze(cfg.vol(60,:,:)))

%Tell it what gpu to use
cfg.gpuid='1'; %GPU ID
cfg.autopilot=1; %Automatically choose how many threads, etc.

for j=1:10
cfg.seed =  randi(100,1,1); %rng
cfg.sradius = 1; %atomic setting on (positive number)
%cfg.minenergy = 0.000001; %terminate photon when energy is less than this amount

cfg.srctype='pencil';  %pencil beam
cfg.srcpos=[30 60 1]; %Location of pencil beam
cfg.srcdir=[0 0 1]; %Headed in the +z direction

cfg.maxdetphoton=1e7; %save up to this many photons
cfg.issaveexit=1; %Save the position and direction of detected photons (can't hurt)'
cfg.issaveref=1; %Also save diffuse reflectance

cfg.unitinmm=1; %Each grid unit is 1 mm

%%%Set up timing (mostly for visualizing flux)
cfg.tstart=0;   %Time the simulation starts
cfg.tstep=5e-12; %Steps to take6
cfg.tend = 5e-9; %When to end.  The output will have [tstart:tstep:tend] slices at each of the different time points

%Photons are only detected at interfaces!
cfg.detpos = [40,60,1, 2;
              45,60, 1, 2;
              50,60, 1, 2;
              55,60, 1, 2;
              60,60, 1, 2;
              65,60, 1, 2;]; %detector at center, 2 mm diameter% 

% cfg.detpos = [50,60, 1, 2;]; %detector at center, 2 mm diameter % 

          
cfg.isreflect=0; %Don''t reflect from outside the boundary (assume photons can escape)
cfg.isrefint=1; %Do consider internal reflections

%Blood OP calculator

o_sat = 0.70; %saturation (you can change this%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%)

%Blood Optical properties (from Dirk Faber)
%650
mua650 = o_sat*0.207+ (1-o_sat) * 1.887;
mus650 = o_sat*92.8+ (1-o_sat) * 85.9;
g650 =  o_sat*0.985+ (1-o_sat) * 0.986;
n650 = o_sat*1.393+ (1-o_sat) * 1.389;


%730
mua730 = o_sat* 0.258+ (1-o_sat) * 0.6889185;
mus730 = o_sat*80.59132+ (1-o_sat) *71.00815 ;
g730 =  o_sat* 0.983154+ (1-o_sat) * 0.9839978;
n730 = o_sat*1.392276 + (1-o_sat) * 1.388302;


%850
mua850 = o_sat*0.607+ (1-o_sat) * 0.395;
mus850 = o_sat*64.4+ (1-o_sat) * 56.4;
g850 =  o_sat*0.980+ (1-o_sat) * 0.981;
n850 = o_sat*1.392+ (1-o_sat) * 1.388;

%muscle absrobtion Calculator

o_sat_muscle = 0.70; %saturation (you can change this%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%)
%74.16% for a 10 um increase in deoxy
%baseline 70
%flexion failure 67.93
%62% Inspiratory challenge
water650 = 0.625*0.00034;
water730 = 0.625*0.00197441;
water850 = 0.625*0.004199792;

% %methods 1 and 2
% hemo650 = 0.07 *(o_sat_muscle*0.207+ (1-o_sat_muscle) * 1.887);
% hemo850 = 0.07 * (o_sat_muscle*0.607+ (1-o_sat_muscle) * 0.395);
% 
% myo650 = 0.6* (o_sat_muscle*0.0903+ (1-o_sat_muscle) * 0.762616);
% myo850 = 0.6*(o_sat_muscle*0.237539+ (1-o_sat_muscle) * 0.178);
%

%method 3
hemo_conc = 0.129; %0.1477 ITL 0.126 baseline 0.135 flexion (129/138/150.7)
hemo650 = o_sat_muscle*hemo_conc*0.0903 + (1-o_sat_muscle) * hemo_conc*0.7626;
hemo730 = o_sat_muscle*hemo_conc* 0.116971+ (1-o_sat_muscle) * hemo_conc*0.301178;
hemo850 = o_sat_muscle*hemo_conc*0.2375 + (1-o_sat_muscle) * hemo_conc*0.178;

mua_muscle_650 = water650 + hemo650; %+myo650;
mua_muscle_730 = water730 + hemo730; %+myo730;
mua_muscle_850 = water850 + hemo850; %+myo850;

%skin layer OPs
%[0.01 5 0.9 1.4] default easy OPs
%[0.025 5 0.9 1.4] 850 nm (may include vessels)
%[0.04 7 0.9 1.4] 650 nm (may include vessels)

      
%%%blood layer OPs     
%[0.5 250 0.993 1.4] 850 nm,  100% HbO2
%[0.45 240 0.993 1.4] 850 nm, 70% HbO2
%[0.4 237 0.99325 1.4] 850 nm, 50% HbO2
%[0.3 225 0.9935 1.4] 850 nm, 0% HbO2
%[mua850 mus850 g850 n850 ] 850 nm, o_sat% HbO2


%[0.1 350 0.9945 1.4]; 650 nm, 100% HbO2
%[0.5 340 0.9945 1.4]; 650 nm, 70% HbO2
%[1 337 0.99475 1.4] 550 nm, 50% HbO2
%[2 325 0.995 1.4]; 650 nm, 0% HbO2
%[mua650 mus650 g650 n650] 650 nm, o_sat% HbO2

%658 nm (simple)
% cfg.prop=[0 0 1 1;  %Properties of the materials.  anywhere cfg.vol == 0 will have properties in the first row (medium type 0)
%    0.06 31.1 0.9 1.39;%skin
%    0.01 15.3 0.9 1.39;%subcutaneous fat
%    mua_muscle_650 6.46 0.9 1.39;%muscle
%    0.01 13.4 0.9 1.39; %deep tissue
%    mua650 mus650 g650 n650;   % IJV (70%) %mu_a mu_s (!!!not mus prime!!!), g, n
%     0.207 92.8 0.985 1.393];   %carotide (100% saturation)

% %658 nm (more precise)
% cfg.prop=[0 0 1 1;  %Properties of the materials.  anywhere cfg.vol == 0 will have properties in the first row (medium type 0)
%    0.06 16.5 0.81 1.4;%skin (0.06 around the baseline 0.03/0.06/0.245)
%    0.01 6.12 0.75 1.44;%subcutaneous fat
%    mua_muscle_650 6.82 0.9 1.37;%muscle
%    0.01 13.4 0.9 1.4; %deep tissue
%    mua650 mus650 g650 n650;   % IJV (70%) %mu_a mu_s (!!!not mus prime!!!), g, n
%     0.207 92.8 0.985 1.393];   %carotid (100% saturation)


% %730 nm (more precise)
% cfg.prop=[0 0 1 1;  %Properties of the materials.  anywhere cfg.vol == 0 will have properties in the first row (medium type 0)
%    0.125 15.96 0.8317 1.4;%skin (average cauasian 0.018 simpson light/0.046 bashkatov/0.125 simpson dark)
%    0.01 5.71 0.75 1.44;%subcutaneous fat
%    mua_muscle_730 5.61 0.9 1.37;%muscle
%    0.01 11.7 0.9 1.4; %deep tissue
%    mua730 mus730 g730 n730;   % IJV (70%) %mu_a mu_s (!!!not mus prime!!!), g, n
%     0.258 80.6 0.98 1.392];     %Carotid Artery 100%  (O_sat)


% % %850 nm (simple)
% cfg.prop=[0 0 1 1;  %Properties of the materials.  anywhere cfg.vol == 0 will have properties in the first row (medium type 0)
%    0.04 21.6 0.9 1.39;%skin
%    0.01 12.9 0.9 1.39;%subcutaneous fat
%    mua_muscle_850 5.07 0.9 1.39;%muscle
%    0.01 9.86 0.9 1.39; %deep tissue
%    mua850 mus850 g850 n850;   % IJV (70%) %mu_a mu_s (!!!not mus prime!!!), g, n
%     0.607 64.4 0.98 1.392];     %Carotid Artery 100%  (O_sat)


% %850 nm (more precise)
cfg.prop=[0 0 1 1;  %Properties of the materials.  anywhere cfg.vol == 0 will have properties in the first row (medium type 0)
   0.01 16.2 0.87 1.4;%skin (average cauasian 0.01/0.038/0.06)
   0.01 5.15 0.75 1.44;%subcutaneous fat
   mua_muscle_850 4.23 0.9 1.37;%muscle
   0.01 9.86 0.9 1.4; %deep tissue
   mua850 mus850 g850 n850;   % IJV (70%) %mu_a mu_s (!!!not mus prime!!!), g, n
    0.607 64.4 0.98 1.392];     %Carotid Artery 100%  (O_sat)
% %           
% %easy
% cfg.prop=[0 0 1 1;  %Properties of the materials.  anywhere cfg.vol == 0 will have properties in the first row (medium type 0)
%    0.01 21.6 0.9 1.39;%skin
%    0.005 12.9 0.9 1.39;%subcutaneous fat
%    0.01 5.07 0.9 1.39;%muscle
%    0.005 9.86 0.9 1.39; %deep tissue
%    mua650 mus650 g650 n650;   % IJV (70%) %mu_a mu_s (!!!not mus prime!!!), g, n
%      0.207 92.8 0.985 1.393];     %Carotid Artery 100%  (O_sat)

 cfg.outputtype='energy';    
 [flux,det,vol, seeds]=mcxlab(cfg);
 %save(fullfile('/usr3/graduate/raeef/Documents/MCX Simulations 2020_01_13/', 'all_detected_photons_2_0'),'det','cfg','-v7.3');

% 
% %Let's plot some fluxes
% %NB: Flux measurements depend on mua ~= 0
% h=figure;
% set(h,'Position',[36,672,1208,425])
% subplot(141)
% imagesc(squeeze(flux.data(30,:,:,5))')
% title('t=25 ps')
% subplot(142)
% imagesc(squeeze(flux.data(30,:,:,50))')
% title('t=250 ps')
% subplot(143)
% imagesc(squeeze(flux.data(30,:,:,100))')
% title('t=500 ps')
% subplot(144)
% imagesc(squeeze(flux.data(30,:,:,150))')
% title('t=750 ps')

%You can also plot the positions of detected photons
%which detector did the photon reach
det1Idx = find(det.detid == 1);
det2Idx = find(det.detid == 2);
det3Idx = find(det.detid == 3);
det4Idx = find(det.detid == 4);
det5Idx = find(det.detid == 5);
det6Idx = find(det.detid == 6);

detector = {};
for n = 1: 6
    detector{n}= find(det.detid == n);
end

skin= {};
skin_path={};
muscle={};
muscle_path ={};
deep= {};
deep_path={};
subcutaneous = {};
subcutaneous_path ={};
carotid_path = {};
ijv_path = {};
ijv = {};
carotid ={};
for n = 1: length(detector)
    i = detector{n};
    skin_path{n} = det.ppath(i,1);
    subcutaneous_path{n} = det.ppath(i,2);
    muscle_path{n} = det.ppath(i,3);
    deep_path{n} = det.ppath(i,4);
    carotid_path{n} = det.ppath(i,6);
    ijv_path{n} = det.ppath(i,5);
    ijv{n} = find(ijv_path{n} > 0);
    carotid{n} = find(carotid_path{n} > 0); 
    deep{n} = find(deep_path{n} > 0);
    muscle{n} = find(muscle_path{n} > 0); 
    skin{n} = find(skin_path{n} > 0);
    subcutaneous{n} = find(subcutaneous_path{n} > 0); 
   
end

%photon weights
unitinmm = cfg.unitinmm;
layer1_mua = cfg.prop( 2, 1); % in units of mm-1
layer2_mua = cfg.prop( 3, 1); % in units of mm-1
layer3_mua = cfg.prop( 4, 1); % in units of mm-1
layer4_mua = cfg.prop( 5, 1); % in units of mm-1
layer5_mua = cfg.prop( 6, 1); % in units of mm-1
layer6_mua = cfg.prop( 7, 1); % in units of mm-1

photon_weight = {};
thresh = {};
for n = 1:length(cfg.detpos)%number of SD separation
    photons(n) = length(ijv_path{n});
    pijv(n) = length(ijv{n})/photons(n)*100;
    pcarotid(n) = length(carotid{n})/photons(n)*100;
    pmuscle(n) = length(muscle{n})/photons(n)*100;
    
    %calculate photon weight by performing beer's law
    for i = 1: length (skin_path{n})
        photon_weight{n}(i) = 1*exp(-skin_path{n}(i)*unitinmm*layer1_mua)*exp(-subcutaneous_path{n}(i)*unitinmm*layer2_mua)*exp(-muscle_path{n}(i)*unitinmm*layer3_mua)*exp(-deep_path{n}(i)*unitinmm*layer4_mua)*exp(-ijv_path{n}(i)*unitinmm*layer5_mua)*exp(-carotid_path{n}(i)*unitinmm*layer6_mua);
    end
    total_detected_weight(j,n) = sum(photon_weight{n});
    
    
    %weighted
    pijv_w(j,n)= sum(photon_weight{n}(ijv {n}))/ total_detected_weight(j,n)*100 ;
    pcarotid_w(j,n) = sum(photon_weight{n}(carotid {n}))/total_detected_weight(j,n)*100 ;
    pmuscle_w(j,n)= sum(photon_weight{n}(muscle{n}))/total_detected_weight(j,n)*100 ;
end
end
% 
initial_weight = cfg.nphoton*1;
% weight_after_layer1 ={};
% weight_after_layer2 ={};
% weight_after_layer3 ={};
% 
% for n = 1:6
%     for i = 1: length (layer1_path{n})
%         weight_after_layer1{n}(i)= 1.* exp(-layer1_path{n}(i)*unitinmm*layer1_mua);
%         weight_after_layer2{n}(i) = weight_after_layer1{n}(i) .* exp(-layer2_path{n}(i)*unitinmm*layer2_mua);
%         weight_after_layer3{n}(i) = weight_after_layer2{n}(i) .* exp(-layer3_path{n}(i)*unitinmm*layer3_mua);
%     end
%     total_weight_after_layer1(n) = sum(weight_after_layer1{n});
%     total_weight_after_layer2(n) = sum(weight_after_layer2{n});
%     total_weight_after_layer3(n) = sum(weight_after_layer3{n});
% 
%     p_lostinlayer2(n)= abs(total_weight_after_layer1(n) - total_weight_after_layer2(n))./length (layer1_path{n})*100;
% 
% end


% convert mcx solution to mcxyz's output
% 'energy': mcx outputs normalized energy deposition, must convert
% it to normalized energy density (1/cm^3) as in mcxyz
% 'flux': cfg.tstep is used in mcx's fluence normalization, must 
% undo 100 converts 1/mm^2 from mcx output to 1/cm^2 as in mcxyz
if(strcmp(cfg.outputtype,'energy'))
    mcxdata=flux.data(:,:,:,90)/((cfg.unitinmm/10)^3);
else
    mcxdata=flux.data*100;
end

if(strcmp(cfg.outputtype,'flux'))
    mcxdata=mcxdata*cfg.tstep;
end


figure;
dim=size(cfg.vol);
yi=((1:dim(2))-floor(dim(2)/2))*cfg.unitinmm;
zi=(1:dim(3))*cfg.unitinmm;

imagesc(yi,zi,log10(abs(squeeze(mcxdata(40,:,:))))')
axis equal;
colormap(jet);
colorbar
% if(strcmp(cfg.outputtype,'energy'))
%     set(gca,'clim',[-2.4429 4.7581])
% else
%     set(gca,'clim',[0.5 2.8])
% end

% %jacobian
% 
% newcfg=cfg;
% newcfg.seed=seeds.data;
% newcfg.outputtype='jacobian';
% newcfg.detphotons=det.data;
% [flux2, det2, vol2, seeds2]=mcxlab(newcfg);
% jac=sum(flux2.data,4);
% figure
% imagesc(log10(abs(squeeze(jac(:,60,:)))))
% % 
% 
% %point spread function
% n=1.4; %index of refraction
% c_mmps = 3e11/n; %Speed of light in medium
% secPerSamp = 1e-12; %How many bins to split the tpsf into
% fs = 1/secPerSamp; %effective sampling rate
% 
% edges = 0:secPerSamp:10e-9; %Edges of the histogram
% %time steps
% tSteps = linspace(secPerSamp/2,max(edges)-secPerSamp/2, length(edges)-1);
% %Distance steps
% pathSteps = tSteps * c_mmps;
% %Frequency bins
% freqBins = ([0:length(tSteps)-1] * fs / length(tSteps))/1e6;
% 
% %define variables
% times= {};
% tpsf ={};
% weighted_tpsf= {};
% intervals = {};
% paddedTPSF={};
% paddedweightedTPSF= {};
% paddedFResp={};
% paddedweightedFResp= {};
% paddedBins = {};
% paddedBins_weighted={}; 
% amp ={};
% amp_weighted = {};
% phase= {};
% phase_weighted = {};
% 
% for n=1:6
%     %Transit times
%     switch n
%         case 1
%             times{n} = double((det.ppath(det1Idx, 1)+det.ppath(det1Idx, 2))/c_mmps);
%             
%         case 2
%             times{n} = double((det.ppath(det2Idx, 1)+det.ppath(det2Idx, 2))/c_mmps);
%             
%         case 3
%             times{n} = double((det.ppath(det3Idx, 1)+det.ppath(det3Idx, 2))/c_mmps);
%             
%         case 4
%             times{n} = double((det.ppath(det4Idx, 1)+det.ppath(det4Idx, 2))/c_mmps);
%             
%         case 5
%             times{n} = double((det.ppath(det5Idx, 1)+det.ppath(det5Idx, 2))/c_mmps);
%             
%         case 6
%             times{n} = double((det.ppath(det6Idx, 1)+det.ppath(det6Idx, 2))/c_mmps);
%     end
%    
%     %Calculate tpsf
%     tpsf{n} = histcounts(times{n},edges);
%     [weighted_tpsf{n} intervals{n}] = histwc(times{n} , photon_weight{n}, length(edges)-1);
% 
% 
%     
%     %Plot TPSF
% %     figure
% %     plot(tSteps/1e-9,tpsf{n})
% %     ylabel('Detected Photons')
% %     xlabel('Time (ns)')
% %     title('Temporal point spread function')
% %     
% %     figure
% %     plot(intervals{n}/1e-9,weighted_tpsf{n})
% %     ylabel('Detected Photons')
% %     xlabel('Time (ns)')
% %     title('Weighted Temporal point spread function')
% 
% 
%     %Translate tpsf to frequency response
%     paddedTPSF{n} = zeros(2^15,1); %Pad TPSF for smoothness
%     fResp = zeros(length(tSteps),1);
%     paddedTPSF{n}(1:length(tSteps)) = tpsf{n};
%     paddedFResp{n} = fft(paddedTPSF{n});
%     %Padded frequency bins
%     paddedBins{n} = ([0:(length(paddedFResp{n})-1)] * fs ./ length(paddedFResp{n}))/1e6; %MHz
% 
%     paddedweightedTPSF{n} = zeros(2^15,1); %Pad TPSF for smoothness
%     fResp = zeros(length(tSteps),1);
%     paddedweightedTPSF{n}(1:length(tSteps)) = weighted_tpsf{n};
%     paddedweightedFResp{n} = fft(paddedweightedTPSF{n});
%     %Padded frequency bins
%     paddedBins_weighted{n} = ([0:(length(paddedweightedFResp{n})-1)] * fs ./ length(paddedweightedFResp{n}))/1e6;
% 
%     %calculate amplitude and phase
%     amp{n} = abs(paddedFResp{n});
%     phase{n} = -angle(paddedFResp{n});
%     amp_weighted{n} = abs(paddedweightedFResp{n});
%     phase_weighted{n} = -angle(paddedweightedFResp{n});
%     
%     
%     figure
%     subplot(121)
%     plot(paddedBins{n},abs(paddedFResp{n}))
%     xlim([50,2000])
%     subplot(122)
%     plot(paddedBins{n},-angle(paddedFResp{n}))
%     xlim([50,2000])
% 
% 
%     
%     figure
%     subplot(121)
%     plot(paddedBins_weighted{n},abs(paddedweightedFResp{n}))
%     xlim([50,2000])
%     subplot(122)
%     plot(paddedBins_weighted{n},-angle(paddedweightedFResp{n}))
%     xlim([50,2000])
% 
% end 

%save(fullfile('/usr3/graduate/raeef/Documents/MCX Simulations 2020_02_10/', 'layer2photons_1a_50'),'layer1_path', 'layer2_path','layer2','majority_layer2','-v7.3');
save(fullfile('/usr3/graduate/raeef/Documents/MCX Simulations 2021_01_20 Skin Absorption', 'highres_model_muscleSCM_850nm_SimpsonLight_baseline'),'photon_weight','total_detected_weight','pcarotid_w', 'pijv_w', 'pmuscle_w','-v7.3') %'p_lostinlayer2','weight_after_layer1','weight_after_layer2', 'weight_after_layer3','-v7.3');
%save(fullfile('/usr3/graduate/raeef/Documents/MCX Simulations 2020_02_10/', 'amp_phase_1a_50'),'paddedBins', 'amp', 'amp_weighted', 'phase', 'phase_weighted','-v7.3');