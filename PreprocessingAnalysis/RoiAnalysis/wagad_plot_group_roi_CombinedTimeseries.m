function fh = wagad_plot_group_roi_CombinedTimeseries(t, meanYIndiv, meanYSocial, ...
        stdYIndiv, stdYSocial, stringTitle, colourArray,fh)
    
%Plots mean (over trials) and s.e.m as shading for peristimulus time
%courses
%
%   fh = wagad_plot_roi_CombinedTimeseries(t1, y1, y2, nVoxels, nTrialsy1, nTrialsy2,stringTitle,colourLine);
%
% IN
%
% OUT
%
% EXAMPLE
%   wagad_plot_roi_CombinedTimeseries
%
%   See also wagad_extract_roi_timeseries tnueeg_line_with_shaded_errorbar

% Author:   Lars Kasper
% Created:  2019-05-26
% Copyright (C) 2019 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%

if nargin < 6
    fh = figure('Name', stringTitle);
end
tnueeg_line_with_shaded_errorbar(t, meanYIndiv', stdYIndiv', colourArray{1});
hold all;
tnueeg_line_with_shaded_errorbar(t, meanYSocial', stdYSocial', colourArray{2});
title(stringTitle);
xlabel('Peristimulus Time (seconds)');
ylabel('Signal Change (%)');

