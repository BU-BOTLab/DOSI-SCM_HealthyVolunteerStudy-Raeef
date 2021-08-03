function [ paa ] = forwardMC( OPs, freqs, MC_tpsf, tVec, muspVec, n,reImFlag,WT )
%transmission15mm Returns theoretical amplitude and phase values for
%transmission measurements through a 15 mm thick slab with OPs mua_guess
%and musp_guess
%  OPs is a 2 element vector [mua_guess, musp_guess]
%   mua_guess= Absorption coefficient in 1/mm
%   musp_guess = Reduced scattering coefficient in 1/mm
%   freqs = The desired modulation frequencies to return in MHz
%   MC_tpsf = The library of White Monte Carlo simulation temporal point
%   spread functions
%   tVec = The TPSFs are made by binning photon arrival times. tVec is the temporal location of the center of the bins
%   muspVec = The range of musp values simulated in the MC library
%   n = the index of refraction of the material
%   reImFlag //if 0 returns phase and log(amp), if 1, returns real/imag
%   parts, if 2 returns phase and amp
%OUTPUTS:
% paa //Phase and amplitude of the given OPs at freqs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        mua_guess = OPs(1);
        musp_guess = OPs(2);
        %if musp_guess > max(muspVec)
        %    musp_guess = max(muspVec);
        %end
        %if musp_guess < min(muspVec)
        %    musp_guess = min(muspVec);
        %end
        fs = 1/mean(diff(tVec)); %Find the sampling frequency to get frequency response
        c_mmps = 3e11/n; %Speed of light in the material (mm/s)
        pathSteps = tVec * c_mmps; %Path length for each of the temporal bins
        [T, Scat] = ndgrid(tVec,muspVec); %Form grid of time vs musp
        F = griddedInterpolant(T,Scat, MC_tpsf); %Generate interpolate object to interpolate new TPSF values
        [Tq, Scatq] = ndgrid(tVec,musp_guess); %Figure out where interpolation should take place
        if mua_guess >= 0
            Vq = F(Tq, Scatq) .* exp(-mua_guess* pathSteps)'; %Interpolate and scale for mua
        else
            Vq = F(Tq,Scatq);
        end
        %Pad the interpolated TPSF
        paddedVq = zeros(2^15,1); 
        paddedVq(1:length(Vq)) = Vq;
        %Calculate frequency bins
        bins = ((0:length(paddedVq)-1) * fs / length(paddedVq)) / 1e6;
        %FFT
        %fprintf('%.3f, %.3f\n',mua_guess,musp_guess);
        fResp = fft(paddedVq);
        %Get the amplitude and phase at the desired frequencies
        [paa] = mcx2paa(bins,fResp',freqs,reImFlag,WT);
        %x=4;
        
    
        
    %paa = [log(amp); phase];


end

