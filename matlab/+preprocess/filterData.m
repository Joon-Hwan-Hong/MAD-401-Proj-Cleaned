function data = filterData(data,hdr,filter_EKG)
%PREPROCESS.FILTERDATA filters input data after resampling.
%   data = PREPROCESS.FILTERDATA(data, hdr, filter_EKG) processes input
%   EEG, EOG, EMG and ECG data with a band-pass filter and RLS adaptive
%   filter to remove ECG artifacts in EMG, EOG and EMG signals.
%
%
%   Input:  data, EEG, EOG, EMG and ECG signals extracted with LoadEDF.
%           hdr, .edf header extracted with LoadEDF.
%           filter_EKG, boolean variable to use RLS filter.
%   Output: data, filtered data

% ****JH - iEEG recs do not have the same channel types as the poly data,
% ****need to change channel indicies; they were hard coded before me anyways.

% Channel indices
% idx_f1 = ismember(hdr.label,{'EEGC','EOGR','EOGL'});
% idx_f2 = ismember(hdr.label,{'EMG'});
% idx_r  = ismember(hdr.label,{'ECG'});
idx_f1 = ismember(hdr.label, {'LFus', 'RFus', 'ten twenty', 'EOG'});

% Iterate over channels
for i = 1:3
    if idx_f1(i)
        % Zero-phase filter of EEG and EOG with IIR band-pass filter.
        Hd = filter.eegFilter(hdr.fs(i));
        data(i,:) = filtfilt(Hd.sosMatrix, Hd.ScaleValues, data(i,:));
        % RLS adaptive filter
        if filter_EKG
            data(i,:) = preprocess.filterEKGArtefact(data(i,:),data(idx_r,:));
        end
    
    elseif idx_f2(i) % iEEG channels didnt seem to have EMG
        % Zero-phase filter of EMG with IIR band-pass filter.
        Hd = filter.emgFilter(hdr.fs(i));
        data(i,:) = filtfilt(Hd.sosMatrix, Hd.ScaleValues, data(i,:));
        % RLS adaptive filter
        if filter_EKG
            data(i,:) = preprocess.filterEKGArtefact(data(i,:),data(idx_r,:));
        end
    end
end
end