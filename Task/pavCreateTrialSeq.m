function [RG,fb,sfi]=pavCreateTrialSeq(prepFile, plot)
% =========================================================================
% Create sequences for stimuli and feedback validity in Pav task.
% J.Swart, 2014.
% 
% This script is used to create sequences for feedback validity in the PAV
% version with 8 cues and 3 response options.
% In the main script a counter per cue and response option will be used to 
% select the next feedback validity, in order to guarantee that every 
% subject will have had the same feedback history when having selected the 
% response option per cue as often. This will keep the experienced 
% probabilities most close to the a-priori probability levels.
%
% First version:     14/3/2014. (Swart)
% Last changes:      21/4/2015. (Swart)
% =========================================================================
load(prepFile)

nTrial              = prep.par.learn.nTrial;
nStim               = prep.par.nStim;
nResp               = prep.par.nResp;
prob                = prep.par.learn.prob;

nRepPerBlockCue     = 5;
blocklength         = nRepPerBlockCue *nStim;
nBlockCue           = nTrial / (nRepPerBlockCue*nStim);

if prob == .7 || prob == .8
    nRepPerBlockFb      = 10;
elseif prob == .75
    nRepPerBlockFb      = 8;
else
    error('Please check if probability of feedback is specified correctly.\n\n');
end
nPartValid          = round(prob*nRepPerBlockFb);
nPartInvalid        = nRepPerBlockFb - nPartValid;
nBlockFb            = ceil(nTrial / (nRepPerBlockFb*nStim));

% The stimulus sequence of 'Go-to-win-left'(1),'Go-to-win-right'(2),'Go-to-avoid-left'(3),
% 'Go-to-avoid-right'(4),'NoGo-to-win'(5),'NoGo-to-win'(6),'NoGo-to-avoid'(7),'NoGo-to-avoid'(8),
% and feedback validity depending on specified probability. mixed in blocks.
% -------------------------------------------------------------------------

fb = cell(prep.par.nPart,nStim,nResp);
sfi = cell(prep.par.nPart,1);
for iPart = 1:prep.par.nPart
    % randomize stimulus sequence. Continue shuffling untill there are no more
    % than 2 stimulus repetitions.
    RGpart = [];
    for iBlock = 1:nBlockCue(iPart)
        stimseq = reshape(repmat(1:nStim,nRepPerBlockCue,1),1,blocklength);
        stimRep = 1;
        while ~isempty(stimRep)
            tmpRG       = mix(stimseq)';
            % find trials where the stimulus is the same as on the next trial.
            repetitionIdx = find(diff(tmpRG(:,1)) == 0);
            % check if there are more than two stim repetitions.
            stimRep = find(diff(repetitionIdx) == 1);
        end;
        RGpart = [RGpart; tmpRG];
    end
    RG{iPart} = RGpart;
    clear repetitionIdx stimRep iBlock
    
    % randomize feedback sequence per cue and per response option.
    feedseq = [ones(nPartValid,1);zeros(nPartInvalid,1)]';
    for iStim = 1:nStim
        for iResp = 1:nResp
            for iBlock = 1:nBlockFb(iPart)
                fb{iPart,iStim,iResp} = [fb{iPart,iStim,iResp}; mix(feedseq)'];
            end % end iBlock-loop.
        end
    end
    
    % randomize cue-feedback interval sequence.
    for iBlock = 1:ceil(prep.par.learn.nTrial(iPart) / numel(prep.par.learn.time.SFI))
        sfi{iPart} = [sfi{iPart}; mix(prep.par.learn.time.SFI)'];
    end % end iBlock-loop.
    sfi{iPart} = sfi{iPart}(1:prep.par.learn.nTrial(iPart));
        
end % end iPart-loop.

if plot
% plot sequences.
figure('stimulus sequence');
imagesc(RG');
title('stimulus sequence')

figure('sequence of feedback validity'); ct = 0;
for iResp = 1:nResp
    for iStim = 1:nStim
        ct = ct + 1;
        subplot(nStim,3,ct)
        imagesc(fb{iStim,iResp}');
        title(sprintf('Cue: %d, Resp: %d',iStim,iResp))
    end
end
end

