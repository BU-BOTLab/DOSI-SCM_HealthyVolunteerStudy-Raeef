function [ tpsf_MC, tSteps, fResp_MC, fBins ] = getTPSF_LUT( basedir, base_fname,secPerSamp,endTime, n,NA,unitInmm,detNum,transFlag )
%getTPSF_LUT Returns a library of temporal point spread functions sampled
%at tSteps by reading in .mat files generated with MCX
%   basedir = The root directory with all the simulation results
%   base_fname = The name of the simulation results. The file name is
%   assumed to be of the form "base_fname_##_of_##.mat" and contains the
%   variable "det"
%   secPerSamp = How often do you want to sample the simulated TPSF?
%   Smaller values give worse SNR but better temporal response in seconds
%   endTime = How many bins to consider in the TPSF. Most simulations go to
%   zero after ~2.5 ns
%   n = the index of refraction of the medium

searchStr = sprintf('%s*.mat',base_fname);
numSims = length(dir(fullfile(basedir,searchStr)));

if numSims == 0
    error('There are no simulation results that match the given values for "basedir" and "base_fname"');
end
fs = 1/secPerSamp;
c_mmps = 3e11 / n; %Speed of light in medium (mm/s)
edges = 0:secPerSamp:endTime; %How many bins to use
tSteps = linspace(secPerSamp/2,max(edges)-secPerSamp/2, length(edges)-1); %Centers of the TPSF bins
fBins = ([0:(2^16-1)] * fs / 2^16)/1e6; %Frequency bins in MHz
tpsf_MC = zeros(length(tSteps),numSims); %Preallocate for TPSF
fResp_MC = zeros(2^16, numSims);
th = asin(NA/n);
  
for i = 1:numSims
  fprintf('Working on Sim %d of %d\n', i,numSims)
  %Load the simulation results  
  thisFile =sprintf('%s_%02d_of_%02d.mat',base_fname,i,numSims);
  load(fullfile(basedir,thisFile),'det');
  
  if transFlag
      z = acos(det.v(:,3));
  else
      z = acos(-det.v(:,3));
  end
  idx = find(det.detid==detNum & z<= 2*th);
  
  %Partial pathlengths in the medium (mm)
% if i == 9
%     q =23;
% end
  paths = det.ppath(idx)*unitInmm;

  %Time the photon was detected
  times = paths/c_mmps;
  %Count the number of photons that arrive in each temporal bin
  tpsf_MC(:,i) = histcounts(times,edges);
  paddedTPSF = zeros(2^16,1);
  paddedTPSF(1:length(tSteps)) = tpsf_MC(:,i);
  
  fResp_MC(:,i) = fft(paddedTPSF);

end

end



