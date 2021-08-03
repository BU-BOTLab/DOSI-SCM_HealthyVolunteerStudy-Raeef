%%
%Script to test Monte Carlo based LUT on experimental data

%%First generate the Monte Carlo temporal point spread function matrix from
%%the simulation files
secPerSamp = 1e-11;
endTime = 10e-9;
n=1.4;
unitInmm = 1;
NA = .55;
transFlag = 0;
muspVec = 0.1:.1:2;
reImFlag = 1;
basedir_new = '../simulations/SD_25mm';
fname_new = 'semiInfRef';
[tpsf_new,tvec_new, fresp,fbins] = getTPSF_LUT(basedir_new,fname_new,secPerSamp,endTime,n,NA,unitInmm,1,transFlag);
%%
%Create the Lookup tables if needed
startFreq = 145;
SDSep = 25;
freqStep = 10; %Difference in modulation frequencies between wavelengths

LUT730=generateMCLUT(linspace(.0001,.05,1000),linspace(.1,2,1000),SDSep,startFreq);
LUT850=generateMCLUT(linspace(.0001,.05,1000),linspace(.1,2,1000),SDSep,startFreq+freqStep);
%%
%Next load the calibration data
%dataDir = '../data/Subject01/201105';
dataDir = 'U:\dDOSI\Data\SCM Healthy Volunteer Study 2020\Subject10\201209';
numDiodes = 2;
%Get file names of all the measurements of ACRIN9
fnames = dir(fullfile(dataDir,'ACRIN*miniLBS.asc'));
%Preallocate a cell array containing the locations of all of the
%calibration measurements
f = cell(1,length(fnames));
%Fill the array
for i = 1:length(fnames)
    f{i} = fullfile(dataDir,fnames(i).name);
end
%Average together all of the calibration measurements
avgCal=averageASCData(f,numDiodes,[.03,.3]);
%Calculate the system response based on the calibration data
calFact=getCalibrationDataMC(avgCal,'ACRIN9.txt',n,tpsf_new, tvec_new, muspVec,freqStep);

%%
%Quick test to see if we can accurately recover the ACRIN OPs given the
%calibrated ACRIN data
%Can comment out once done
rawDat = complex(avgCal.real,avgCal.imag);
calDat = rawDat .* calFact.IRFz;
ACR730 = [0.013063198,0.730825043];
ACR850 = [0.006557937,0.636148515];
test730=fitMuMC(startFreq,[real(calDat(1));imag(calDat(1))],tpsf_new,tvec_new,muspVec,n,1,0);
test850=fitMuMC(startFreq+freqStep,[real(calDat(2));imag(calDat(2))],tpsf_new,tvec_new,muspVec,n,1,0);
[test730LUT(1),test730LUT(2)] = getLUTOPs(LUT730,[real(calDat(1));imag(calDat(1))],0);
[test850LUT(1),test850LUT(2)] = getLUTOPs(LUT850,[real(calDat(2));imag(calDat(2))],0);
fprintf('ACRIN 730, Tabulated %.4f, %.4f, Monte Carlo: %.4f %.4f, LUT: %.4f, %.4f\n',ACR730(1),ACR730(2), test730(1),test730(2),test730LUT(1),test730LUT(2))
fprintf('ACRIN 850, Tabulated %.4f, %.4f, Monte Carlo: %.4f %.4f, LUT: %.4f, %.4f\n',ACR850(1),ACR850(2), test850(1),test850(2),test850LUT(1),test850LUT(2))


%%
%All tests look good, so now let's get down to the actual processing

%sampName = 'LongFlexion1-*.asc';
sampName = '*.asc';

fnames2 = dir(fullfile(dataDir,sampName));
%Preallocate a cell array containing the locations of all of the
%calibration measurements
f2 = cell(1,length(fnames2));
%Fill the array
for i = 1:length(fnames2)
    f2{i} = fullfile(dataDir,fnames2(i).name);
end
%Preallocate for results
sampMua = zeros(numDiodes,length(f2));
sampMus = zeros(numDiodes,length(f2));
amp = zeros(numDiodes,length(f2));
phase = zeros(numDiodes,length(f2));
tic
for i = 1:length(f2)
    raw = averageASCData(f2(i),numDiodes,[.03,.3]);
    rawz = complex(raw.real,raw.imag);
    calDat = rawz .* calFact.IRFz;
    amp(:,i) =raw.AC;
    phase(:,i) = raw.phase;
    for j = 1:numDiodes
        if j == 1
            [sampMua(j,i),sampMus(j,i)] = getLUTOPs(LUT730,[real(calDat(j));imag(calDat(j))],0);
        else
            [sampMua(j,i),sampMus(j,i)] = getLUTOPs(LUT850,[real(calDat(j));imag(calDat(j))],0);
        end
    end
end
toc
%Calculate chromophores
lams = [730,850];
extCoefs = getExtinctionCoefs('chromophores_ZijlstraKouVanVeen.txt',lams);
allChroms = zeros(size(sampMua));
for q = 1:size(sampMua,2)
    allChroms(:,q) = extCoefs(:,1:2)\sampMua(:,q);
end

OP_Data.names = fnames2;
OP_Data.amp = amp;
OP_Data.phase = phase;
OP_Data.mua = sampMua;
OP_Data.musp = sampMus;
OP_Data.chroms = allChroms *1000;


%%
%Plotting
figure
plot(sampMua(1,:))
hold on
plot(sampMua(2,:))
xlabel('Measurement number')
ylabel('\mu_a (mm^{-1})');
title('Absorption, subject01 long flex1')
l=legend('730','850','location','southwest');
title(l,'\lambda (nm)')
print('../plots/mua_sub01_longflex1.png','-dpng')

figure
plot(sampMus(1,:))
hold on
plot(sampMus(2,:))
xlabel('Measurement number')
ylabel('\mu_s'' (mm^{-1})');
title('Scattering, subject01 long flex1')
l=legend('730','850','location','northeast');
title(l,'\lambda (nm)')
print('../plots/mus_sub01_longflex1.png','-dpng')

figure
plot(allChroms(1,:)*1000,'r')
hold on
plot(allChroms(2,:)*1000,'b')
xlabel('Measurement number')
ylabel('Concentration (\muM)')
legend('Oxy','Deoxy')
title('Chromophores subject01 long flex 1')
print('../plots/chrom_sub01_longflex1.png','-dpng')