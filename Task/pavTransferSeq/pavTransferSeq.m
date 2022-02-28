% =========================================================================
% pavTransferSeq - Subfunction of the function pavStimseq(sID,day).
% =========================================================================
% Sequences created on 17/06/2015.
% By Jennifer Swart.
% -------------------------------------------------------------------------
% Subfunction used to create 10 random sequences of stimuli pairs for
% during the transfer phase, where no stimuli is repeated more than three
% times and where no pair is repeated at all.
% This version was adapted for the EEG study 2015 with 8 cues and 3 
% response options.In this version of the transfer phase no stimuli of the 
% same kind are compared (e.g. no Go2win-left vs. Go2win-right). This 
% results in 48 comparisons, which are conceptually the same as in the 
% Cavanagh 2013 study.
% -------------------------------------------------------------------------

% parameters.
nTrial      = 48;
nStim       = 8;

% all possible combinations.
all_choice  = [reshape(repmat(1:nStim,nStim,1),nStim^2,1) repmat(1:nStim,1,nStim)'];

% remove comparisons between the same cue type.
tmp         = [1:nStim 1:nStim; 1:nStim 2 1 4 3 6 5 8 7]';
for iPair = 1:length(tmp)
    all_choice(sum(ismember(all_choice,tmp(iPair,:)),2)==2,:)=[];
end
clear tmp

% control check - nChoice should only be equal to nTrial in case trials are not repeated.
nChoice     = length(all_choice);
if nChoice ~= nTrial; error('Please check cue combination for transfer phase!\n\n'); end

% create different combinations, taking the restrictions into account (see
% above).
for iSeq = 0:9
    
    pairRep = 1; stimRep = ones(nStim,1);
    while ~isempty(pairRep) || sum(stimRep) > 0
        
        % randomize sequence of stimuli pairs.
        idx         = mix(repmat(1:nChoice,1,ceil(nTrial/nChoice)));
        BS          = all_choice(idx,:);
        
        % create unique number per stimulus pairing.
        pairing     = BS(:,1).*BS(:,2);
        % find trials where the stimulus is the same as on the next trial.
        pairRep = find(diff(pairing) == 0);
        
        for iStim = 1:nStim
            % find trials where the stimulus is the same as on the next trial.
            repetitionIdx = find(diff(find(sum(BS == iStim,2))) == 1);
            % check if there are more than three stim repetitions.
            stimRep(iStim) = sum(diff(find(diff(repetitionIdx) == 1))==1);
        end
    end;
    
    filename = 'C:\Users\jenswa\Dropbox\EEGproject\task\PAV\pavTransferSeq\transferSeq_';
    filename = [filename num2str(iSeq)];
    
    save(filename,'BS')

    disp(['finished with sequence ' num2str(iSeq)])
end