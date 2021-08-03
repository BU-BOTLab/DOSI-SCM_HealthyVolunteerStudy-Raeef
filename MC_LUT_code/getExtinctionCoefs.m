function [ chromExt ] = getExtinctionCoefs( fname, lams )
%getExtinctionCoefs -- parse a chromophore file and grab the extinction
%coefficients listed there for the wavelengths that are being used and
%returns them as a matrix for least squares estimation from mua

dat = dlmread(fname,'\t',1,0);
chromExt = zeros(length(lams),size(dat,2)-1);
for i = 1:size(chromExt,2)
    chromExt(:,i) = interp1(dat(:,1),dat(:,i+1), lams,'linear');
end
end

