%Script to test Monte Carlo method using simulated data
%%
%Constants needed to generate the temporal point spread function which is
%used for the forward model
secPerSamp = 1e-11;
endTime = 5e-9;
n=1.4;
unitInmm = 1;
NA = .55;
transFlag = 0;
muspVec = 0.1:.1:2;
SDSep = 25;
reImFlag = 1;
basedir_new = '../simulations/SD_25mm';
fname_new = 'semiInfRef';
[tpsf_new,tvec_new, fresp,fbins] = getTPSF_LUT(basedir_new,fname_new,secPerSamp,endTime,n,NA,unitInmm,1,transFlag);
%%
%"Calibrate" data from the p1 semi-infinite model so it matches the Monte
%Carlo model

rng(14850); %set random seed for consistency
numTrials = 100; %Number of OP pairs (on my PC 100 trails takes 78 seconds)
freqs = [155]'; %Frequency (or frequencies) to use

knownMuaVec =  zeros(1,numTrials);
knownMusVec =  zeros(1,numTrials);
recMuaVec =  zeros(1,numTrials);
recMusVec =  zeros(1,numTrials);
recLUTMuaVec = zeros(size(recMuaVec));
recLUTMusVec = zeros(size(recMusVec));

%Calculate the response using both p1 semi-infinite and monte carlo
calDiffusion = p1seminf([.01,.5],freqs,0,n,SDSep,0,1,reImFlag);
calMC = forwardMC( [.01,.5], freqs, tpsf_new, tvec_new, muspVec, n,reImFlag,0);
%Make them complex numbers
diffz = complex(calDiffusion(1:length(freqs)),calDiffusion(length(freqs)+1:end));
MCz = complex(calMC(1:length(freqs)),calMC(length(freqs)+1:end));
%Get the instrument response function
IRFz = MCz./diffz;

%%Generate the LUT if necessary
LUT=generateMCLUT(linspace(.0001,.1,1000),linspace(min(muspVec),max(muspVec),1000),SDSep,freqs);

%%Run the tests
tic
for i = 1:numTrials
    if mod(i,5) == 0
        fprintf('Working on %d of %d\n',i,numTrials)
    end
    %get random OP pair within the range
    mua = 0.0001 + (.1-.0001)*rand(1);
    mus = min(muspVec) + (max(muspVec)-min(muspVec)) * rand(1);
    knownMuaVec(i) = mua;
    knownMusVec(i) = mus;
    %Get forward data with diffusion approx.
    simFwd = p1seminf([mua,mus],freqs,0,n,SDSep,0,1,reImFlag);
    %Make complex number
    simz = complex(simFwd(1:length(freqs)),simFwd(length(freqs)+1:end));
    %Calibrate the complex number
    calz = simz.*IRFz;
    %Split complex number because that's what the inverse model expects
    calDat = [real(calz);imag(calz)];
    
    %Run both inverse models
    %simFwd = forwardMC( [mua,mus], freqs, tpsf_new, tvec_new, muspVec, n,reImFlag,0 );
    recOP = fitMuMC(freqs,calDat,tpsf_new,tvec_new,muspVec,n,reImFlag,0);
    [recLUTmua,recLUTmus] = getLUTOPs(LUT,calDat,0);
    %Store results
    recMuaVec(i) = recOP(1);
    recMusVec(i) = recOP(2);
    
    recLUTMuaVec(i) = recLUTmua;
    recLUTMusVec(i) = recLUTmus;
end
toc
%%
%Plotting
%Percent error
muaerr = mean((recMuaVec-knownMuaVec)./knownMuaVec)*100
muserr = mean((recMusVec-knownMusVec)./knownMusVec) * 100

figure
plot(knownMuaVec,recMuaVec,'o')
hold on
plot([0,.1],[0,.1],'k--')
xlabel('True \mu_a (mm^{-1})')
ylabel('Reconstructed \mu_a (mm^{-1})')
title('Absorption accuracy')
print('../plots/absAccuracy.png','-dpng')

figure
plot(knownMusVec,recMusVec,'o')
hold on
plot([.1,2],[0.1,2],'k--')
xlabel('True \mu_s'' (mm^{-1})')
ylabel('Reconstructed \mu_s'' (mm^{-1})')
title('Scattering accuracy')
print('../plots/scatAccuracy.png','-dpng')

figure
plot(knownMuaVec,knownMusVec,'o')
hold on
plot(recMuaVec,recMusVec,'.')
plot([.01,.05],[.01,.5],'k--')
xlabel('\mu_a (mm^{-1})')
ylabel('\mu_s'' (mm^{-1})')
title('Error Landscape')
legend('True','Recovered','location','southeast')
print('../plots/errorLandscape.png','-dpng')

figure
plot(knownMuaVec,recLUTMuaVec,'o')
hold on
plot([0,.1],[0,.1],'k--')
xlabel('True \mu_a (mm^{-1})')
ylabel('Reconstructed \mu_a (mm^{-1})')
title('Absorption accuracy')
print('../plots/absAccuracyLUT.png','-dpng')

figure
plot(knownMusVec,recLUTMusVec,'o')
hold on
plot([.1,2],[0.1,2],'k--')
xlabel('True \mu_s'' (mm^{-1})')
ylabel('Reconstructed \mu_s'' (mm^{-1})')
title('Scattering accuracy')
print('../plots/scatAccuracyLUT.png','-dpng')

figure
plot(knownMuaVec,knownMusVec,'o')
hold on
plot(recLUTMuaVec,recLUTMusVec,'.')
plot([.01,.05],[.01,.5],'k--')
xlabel('\mu_a (mm^{-1})')
ylabel('\mu_s'' (mm^{-1})')
title('Error Landscape')
legend('True','Recovered','location','southeast')
print('../plots/errorLandscapeLUT.png','-dpng')

figure

for i = 1:2:20
    plot(tvec_new,tpsf_new(:,i))
    hold on
end
