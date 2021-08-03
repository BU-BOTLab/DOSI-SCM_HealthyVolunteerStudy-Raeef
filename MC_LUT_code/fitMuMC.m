function [ calcOP, theoPAA, resid ] = fitMuMC( freqs, measuredPAA, tpsf, tvec, muspVec, n, reImFlag,WT )
%fitMuTransmission Uses Least Squares fitting to find the best OPs for a
%given set of measured data
%INPUTS: 
%freqs       //modulation frequencies that were used
%measuredPAA //measured phase and amplitude
%tpsf        //Temporal point spread function matrix based on MC simulation
%tvec        //Binned temporal bins
%muspVec     //scattering values associated with the white MC simulations
%n           //Index of refraction of the medium
%reImFlag    //Basis of fit: 0=log scaled amplitude and phase, 1 = real and
%            //imaginary parts of the data, 2=unscaled phase and amplitude
%OUTPUTS:
%calcOP      //Best fit optical properties to the data
%theoPAA     //Theoretical data (phase and amplitude or real/imaginary parts)
%resid       //Residual of the fit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
    pinitial =	[.006 .636;.01 .9;.0180 0.15;.05 .1]; %Starting points
    %Fit options
    o = optimset('display','off','TolFun',1e-12,'MaxFunEvals',1000);
    %Preallocate
    recoveredOP = zeros(size(pinitial));
    resid = zeros(size(pinitial,1),1);
    exitflag = resid;
    %Run the fit for each of the starting points
    for i = 1:size(pinitial,1)
        [f, resid(i),~,exitflag(i)] = lsqcurvefit('forwardMC',pinitial(i,:)',freqs, measuredPAA,[.0001,.1],[min(muspVec),max(muspVec)],o,tpsf,tvec,muspVec,n,reImFlag,WT);
        recoveredOP(i,:) = f';
    end
    %Find the best fit
    [~, best] = min(resid);
    calcOP = recoveredOP(best,:);
    %Calculate with the forward model
    theoPAA = forwardMC(calcOP,freqs,tpsf,tvec,muspVec,n,2,1);
end

