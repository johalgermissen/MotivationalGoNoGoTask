function pavRun
%==========================================================================
% Main code to run the Pavlovian Go/NoGo task. This version is developed
% for the EEG study 2015 with 8 cues and 3 response options (Go-left/right,
% NoGo).
%
% Hanneke den Ouden,
% start:        16-08-2009
% last changes  19-10-2009
%
% Jennifer Swart,
% start:        30-01-2014
% last changes: 04-05-2015
%
% Jessica Määttä,
% start:        29-04-2015
% last changes  29-04-2015

% see pavParams for Bitsi codes.
%==========================================================================

sID         = input('Subject ID (1-999): ');
pavDefault  = input(['======================================\n',...
    'DEFAULTS:\n',...
    '   - Language:         English\n',...
    '   - Directories:      current folder\n',...
    '   - Skip MRI: yes\n',... 
    '   - Run instructions: yes\n',...
    '   - Run part 1 and 2: yes\n',...
    '======================================\n',...
    'Run defaults? yes(1)/no(0): ']);

if pavDefault
    lang     = 1;
    runInstr = 0;
    skipMRI  = 1;
    part     = 1;
    dirOut   = 1;
else
    fprintf(['\n---------------------------------------\n\n\n',...
        '---------------------------------------\n',...
        'ALTERNATIVE TASK SETTINGS.\n',...
        '---------------------------------------\n']);
    lang     = input('language: eng(1)/ned(2): ');
    runInstr = input('Run(1)/skip(0) instructions? ');
    skipMRI  = input('Skip(1)/run(0) MRI? ');
    part     = input('Run script from the beginning? yes(1)/no(0): ');
    if part == 0
        part = input('Start with part 1(1) or part 2(2)? ');
    end
    dirOut   = input('Use default logfile directory(1) or specify manually(0)? ');
    if ~dirOut
        dirOut = input('Directory name for logfiles: ');
    end
end

% PARAMETERS THAT NEED TO BE MODIFIED
%==========================================================================
% debug       = input('debug mode? (1 = yes, 0 = no): ');
debug = 0;

% file and directory names
subTag      = sprintf('3017042.02_emmvdij_%03.0f_001',sID);
if dirOut == 1
    dirOut 		= fullfile(cd,'Log',subTag);
end
prepFile        = fullfile(dirOut,sprintf('%s_prep.mat',subTag));
resultsFile     = fullfile(dirOut,sprintf('%s_results.mat', subTag));
logFileName     = fullfile(dirOut,sprintf('%s_log',subTag));
timingFileName  = fullfile(dirOut,sprintf('%s_timing',subTag));
%==========================================================================

% If resultsFile already exists, create unique resultsFile.
createPrep = 1;
if exist(resultsFile,'file')
    randAttach      = round(rand*10000);
    resultsFile     = sprintf('%s_%04.0f.mat',resultsFile(1:end-4),randAttach);
    logFileName     = sprintf('%s_%04.0f.txt',logFileName(1:end-4),randAttach);
    timingFileName  = sprintf('%s_%04.0f',timingFileName,randAttach);
    useOldPrep      = input(['-------------------------------------------------\n',...
        '\n\n-------------------------------------------------\n',...
        'WARNING: Prep file already exists.\n',...
        'It''s prefered to use the old prep file!\n',...
        '-------------------------------------------------\n',...
        'Use old prep file(1) or create new file(0)? ']);
    if ~useOldPrep
        prepFile = sprintf('%s_%04.0f.mat',prepFile(1:end-4),randAttach);
    else
        createPrep = 0;
    end
end % end if exist(resultsFile,'file').

% check if output directory exists.
if ~exist(dirOut,'dir')
    mkdir(dirOut);
end

% A.    Getting started
%--------------------------------------------------------------------------
rand('state',sum(100*clock));   % initialize random number generator

if createPrep
    % get and store the experimental parameters in prep.
    pavParams(sID,lang,prepFile,skipMRI);
    % calculate the trial sequence.
    pavStimseq(sID,prepFile);
end

load(prepFile);

% Bitsi setup.
if prep.par.comport == 2
    delete(instrfind); % otherwise it won't find the port! ('COM#').
    B = Bitsi(prep.par.comB);
    if skipMRI == 0
       B_MRI = Bitsi(prep.par.comMRI);
    end
end

% Set stuff up (log files, variables etc.), start PTB - Screen.
pavSetup
inTransfer = false;


% B.1    INSTRUCTIONS.
%--------------------------------------------------------------------------
if runInstr == 1; pavInstr; end
if skipMRI == 0; pavInstrShort; end
inInstructions = false;

% keyboard;
% B.clearResponses(); 
% B.getResponse(10*60,true);

% B.2    LEARNING PHASE.
%--------------------------------------------------------------------------

% prepare some values.
tm.taskStart{part}  = GetSecs;
pavSendTrigger(prep,B,prep.par.code.startExp);
aborted             = false;
paused              = false;
breaktime           = 0;

if strcmp(prep.par.lang, 'ned')
    txtBreak = {'Wacht op de onderzoeker om verder te gaan met de taak.',...
        ' ','(Controleer of de opname gestart is voordat de taak wordt gestart.)'};
elseif strcmp(prep.par.lang, 'eng')
    txtBreak = {'Wait for the researcher to continue.',' ',...
        '(Please turn on the recording before continuing)'};
end
tm.learn{part}.break(1) = disptxt(txtBreak,wd,wdw,wdh,0,0,prep.par.col.white,0,0);
% WaitSecs(2);
% inBreak = true;
% while inBreak
%     resp = KeyboardResponse(inf,true);
%     if resp == prep.par.key.resume
%         blackscreen;
%         WaitSecs(1);
%         clear resp
%         inBreak = false;
%     end
% end % end while inBreak.

    
for iPart = part:prep.par.nPart
    
    fprintf(logfile, 'PART %d.\n', iPart);
    fprintf(logfile, 'tm.taskStart:\t\t%d   \n\n', tm.taskStart{iPart});
    nTrial              = prep.par.learn.nTrial(iPart);
    iBlock              = 0;
    missedCt            = 0;
    ct                  = ones(prep.par.nStim,prep.par.nResp);
    WaitSecs(1);
     
    % loop over trials.
    for iTrial = 1:nTrial
        
        % check whether to continue at beginning of each block.
        pavStartBlock; % here wait for trigger if fMRI
        if aborted; break; end
        
        % stimulus presentation.
        iStim   = prep.seq.learn.stim{iPart}(iTrial);
        wd      = pavDrawStim(wd,prep,1,prep.seq.learn.stim{iPart},results,iTrial,img,[],iPart);
        tm.learn{iPart}.stim(iTrial,1) = Screen(wd, 'Flip');
        pavSendTrigger(prep,B,prep.par.code.startTrial(iStim));
        
        % record responses during stimulus presentation.
        [resp,t,aborted,paused] = pavCheckResponse(prep.par.learn.time.stim,true,...
            prep,B,aborted,paused,false);
        results.learn{iPart}.response(iTrial,1) = resp(1);
        tm.learn{iPart}.response(iTrial,1) = t;
        
        % stimulus offset.
        Screen('FillRect',wd,backgroundCol);
        drawfix;
        WaitSecs('UntilTime',tm.learn{iPart}.stim(iTrial,1)+prep.par.learn.time.stim);
        tm.learn{iPart}.sfi(iTrial,1) = Screen('Flip', wd);
        pavSendTrigger(prep,B,prep.par.code.sfi);
        
        % determine Go vs NoGo.
        if results.learn{iPart}.response(iTrial,1) > 0 % Go response.
            results.learn{iPart}.go(iTrial,1) = 1;
            results.learn{iPart}.RT(iTrial,1) = tm.learn{iPart}.response(iTrial,1) - tm.learn{iPart}.stim(iTrial,1);
            [~,~,aborted,paused] = pavCheckResponse(prep.seq.learn.SFI{iPart}(iTrial)-.01,true,...
                prep,B,aborted,paused,true);
        else % NoGo response.
            results.learn{iPart}.go(iTrial,1) = 0;
            % check for responses after stim offset.
            [lateResp,lateT,aborted,paused] = pavCheckResponse(prep.seq.learn.SFI{iPart}(iTrial)-.01,true,...
                prep,B,aborted,paused,false);
        end
        
        % determine accuracy..
        acc         = results.learn{iPart}.response(iTrial,1) == prep.seq.learn.resp{iPart}(iTrial);
        results.learn{iPart}.acc(iTrial,1) = acc;
        % determine associated outcome, taking feedback validity in account.
        iResp       = find(results.learn{iPart}.response(iTrial,1) == [0 prep.par.key.left prep.par.key.right]);
        if isempty(iResp)
            if ~aborted && ~paused
                pavErrorinstr
                missedCt = missedCt +1;
            end
        else
            valid       = prep.seq.learn.feedback{iPart,iStim,iResp}(ct(iStim,iResp));
            ct(iStim,iResp) = ct(iStim,iResp)+1;
            if ismember(prep.seq.learn.stim{iPart}(iTrial),prep.par.rewStim)
                results.learn{iPart}.outcome(iTrial,1) = abs(acc + valid -1); % 0 = neutral, 1 = reward.
                outcomeID = results.learn{iPart}.outcome(iTrial,1) + 3;
            elseif ismember(prep.seq.learn.stim{iPart}(iTrial),prep.par.punStim)
                results.learn{iPart}.outcome(iTrial,1) = abs(acc + valid -1) - 1; % 0 = neutral, -1 = punishment.
                outcomeID = results.learn{iPart}.outcome(iTrial,1) + 2;
            end
            
            % outcome.
            wd = pavDrawStim(wd,prep,2,prep.seq.learn.stim{iPart},results,iTrial,img,[],iPart);
            WaitSecs('UntilTime',tm.learn{iPart}.sfi(iTrial,1) + prep.seq.learn.SFI{iPart}(iTrial));
            tm.learn{iPart}.outcome(iTrial,1) = Screen(wd, 'Flip');
            pavSendTrigger(prep,B,prep.par.code.outcome(outcomeID));
            % Give opportunity for the researcher to abort trial:
            [~,~,aborted,paused] = pavCheckResponse(prep.par.learn.time.feedback-.01,true,...
                prep,B,aborted,paused,true);
            
            % ITI start.
            Screen('FillRect',wd,backgroundCol);
            drawfix;
            WaitSecs('UntilTime',tm.learn{iPart}.stim(iTrial,1) + prep.par.learn.time.stim + ...
                prep.seq.learn.SFI{iPart}(iTrial) + prep.par.learn.time.feedback);
            tm.learn{iPart}.iti(iTrial) = Screen('Flip', wd);
            pavSendTrigger(prep,B,prep.par.code.iti);
            
        end % end if-isempty(iResp).
        
        tic
        
        % store data for late responses (but mark response as NoGo).
        if results.learn{iPart}.go(iTrial,1) == 0 && lateResp(1) > 0
            results.learn{iPart}.response(iTrial,1) = lateResp(1);
            tm.learn{iPart}.response(iTrial,1) = lateT;
            results.learn{iPart}.RT(iTrial,1) = tm.learn{iPart}.response(iTrial,1) - tm.learn{iPart}.stim(iTrial,1);
        end
        
        %  making logs.
        fprintf(logfile, 'Trial %d:\t\t \n', iTrial);
        fprintf(logfile, 'stimulustype: \t\t%s\n',prep.par.stimID{prep.seq.learn.stim{iPart}(iTrial,1)});
        fprintf(logfile, 'Go(1)/NoGo(0):\t\t%d\n',results.learn{iPart}.go(iTrial,1));
        fprintf(logfile, 'response:     \t\t%d\n',results.learn{iPart}.response(iTrial,1));
        fprintf(logfile, 'accuracy:     \t\t%d\n',results.learn{iPart}.acc(iTrial,1));
        fprintf(logfile, 'RT(ms):       \t\t%0.7g\n',results.learn{iPart}.RT(iTrial,1)*1000);
        if ~isempty(iResp)
            fprintf(logfile, 'Outcome:      \t\t%s\n\n',prep.par.learn.outcomeID{results.learn{iPart}.outcome(iTrial,1)+2});
        end
        
        % calculate precise time to start the new stimulus; use the stored
        % times of how long every step is supposed to take to calculate at what
        % time precisely we should start the new trial (it's to avoid any build
        % up of slight delays).
        % when using a poisson, or other random distribution
        %     total_time=(sum(prep.stim.ISI(1:t,:))+t*prep.par.time.feedback+sum(prep.stim.ITI(1:t,:)));
        % when using a set time
        total_time = iTrial * (prep.par.learn.time.stim + prep.par.learn.time.feedback) ...
            + sum(prep.seq.learn.SFI{iPart}(1:iTrial)) + sum(prep.seq.learn.ITI{iPart}(1:iTrial-1));
        
        % saving.
        save(resultsFile,'today','results','tm','prep');
        
        t = toc;
        
        % Give opportunity for the researcher to abort trial:
        [~,~,aborted,paused] = pavCheckResponse(prep.seq.learn.ITI{iPart}(iTrial)-t-.1,true,...
            prep,B,aborted,paused,true);
        
        % wait till end iti to start new trial.
        WaitSecs('UntilTime',tm.taskStart{iPart} + total_time + breaktime + 3*missedCt);
        tm.learn{iPart}.trialend(iTrial,1) = GetSecs;
        pavSendTrigger(prep,B,prep.par.code.endTrial);
        
        [breaktime,tm,paused] = pavCheckPause(prep,B,aborted,paused,1,tm,wd,...
            breaktime,logfile,iPart);
        if aborted; break; end
        
        % break for subject after specified number of trials.
        if ismember(iTrial,prep.par.learn.break)
            WaitSecs(15);
            blackscreen;
            if strcmp(prep.par.lang, 'ned')
                txtBreak = {'Pauze.','(Stop scanner)',' ',...
                    'Wacht op de onderzoeker om verder te gaan met de taak.'};
            elseif strcmp(prep.par.lang, 'eng')
                txtBreak = {'Break.','(Stop scanner)',' ','Wait for the researcher to continue.'};
            end
            tBreak = disptxt(txtBreak,wd,wdw,wdh,0,0,prep.par.col.white,0,0);
            tm.learn{iPart}.break(iBlock+1) =  tBreak;
            pavSendTrigger(prep,B,prep.par.code.break);
            fprintf(logfile,'\ntBreak:\t\t\t%0.7g \n\n',tBreak - tm.taskStart{iPart});
            WaitSecs(2);
%             inBreak = true;
%             while inBreak
%                 resp = KeyboardResponse(inf,true);
%                 if resp == prep.par.key.resume
%                     blackscreen;
%                     Screen(wd, 'Flip');
%                     clear resp
%                     inBreak = false;
%                 end
%             end % end while inBreak.
        end % end if ismember.
        
    end % end of iTrial-loop.
    
    tm.taskEnd{iPart} = GetSecs;
    fprintf(logfile, 'tm.taskEnd:\t\t%d   \n\n', tm.taskEnd{iPart});
    pavSendTrigger(prep,B,prep.par.code.endExp);
    
    % calculate the total number of rewards and punishments received.
    results.totR(iPart) = length(find(results.learn{iPart}.outcome == 1));
    results.totP(iPart) = length(find(results.learn{iPart}.outcome == -1));
    results.totN(iPart) = length(find(results.learn{iPart}.outcome == 0));
    results.tot(iPart) = results.totR(iPart) - results.totP(iPart);

    if iPart == 1 && prep.par.nPart > 1
        tm.taskStart{iPart + 1}         = GetSecs;
        pavSendTrigger(prep,B,prep.par.code.startExp);
        tm.learn{iPart + 1}.break(1)    = GetSecs;
        breaktime                       = 0;
        aborted = false;
        pavToNextPart; % replace
    end
    
end % end iPart-loop.

% C.    TRANSFER PHASE.
% -------------------------------------------------------------------------
% only perform transfer phase for the last part.
if iPart == prep.par.nPart && iTrial > 1
    
    % We now start the transfertest. During the first screen you can abort
    % the transfertest.
    aborted         = false;
    inTransfer      = true;
    
    % run instructions.
    pavToTransfer; % replace
    
    % setup.
    tm.transferStart    = GetSecs;
    paused              = false;
    missedTrial         = [];
    missedCt            = 0;
    fprintf(logfile, '\n\nTRANSFER PHASE.\n\n');
    pavSendTrigger(prep,B,prep.par.code.startTrans);
    fprintf(logfile, 'tm.transferStart:\t\t%d   \n\n', tm.transferStart);
    Screen('FillRect',wd,backgroundCol);
    
    if ~aborted
        drawfix;
        Screen('Flip', wd);
        WaitSecs(2);
    end
    
    % loop over trials.
    for iTrial = 1:prep.par.trans.nTrial
        
        if aborted; break; end
        
        % stimulus presentation.
        wd = pavDrawStim(wd,prep,3,prep.seq.trans.stim,results,iTrial,img,[],iPart);
        tm.trans.stim(iTrial,1) = Screen(wd, 'Flip');
        pavSendTrigger(prep,B,prep.par.code.transTrial)
        
        % get response.
        [resp,t,aborted,paused] = pavCheckResponse(prep.par.trans.time.stim,true,...
            prep,B,aborted,paused,false);
        results.trans.response(iTrial,1)    = resp(1);
        tm.trans.response(iTrial,1)         = t;
        results.trans.RT(iTrial,1)          = t - tm.trans.stim(iTrial,1);
        
        % determine choice.
        down    = resp(1) == prep.par.key.down;
        up   = 2*(resp(1) == prep.par.key.up);
        choice = down + up;
        if choice == 1 || choice == 2;
            results.trans.choice(iTrial,1) = prep.seq.trans.stim(iTrial,choice);
        else
            responsecode = 'wrong';
            if resp == 0
                responsecode = 'miss';
            end
            pavErrorinstr
            missedCt = missedCt +1;
            missedTrial(missedCt,1) = iTrial;
        end
        
        % ITI.
        Screen('FillRect',wd,backgroundCol);
        drawfix;
        tm.trans.iti(iTrial,1) = Screen('Flip', wd);
        pavSendTrigger(prep,B,prep.par.code.iti);
        
        % log and save data.
        fprintf(logfile, 'Trial       %d:\t\t \n', iTrial);
        fprintf(logfile, 'stimuli shown: \t\t%s%s%s\n', prep.par.stimID{prep.seq.trans.stim(iTrial,1)}...
            ,' & ',prep.par.stimID {prep.seq.trans.stim(iTrial,2)});
        if choice == 1 || choice == 2;
            fprintf(logfile, 'choice:       \t\t%s\n',prep.par.stimID{results.trans.choice(iTrial)});
            fprintf(logfile, 'RT(ms):       \t\t%0.7g\n\n',results.trans.RT(iTrial,1)*1000);
        else
            fprintf(logfile, 'error:        \t\t%s\n\n',responsecode);
        end
        save(resultsFile,'today','results','tm','prep');
        clear responsecode
        
        % abort trial?.
        [~,~,aborted,paused] = pavCheckResponse(prep.par.trans.time.ITI-0.1,...
            false,prep,B,aborted,paused,true);
        [breaktime,tm,paused] = pavCheckPause(prep,B,aborted,paused,2,tm,wd,...
            breaktime,logfile,iPart);
        if aborted; break; end
        
        % Wait for end of trial.
        WaitSecs('Untiltime',tm.trans.iti(iTrial,1) + prep.par.trans.time.ITI);
        tm.trans.trialend(iTrial,1) = GetSecs;
        pavSendTrigger(prep,B,prep.par.code.endTrial);
        
    end % end iTrial-loop.
    
    % repeat missed trials.
    %----------------------------------------------------------------------
    iTrial = 1;
    while iTrial <= missedCt
        
        if aborted; break; end
        
        % stimulus presentation.
        wd = pavDrawStim(wd,prep,3,[],results,missedTrial(iTrial),img,[],iPart);
        tm.trans.missed.stim(iTrial,1) = Screen(wd, 'Flip');
        pavSendTrigger(prep,B,prep.par.code.transTrial);
        
        % get response.
        [resp,t,aborted,paused] = pavCheckResponse(prep.par.trans.time.stim,true,...
            prep,B,aborted,paused,false);
        results.trans.missed.response(iTrial,1) = resp(1);
        tm.trans.missed.response(iTrial,1)      = t;
        results.trans.missed.RT(iTrial,1)       = t - tm.trans.missed.stim(iTrial,1);
        
        % determine choice.
        down    = resp(1) == prep.par.key.down;
        up   = 2*(resp(1) == prep.par.key.up);
        choice = down + up;
        if choice == 1 || choice == 2;
            results.trans.missed.choice(iTrial,1) = ...
                prep.seq.trans.stim(missedTrial(iTrial),choice);
        elseif ~ismember(resp(1),[prep.par.key.abort; prep.par.key.pause])
            responsecode = 'wrong';
            if resp == 0
                responsecode = 'miss';
            end
            pavErrorinstr
            missedCt = missedCt +1;
            missedTrial(missedCt,1) = missedTrial(iTrial);
        end
        
        % ITI.
        Screen('FillRect',wd,backgroundCol);
        drawfix;
        tm.trans.missed.iti(iTrial,1) = Screen('Flip', wd);
        pavSendTrigger(prep,B,prep.par.code.iti);
        
        % log and save data.
        fprintf(logfile, 'Missed Trial       %d:\t\t \n', missedTrial(iTrial));
        fprintf(logfile, 'stimuli shown: \t\t%s%s%s\n', ...
            prep.par.stimID{prep.seq.trans.stim(missedTrial(iTrial),1)}...
            ,' & ',prep.par.stimID{prep.seq.trans.stim(missedTrial(iTrial),2)});
        if choice == 1 || choice == 2;
            fprintf(logfile, 'choice:       \t\t%s\n',prep.par.stimID{results.trans.missed.choice(iTrial)});
            fprintf(logfile, 'RT(ms):       \t\t%0.7g\n\n',results.trans.missed.RT(iTrial,1)*1000);
        else
            fprintf(logfile, 'error:        \t\t%s\n\n',responsecode);
        end
        save(resultsFile,'today','results','tm','prep');
        clear responsecode
        
        % abort trial?.
        [~,~,aborted,paused] = pavCheckResponse(prep.par.trans.time.ITI-0.1,...
            false,prep,B,aborted,paused,true);
        [breaktime,tm,paused] = pavCheckPause(prep,B,aborted,paused,2,tm,wd,...
            breaktime,logfile,iPart);
        if aborted; break; end
        
        % Wait for end of trial.
        WaitSecs('Untiltime',tm.trans.missed.iti(iTrial,1) + prep.par.trans.time.ITI);
        tm.trans.missed.trialend(iTrial,1) = GetSecs;
        pavSendTrigger(prep,B,prep.par.code.endTrial);
        
        iTrial = iTrial+1;
    end % end while iTrial <= missedCt.
    
end % end if part == 2.


% D     SAVE AND WRAP UP.
%--------------------------------------------------------------------------
Screen('FillRect',wd,backgroundCol);
Screen(wd, 'Flip');
WaitSecs(0.5);

% Thank the subject.
if strcmp(prep.par.lang, 'eng')
    text =  'Thank you for participating.';
elseif strcmp(prep.par.lang, 'ned')
    text =  'Dankjewel voor het meedoen.';
end

[wt] = Screen('TextBounds',wd,text);
xpos = round(wdw/2-wt(3)/2);
ypos = round(wdh/2-wt(4)/2);
Screen('Drawtext',wd,text,xpos,ypos);
tm.Endtext = Screen('flip', wd,[]);
pavSendTrigger(prep,B,prep.par.code.endExp);


% % % determine bonus based on overall performance;
% % results.bonus = results.tot / (prep.par.learn.prob*...
% %     (prep.par.learn.n_Go_Win_Right +prep.par.learn.n_Go_Win_Left + prep.par.learn.n_NoGo_Win)...
% %     - (1-prep.par.learn.prob)*...
% %     (prep.par.learn.n_Go_Avoid_Left + prep.par.learn.n_Go_Avoid_Right + prep.par.learn.n_NoGo_Avoid))...
% %     * prep.par.learn.maxbonus;
% %
% % % take allowed max and min of bonus into account.
% % if results.bonus < prep.par.learn.minbonus;
% %     results.bonus = prep.par.learn.minbonus;
% % elseif results.bonus > prep.par.learn.maxbonus;
% %     results.bonus = prep.par.learn.maxbonus;
% % end
% %
% % Display bonus.
% bonus2display = results.tot*100;
% if bonus2display < 0; bonus2display = 0; end
% if strcmp(prep.par.lang, 'eng')
%     text =  ['You got ' num2str(bonus2display) ' points during the game!'];
% elseif strcmp(prep.par.lang, 'ned')
%     text =  ['Je hebt ' num2str(bonus2display) ' punten behaald tijdens het spel!'];
% end
% [wt] = Screen('TextBounds',wd,text);
% xpos = round(wdw/2-wt(3)/2);
% ypos = round(wdh/2-wt(4)/2);
% Screen('Drawtext',wd,text,xpos,ypos);
% WaitSecs('UntilTime',tm.Endtext + 2);
% tm.bonustext = Screen('flip', wd,[]);

% save variables and logfile.
save(resultsFile,'today','results','tm','prep');

fprintf(logfile, 'end time:      \t\t%d   \n',tm.Endtext);
fprintf(logfile, 'task duration: \t\t%0.7g \n\n',(tm.Endtext-tm.taskStart{1}));
fprintf(logfile, 'No. of trials: \t\t%d\n',sum(prep.par.learn.nTrial));
fprintf(logfile, 'No. of reward: \t\t%d\n',sum(results.totR));
fprintf(logfile, 'No. of punish: \t\t%d\n',sum(results.totP));
fprintf(logfile, 'No. of neutral:\t\t%d\n',sum(results.totN));
% fprintf(logfile, 'bonus:         \t\t%d\n',results.bonus);
fprintf(logfile, 'average RT(ms):\t\t%0.7g   \n',1000*mean(results.learn{iPart}.RT(~isnan(results.learn{iPart}.RT))));

WaitSecs(2);
blackscreen;

% close down bitsi/logfile/audio/screen.
if prep.par.comport == 1
    fclose(B);
else
    B.close;
end
fclose(logfile);
fclose(timingfile);
WaitSecs(1);
Screen('CloseAll');
clear Screen

disp(['PAV: ' num2str(sum(results.tot)*100) ' points.']);
tmpBonus = ceil(sum(results.tot)/144*5);
if tmpBonus < 0; tmpBonus = 0; end
disp(['bonus: ' num2str(tmpBonus) ' euros.']);

clear all

end

