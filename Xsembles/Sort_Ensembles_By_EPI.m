function [EPIs_sorted,ensemble_id,avg_EPI_onoff] = Sort_Ensembles_By_EPI(EPI)
% Sort ensemble by Ensemble Participation Index (EPI). This function sort the ensembles by
% the number of neurons and EPI of them. First ensemble have more neurons with
% high EPIs (onsemble and offsemble neurons), and so on.
%
%       [EPIs_sorted,ensemble_id,avg_EPI_onoff] = Sort_Ensembles_By_EPI(EPI)
%
% Jesús Pérez-Ortega, Sep 2023

EPIs_on = EPI;
EPIs_on(EPIs_on<0) = 0;

EPIs_off = EPI;
EPIs_off(EPIs_off>0) = 0;

avg_EPIs_on = mean(EPIs_on,2);
avg_EPIs_off = mean(EPIs_off,2);
avg_EPI_onoff = avg_EPIs_on-avg_EPIs_off;

% Sort ensembles
[EPIs_sorted,ensemble_id] = sort(avg_EPI_onoff,'descend');
