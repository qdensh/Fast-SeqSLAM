function showPrecisionCurve(matches,targs,range,imageSkip,filename)
    
    
    % Compute empirical curves
    dvs = matches(:,2)';
    predicted = matches(:,1)';
    
    [TPR_emp, FPR_emp, PPV_emp] = precision_recall(targs, dvs, predicted,range,imageSkip);
    points = [TPR_emp,PPV_emp];
    filename = strcat('prcurve/',filename)
    save(filename,'points');
    
    cols = [200 45 43; 37 64 180; 0 176 80; 0 0 0]/255;
    figure,hold on;
    plot(TPR_emp, PPV_emp, '-o', 'color', cols(1,:), 'linewidth', 2);
    axis([0 1 0 1]);
    xlabel('TPR (recall)'); ylabel('PPV (precision)'); title('PR curves');
    set(gca, 'box', 'on');
end

% Computes empirical statistics based on classification output.
% 
% Usage:
%     [TPR, FPR, PPV, AUC, AP] = prc_stats_empirical(targs, dvs)
% 
% Arguments:
%     targs: true class labels (targets)
%     dvs: decision values output by the classifier
% 
% Return values:
%     TPR: true positive rate (recall)
%     FPR: false positive rate
%     PPV: positive predictive value (precision)
%     AUC: area under the ROC curve
%     AP: area under the PR curve (average precision)
% 
%     Each of these return vectors has length(desireds)+1 elements.
% 
% Literature:
%     K.H. Brodersen, C.S. Ong, K.E. Stephan, J.M. Buhmann (2010). The
%     binormal assumption on precision-recall curves. In: Proceedings of
%     the 20th International Conference on Pattern Recognition (ICPR).

% Kay H. Brodersen & Cheng Soon Ong, ETH Zurich, Switzerland
% $Id: prc_stats_empirical.m 5529 2010-04-22 21:10:32Z bkay $
% -------------------------------------------------------------------------
function [TPR, FPR, PPV, AUC, AP] = precision_recall(targs, dvs,predicted,range,imageSkip)
    
    % Check input
    %assert(all(size(targs)==size(dvs)));
    %assert(all(targs==-1 | targs==1));
    
    % Sort decision values and true labels according to decision values
    n = length(dvs);
    [dvs_sorted,idx] = sort(dvs,'descend'); 
    targs_sorted = targs(idx*imageSkip);
    predicted_sorted = predicted(idx)*imageSkip;
    
    % Inititalize accumulators
    TPR = repmat(NaN,1,n+1);
    FPR = repmat(NaN,1,n+1);
    PPV = repmat(NaN,1,n+1);
    
    % Now slide the threshold along the decision values (the threshold
    % always lies in between two values; here, the threshold represents the
    % decision value immediately to the right of it)
    fn = zeros(size(predicted_sorted));
    for thr = 1:length(dvs_sorted)+1
        % values greater than thr are positive and smaller than thr are NaN
        TP = sum(abs(targs_sorted(thr:end)-predicted_sorted(thr:end))<range);%you have to match whether  trgs(i) == dvs(i)
        FN = sum(~isnan(targs_sorted(1:thr-1)));
        TN = sum(isnan(targs_sorted(1:thr-1)));
        FP = sum(abs(targs_sorted(thr:end)-predicted_sorted(thr:end))>=range);
        
        TPR(thr) = TP/(TP+FN);%recall
        FPR(thr) = FP/(FP+TN);
        PPV(thr) = TP/(TP+FP);%precision
    end
    
    % Compute empirical AUC
    %[tmp,tmp,tmp,AUC] = perfcurve(targs,dvs,1);
    
    % Compute empirical AP
    %AP = abs(trapz(TPR(~isnan(PPV)),PPV(~isnan(PPV))));
    
end
