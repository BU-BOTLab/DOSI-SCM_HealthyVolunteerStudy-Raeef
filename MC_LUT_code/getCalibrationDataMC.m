function cal=getCalibrationDataMC(avgCalData, cal_file, n,MC_tpsf, tVec, muspVec,freqStep)
%%%byh Calculates instrument response using measurement on phantom of known optical properties 

% calibration files need to be in path, will probably need to specify
% location at some point. . 
% phantom name must not have dash
% OUTPUT:
% cal.error
% cal.dist
% cal.AC
% cal.ACsd_AC_sqd
% cal.phase
% cal.phsd_sqd

    if avgCalData.error~=0
        cal.error=-1;
        return;
    end
    
    cal.dist = avgCalData.dist;
    nFreq=length(avgCalData.freq);         	%find number of data points
    noWt = ones(nFreq*2,1); %No weighting for calibration
    
    %%%byh For phantom files, standardized names are used which match up to
    %%%calibration files in the phantom directory.  the calibration files
    %%%consist of the phantom optical properties at a number of wavelengths.  The
    %%%wavelengths and optical properties are loaded here below 
    cfile=load(cal_file);
    %%%byh The wavelengths in the phantom files do not always match up to the fdpm wavelengths, 
    %%%so we do an interpolation of that dataset to get mua and mus at each
    %%%of the fdpm diode wavelengths
    pmua = interp1(cfile(:,1), cfile(:,2), avgCalData.wavelengths); %mua
    pmus = interp1(cfile(:,1), cfile(:,3), avgCalData.wavelengths); %mus
    cal.IRFz = complex(zeros(nFreq,avgCalData.nDiodes));
    for a=1:avgCalData.nDiodes
        %%%byh Forward calculation - for matlab purposes, the model is set up to return the
        %%%amplitude and phase as a single array, ampltiude at every
        %%%frequency followed by phase at each frequency
        theory=forwardMC( [pmua(a),pmus(a)], avgCalData.freq+(a-1)*freqStep, MC_tpsf, tVec, muspVec, n,1,0);
        real_phan = theory(1:nFreq);
        imag_phan = theory(1+nFreq:2*nFreq);  %in radians
        phanz = complex(real_phan,imag_phan);
        measz = complex(avgCalData.real(:,a),avgCalData.imag(:,a));
        
        cal.IRFz(:,a) = phanz./measz;
        
    end
    
cal.error=0;