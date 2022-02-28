% =========================================================================
% This script runs a short practice block, using each cue once.
%
% Hanneke den Ouden,
% last changes  06-08-2010
%
% Jennifer Swart,
% start:        04-02-2014
% last changes: 11-05-2015
% =========================================================================

% Run practice trials.
%--------------------------------------------------------------------------

% Make screen to black before starting.
blackscreen;
WaitSecs(1);

aborted                 = false;
tm.pract.taskStart(iSes)= GetSecs;
fprintf(logfile, 'INSTRUCTIONS PART %d.\n', iSes);
fprintf(logfile, 'tm.pract.taskStart:\t%d   \n\n', tm.pract.taskStart(iSes));
nTrial                  = prep.par.pract.nRep;

% stimulus sequence, required response and feedback validity.
reqResp         = [prep.par.key.instr.left 0 prep.par.key.instr.right];
reqResp         = reqResp(iResp);
iStim           = iResp;
invalidfb       = nTrial-mod(iSes*2-1,nTrial);
seq.feedback    = ones(1,nTrial)'; 
seq.feedback(invalidfb) = 0;

% loop over trials.
for iTrial = 1:nTrial
    
    % stimulus presentation.
    wd = pavDrawStim(wd,prep,4,iStim,[],[],img,[],[]);
    tm.pract.stim(iSes,iTrial) = Screen(wd,'Flip');
    
    % determine Go vs NoGo.
    if prep.par.instr.keymode  == 1
        B.clearResponses()
        [resp,t] = B.getResponse(prep.par.learn.time.stim,false);
    else
        [resp,t] = KeyboardResponse(prep.par.learn.time.stim,false);
    end
    results.pract.response(iSes,iTrial)    = resp;
    tm.pract.response(iSes,iTrial)         = t;
    results.pract.RT(iSes,iTrial)          = t - tm.pract.stim(iSes,iTrial);
    results.pract.go(iSes,iTrial)          = resp > 0;
    
    % stimulus-feedback interval.
    Screen('FillRect',wd,backgroundCol);
    drawfix;
    tm.pract.sfi(iSes,iTrial) = Screen('Flip', wd);
    
    % determine feedback.
    acc         = results.pract.response(iSes,iTrial) == reqResp;
    valid       = seq.feedback(iTrial);
    results.pract.acc(iSes,iTrial) = acc;
    results.pract.outcome(iSes,iTrial) = abs(acc + valid -1); % 0 = neutral, 1 = reward.
    
    % display feedback.
    if results.pract.outcome(iSes,iTrial) == 0;
        if strcmp(prep.par.lang,'ned')
            abd = 'Fout.';
        elseif strcmp(prep.par.lang,'eng')
            abd = 'Bad.';
        end
    else
        if strcmp(prep.par.lang,'ned')
            abd = 'Goed.';
        elseif strcmp(prep.par.lang,'eng')
            abd = 'Good.';
        end
    end
    [wt] = Screen('TextBounds',wd,abd);
    xpos = round(wdw/2-wt(3)/2);
    ypos = round(wdh/2-wt(4)/2);
    Screen('Drawtext',wd,abd,xpos,ypos);
    WaitSecs('UntilTime',tm.pract.sfi(iSes,iTrial) + prep.par.pract.SFI);
    tm.pract.outcome(iSes,iTrial) = Screen(wd, 'Flip');
     
    % ITI.
    Screen('FillRect',wd,backgroundCol);
    drawfix;
    WaitSecs('UntilTime',tm.pract.sfi(iSes,iTrial) + prep.par.pract.SFI ...
        + prep.par.pract.time.feedback);
    Screen('Flip', wd);
    
    % abort trial?.
    [results.pract.abort(iSes),tm.pract.abort(iSes)] = KeyboardResponse(prep.par.learn.time.ITI,true);
    
    % check if aborted.
    if ismember(results.pract.abort(iSes),prep.par.key.abort)
        aborted = true;
        tm.prep.abort(iSes)  = GetSecs;
        if strcmp(prep.par.lang,'ned')
            abd = 'Je hebt de taak gestopt.';
        elseif strcmp(prep.par.lang,'eng')
            abd = 'You have aborted the task.';
        end
        [wt] = Screen('TextBounds',wd,abd);
        xpos = round(wdw/2-wt(3)/2);
        ypos = round(wdh/2-wt(4)/2);
        Screen('Drawtext',wd,abd,xpos,ypos,prep.par.col.white);
        tm.pract.Endtext(iSes) = Screen('flip', wd,[]);
        fprintf(logfile, '\ntAborted\t\t%0.7g \n\n',...
            tm.pract.abort(iSes) - tm.pract.taskStart(iSes));
        WaitSecs(1);
        Screen('FillRect',wd,backgroundCol);
        Screen('Flip', wd);
        break
    end
    
    % saving
    save(resultsFile,'today','results','tm','prep');
    
    % wait till time and start new trial:
    WaitSecs('UntilTime',tm.pract.sfi(iSes,iTrial) + prep.par.pract.SFI ...
        + prep.par.pract.time.feedback + prep.par.pract.time.ITI);
    tm.pract.trialend(iSes,iTrial) = GetSecs;
    
end % end of trial loop

blackscreen;
WaitSecs(1);