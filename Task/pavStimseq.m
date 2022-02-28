function pavStimseq(sID,prepFile)

%==========================================================================
% Code for calculating the trial sequence of the learning and transfer 
% phase, and the sequence of feedback validity, required response and iti 
% for the learning phase.
% This routine will load the pavPrep variable in which all paramaters have
% been stored after running pavParams, and stores the calculated
% sequences in the same variable.
%
% Hanneke den Ouden,
% start:        16-08-2009
% last changes: 02-08-2012
%
% Jennifer Swart,
% start:        30-01-2014
% last changes: 21-04-2015
%==========================================================================

% Calculate the stimulus sequence and the associated outcomes.
% =========================================================================

% A. Learning phase.
% -------------------------------------------------------------------------
clear prep;
load(prepFile);

% stimulus sequence and feedback validity per cue and response option.
[RG,fb,sfi]=pavCreateTrialSeq(prepFile,false);

prep.seq.learn.stim     = RG;
prep.seq.learn.feedback = fb;
prep.seq.learn.SFI      = sfi;
nTrial              = prep.par.learn.nTrial;
iti                 = prep.par.learn.time.ITI';
for iPart = 1:prep.par.nPart
    prep.seq.learn.resp{iPart}(RG{iPart}(:,1)>4,1) = 0; % requires nogo.
    prep.seq.learn.resp{iPart}(RG{iPart}(:,1)==1 | RG{iPart}(:,1)==3,1)= prep.par.key.left; % requires left.
    prep.seq.learn.resp{iPart}(RG{iPart}(:,1)==2 | RG{iPart}(:,1)==4,1)= prep.par.key.right; % requires right.
    
    % create random order of possible ITIs.
    prep.seq.learn.ITI{iPart}  = mix(repmat(iti,1,nTrial(iPart)/length(iti)))';
end
clear nTrial

% store actual probability of valid feedback.
prep.par.learn.prob = mean(mean(cell2mat(fb)));
    
% B. Transfer phase.
% -------------------------------------------------------------------------
% fixed sequence was generated on 05/3/2014 with the script pavTransferSeq. 
% Here we load the sequence.
load(fullfile('pavTransferSeq',sprintf('transferSeq_%d.mat',mod(sID,10))))
prep.seq.trans.stim      = BS;

% C. Save prep.
%--------------------------------------------------------------------------
save(prepFile,'prep');

end
