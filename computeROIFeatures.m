function [F] = computeROIFeatures(singleChannel, roisArr,dx, dy, Od)
% Copyright (C) 2016  Gregory L. Futia
% This work is licensed under a Creative Commons Attribution 4.0 International License


    if nargin < 5
        Od = 2;
    end
    
    OdN = floor(Od/2);
    
    %F.channelName = channelName;
    F.Od = Od;
    F.OdN = OdN;
    
    numParticles = length(roisArr);
    
    % initalize the variables
    F.totalSig_c = zeros(1, numParticles); %_c = counts
    F.totalSig_dBc = zeros(1, numParticles); %_dBc decibel counts
    F.CountsPerPixel_c = zeros(1, numParticles);
    F.numPixels = zeros(1, numParticles);
    F.x1m_m = zeros(1, numParticles);
    F.y1m_m = zeros(1, numParticles);
    F.radius_m = zeros(OdN, numParticles);
    F.totalSig_fxfy_c = zeros(1, numParticles);
    F.radius_invm = zeros(OdN, numParticles);
    F.M2 = zeros(OdN, numParticles);
    F.entropy_c_dB = zeros(1, numParticles);
        
    for kk=1:length(roisArr)
        bounds = struct(roisArr(kk).getBounds());
        poly = struct(roisArr(kk).getPolygon());     
        %bounds = struct(roisArr(kk).getPolygon().getBounds());       

        % have to use get field to avoid dot name ref to non scalar struct
        % error 
        x = getfield(poly, 'xpoints') - getfield(bounds, 'x');
        y = getfield(poly, 'ypoints') - getfield(bounds, 'y');

        mask = poly2mask(double(x),  double(y), bounds.height, bounds.width);
        xClip = [bounds.x:bounds.x+bounds.width-1];
        yClip = [bounds.y:bounds.y+bounds.height-1];    
        xArr = xClip*dx;
        yArr = yClip*dy;
        
        F.numPixels(kk) = sum(sum(mask));
        
        maskedObj = singleChannel(yClip, xClip).*mask;  
        % compute frequency domain representation
        [maskedImg_fxfy, fx, fy] = transformer2((maskedObj - mean(mean(maskedObj))), xArr, yArr); 
        
        F.totalSig_c(kk) = sum(sum(maskedObj));
        F.totalSig_fxfy_c(kk) = sum(sum(abs(maskedImg_fxfy)));
        F.x1m_m(kk) = (xArr*sum(maskedObj,1).')/F.totalSig_c(kk); % 1st moments
        F.y1m_m(kk) = yArr*sum(maskedObj, 2)/F.totalSig_c(kk);
        F.CountsPerPixel_c(kk) =  F.totalSig_c(kk)/F.numPixels(kk);
        F.entropy_c_dB = 10*log10(sum(sum(maskedObj.*log(maskedObj))));
        
        for jj = 1:OdN
            Odi = jj*2;
            % spatial moments
            R2 = ones(1,bounds.height).'*((xArr-F.x1m_m(kk)).^Odi) + ((yArr-F(1).y1m_m(kk)).^Odi).'*ones(bounds.width, 1).';
            r2m = sum(sum(maskedObj.*R2))/F.totalSig_c(kk);
            F.radius_m(jj, kk) = (r2m).^(1/Odi);
            % spatial frequency momements
            R2_fxfy =  ones(1,bounds.height).'*((fx).^Odi) +((fy).^Odi).'*ones(bounds.width, 1).';        
            r2m_fxfy = sum(sum(abs(maskedImg_fxfy).*R2_fxfy))/F.totalSig_fxfy_c(kk);
            F.radius_invm(jj, kk) = (r2m_fxfy)^(1/Odi);
            % space - spatial frequency product
            F.M2(jj, kk) = F.radius_m(jj, kk)*F.radius_invm(jj, kk);         
            
        end
        % prevent having log10(0) = inf
        maskedObj = maskedObj + 1;
        F.entropy_c_dB = 10*log10(sum(sum(maskedObj.*log(maskedObj))));        
    end
        F.totalSig_dBc = 10*log10(F.totalSig_c);    
end
