function PreprocessNewData(p_edf,p_output,ftype)
%PREPROCESSNEWDATA process inputs edfs and labels
%   PREPROCESSNEWDATA inputs a set of edfs and
%   filters, resamples and normalizes data. The data is now saved in a new
%   .txt format.
%
%   Input:  p_edf, folder locating edf files
%           p_output, output txt folder
%           ftype, file type (custom edf handling in LoadEDF.m)
%           Overwrite, to overwrite files in p_output

des_fs = 128;
dirIndex = paths;
f_edf = dir(p_edf);
f_edf = {f_edf.name};
% if not exist ftype, var. The default ftype is 'wsc'
if ~exist('ftype','var')
    ftype = 'wsc';
end

parfor i = 1:length(f_edf)
    fprintf('Processsing EDFs %.0f/%.0f\n',i,length(f_edf));
    try
        % Load and preprocess data
        % in /resources_matlab/LoadEDF.m -JH
        [hdr,data] = LoadEDF(p_edf, ftype);
        [hdr,data] = preprocess.resampleData(data,hdr,des_fs);
        if strcmp(ftype, 'mni')
            data = preprocess.filterData(data, hdr, 0);
        else
            data = preprocess.filterData(data, hdr, 1);
        end
        % JH - Load labels, SHOULD BE CHANGED DEPENDING ON HOW YOU
        % WANT TO LOAD AROUSAL LABELS. This may differ depending on
        % situation so as a "null default" I put zero matrix
        ar_seq = zeros(1, size(data, 2)/des_fs);
        W = ar_seq;
        % Save
        exportData(data,ar_seq,W,hdr,filepath(p_output,[f_edf{i}(1:end-4) '.txt']));
    catch me
        disp(me.message);
    end
end

