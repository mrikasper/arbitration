function logp = linear_1stlevelprecision_reward_social(r, infStates, ptrans)
% Calculates the log-probability of choices and wagers in the arbitration
% task developed by Diaconescu, Stecy, Stephan and Tobler, 2015-2017
%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2014 Christoph Mathys, UCL; adapted by Andreea Diaconescu
% for WAGAD paper
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% Transform parameters to their native space
be0       = ptrans(1);
be1       = ptrans(2);
be2       = ptrans(3);
be3       = ptrans(4);
be4       = ptrans(5);
be5       = ptrans(6);
be6       = ptrans(7);
ze        = exp(ptrans(8)); % social bias
be_ch     = exp(ptrans(9)); % decision noise for choice
be_wager  = exp(ptrans(10));% noise wager

% Initialize returned log-probabilities as NaNs so that NaN is
% returned for all irregualar trials
logp_ch = NaN(length(infStates),1);
logp_wager = NaN(length(infStates),1);
logp = NaN(length(infStates),1);
n = size(infStates,1);

% Weed irregular trials out from responses and inputs
y = r.y(:,1);
y(r.irr) = [];

u = r.u(:,1);
u(r.irr) = [];

advice_card_space = r.u(:,3);

% Extract trajectories of interest from infStates
mu1hat_a = infStates(:,1,3);
mu1hat_a(r.irr) = [];
mu1hat_r = infStates(:,1,1);
mu1hat_r(r.irr) = [];
mu2hat_a = infStates(:,2,3);
mu2hat_a(r.irr) = [];
mu2hat_r = infStates(:,2,1);
mu2hat_r(r.irr) = [];
sa2hat_r = infStates(:,2,2);
sa2hat_r(r.irr) = [];
sa2hat_a = infStates(:,2,4);
sa2hat_a(r.irr) = [];
mu3hat_r = infStates(:,3,1);
mu3hat_r(r.irr) = [];
mu3hat_a = infStates(:,3,3);
mu3hat_a(r.irr) = [];

% Transform the card colour
transformed_mu1hat_r = mu1hat_r.^advice_card_space.*(1-mu1hat_r).^(1-advice_card_space);

% Decisions
y_ch = r.y(:,1);
y_ch(r.irr) = [];

% Calculate log-probabilities for non-irregular trials
y_wager = r.y(:,2);
y_wager(r.irr) = [];

%% Belief Vector
% Precision 1st level (i.e., Fisher information) vectors
px = 1./(mu1hat_a.*(1-mu1hat_a));
pc = 1./(mu1hat_r.*(1-mu1hat_r));

% Weight vectors 1st level
wx = ze.*px./(ze.*px + pc); % precision first level
wc = pc./(ze.*px + pc);

% Belief and Choice Noise
b              = wx.*mu1hat_a + wc.*transformed_mu1hat_r;
decision_noise = be_ch;

% Integrated Belief
% ~~~~~~~~
x = b;

% Avoid any numerical problems when taking logarithms close to 1
logx = log(x);
log1pxm1 = log1p(x-1);
logx(1-x<1e-4) = log1pxm1(1-x<1e-4);
log1mx = log(1-x);
log1pmx = log1p(-x);
log1mx(x<1e-4) = log1pmx(x<1e-4); 

% Calculate log-probabilities for non-irregular trials
reg = ~ismember(1:n,r.irr);
logp_ch(reg) = y_ch.*decision_noise.*(logx -log1mx) +decision_noise.*log1mx -log((1-x).^decision_noise +x.^decision_noise);
% res(reg) = (y_ch-x)./sqrt(x.*(1-x));

% Irreducible uncertainty
% ~~~~~~~~
uncertainty = b.*(1-b);

% Arbitration
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
arbitration = wx;

% Inferential variance (aka informational or estimation uncertainty, ambiguity)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
inferv_a = tapas_sgm(mu2hat_a, 1).*(1 -tapas_sgm(mu2hat_a, 1)).*sa2hat_a; 
inferv_a(r.irr) = [];

inferv_r = tapas_sgm(mu2hat_r, 1).*(1 -tapas_sgm(mu2hat_r, 1)).*sa2hat_r; 
inferv_r(r.irr) = [];

% Phasic volatility (aka environmental or unexpected uncertainty)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pv_a = tapas_sgm(mu2hat_a, 1).*(1-tapas_sgm(mu2hat_a, 1)).*exp(mu3hat_a); 
pv_a(r.irr) = [];
pv_r = tapas_sgm(mu2hat_r, 1).*(1-tapas_sgm(mu2hat_r, 1)).*exp(mu3hat_r); 
pv_r(r.irr) = [];

% Calculate predicted log-reaction time
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
logrt    = be0 + be1.*uncertainty + be2.*arbitration + be3.*inferv_a + be4.*inferv_r + be5.*pv_a + be6.*pv_r;
wager = logrt;

% Calculate log-probabilities for non-irregular trials
% Note: 8*atan(1) == 2*pi (this is used to guard against
% errors resulting from having used pi as a variable).
logp_wager(reg)         = -1/2.*log(8*atan(1).*be_wager) -(y_wager-wager).^2./(2.*be_wager);
logp(reg)               = logp_ch + logp_wager; 


return;
