
function pavParams(sID,lang,prepFile,skipMRI)
%==========================================================================
% Set up general parameter definitions for the action x motivation Go-NoGo
% task. Parameters are adapted to the EEG study 2015.
% This routine stores all parameters in the structure 'prep' and saves prep
% in a file named 'EEGpav_[subjectID]_prep.mat'.
%
% NB: all timing parameters are given in seconds.
%
% Hanneke den Ouden, 
% original:     16-08-2009.
% last changes: 13-04-2014
%
% Jennifer Swart,
% start:        30-01-2014.
% last:         23-04-2014.
% 
% Jessica M‰‰tt‰,
% start:        15-04-2015.
% end:          29-04-2015.
%==========================================================================
KbName('UnifyKeyNames');

% PARAMETERS THAT NEED TO BE MODIFIED.
%==========================================================================
prep.par.keymode            = 2; % 1 = buttonbox, 2 = keyboard.
prep.par.instr.keymode      = 2; % 1 = buttonbox, 2 = keyboard.
prep.par.comport            = 2; % 1 = serial, 2 = parallel.
%==========================================================================
if skipMRI == 1
    prep.par.comB                = 'com1';
    prep.par.comMRI              = (''); 
elseif skipMRI == 0 % run MRI
    prep.par.comB                = 'com2';
    prep.par.comMRI              = 'com3';
    % add term for received trigger
    prep.par.trigger.MRI = 97;
    % add timing variable that indicates how long to wait after you
    % received a trigger (in seconds)
    prep.par.learn.time.MRI = 10;
    prep.par.keymode = 1;
    prep.par.comport = 2;
end

% update comport for incase there was an invalid combination.
if prep.par.keymode == 1
    prep.par.comport = 2;
end

% Bitsi setup.
if prep.par.keymode == 2 % keyboard.
    prep.par.comB = ('');
end

% save inputs
prep.par.sID        = sID;
prep.par.today      = date;
if lang == 2
    prep.par.lang               = 'ned'; 
elseif lang == 1
    prep.par.lang               = 'eng'; 
end

% A.    Stimulus, sequence and timing parameters.
% -------------------------------------------------------------------------
nStim                   = 8;
nResp                   = 3;
prep.par.nStim          = nStim;
prep.par.nResp          = nResp;
prep.par.stimID         = {'Go-to-win-left','Go-to-win-right','Go-to-avoid-left',...
    'Go-to-avoid-right','NoGo-to-win','NoGo-to-win','NoGo-to-avoid','NoGo-to-avoid'};
prep.par.rewStim        = [1 2 5 6];
prep.par.punStim        = [3 4 7 8];
prep.par.nPart          = 2;

prep.dir.imgs           = fullfile(pwd,'pics','stimuli');
prep.dir.instructions   = fullfile(pwd,'pics','instructions');
prep.dir.ShortInstructions = fullfile(pwd, 'pics','ShortInstructions');
prep.dir.nextPart       = fullfile(pwd,'pics','nextPart'); % to next part
prep.dir.toTransfer     = fullfile(pwd,'pics','toTransfer');% to transfer

stimLabelA = cell(1,nStim); stimLabelB = cell(1,nStim);
for iStim = 1:nStim
    stimLabelA{iStim}        = sprintf('A%d',iStim);
    stimLabelB{iStim}        = sprintf('B%d',iStim);
end
prep.par.stimColor                  = cell(prep.par.nPart,1);
prep.par.stimColor{mod(sID,2)+1}    = mix(stimLabelA)';
prep.par.stimColor{2-mod(sID,2)}    = mix(stimLabelB)';
clear stimLabelA stimLabelB

% PRACTICE BLOCK.
%--------------------------------------------------------------------------
prep.par.pract.nStim          = 3;
prep.par.pract.SFI            = 0.7;
prep.par.pract.nRep           = 5;
prep.par.pract.nTrial         = prep.par.pract.nStim .* prep.par.pract.nRep;
prep.par.pract.page           = {7,8,9};
prep.par.pract.time.feedback  = 1.5;      % feedback duration.
prep.par.pract.time.ITI       = 1;

% LEARNING PHASE.
%--------------------------------------------------------------------------
% if nTrial is a multiplication of 40, the probability level of valid 
% feedback can always be exactly 70%.
prep.par.learn.prob            = 0.8;
nTrial                         = [320;320]; % task twice. 
prep.par.learn.nTrial          = nTrial;
prep.par.learn.n_Go_Win_Left   = nTrial/nStim;
prep.par.learn.n_Go_Win_Right  = nTrial/nStim;
prep.par.learn.n_Go_Avoid_Left = nTrial/nStim;
prep.par.learn.n_Go_Avoid_Right= nTrial/nStim;
prep.par.learn.n_NoGo_Win      = nTrial/nStim*2;
prep.par.learn.n_NoGo_Avoid    = nTrial/nStim*2;
prep.par.learn.outcomeID       = {'loss','neutral','reward'};
prep.par.learn.maxbonus        = 5;
prep.par.learn.minbonus        = 0;
prep.par.learn.break           = [0:110:max(nTrial) max(nTrial)];

% Timing alternative 1
% prep.par.learn.time.stim      = 1.3;        % stimulus duration.
% prep.par.learn.time.SFI       = 0.5;        % stimulus-feedback interval.
% prep.par.learn.time.feedback  = 1;          % feedback duration.
% prep.par.learn.time.ITI       = [1.25; 1.50; 1.75; 2]; % inter-trial interval.

% % Timing alternative 2
% prep.par.learn.time.stim      = 1.3;        % stimulus duration.
% prep.par.learn.time.SFI       = 0.5;        % stimulus-feedback interval.
% prep.par.learn.time.feedback  = 2;          % feedback duration.
% prep.par.learn.time.ITI       = [1.25; 1.50; 1.75; 2]; % inter-trial interval.

% % Timing alternative 3
% prep.par.learn.time.stim      = 1.3;        % stimulus duration.
% prep.par.learn.time.SFI       = 0.7;        % stimulus-feedback interval.
% prep.par.learn.time.feedback  = 1;          % feedback duration.
% prep.par.learn.time.ITI       = [1; 1.25; 1.5; 1.75]; % inter-trial interval.

% Timing alternative 4 - MRI
% prep.par.learn.time.stim      = 1.3;          % stimulus duration.
% prep.par.learn.time.SFI       = 1 : 0.1: 2.7; % stimulus-feedback interval.
% prep.par.learn.time.feedback  = 1;            % feedback duration.
% prep.par.learn.time.ITI       = [1; 1.25; 1.5; 1.75]; % inter-trial interval.
% total time trial = max 6,75 s

% Timing alternative 5 - MRI long - feedback 0.75 s
prep.par.learn.time.stim      = 1.3;            % stimulus duration.
prep.par.learn.time.SFI       = 1.4 : 0.1: 2.6; % stimulus-feedback interval (average 2 seconds)
prep.par.learn.time.feedback  = 0.75;           % feedback duration.
prep.par.learn.time.ITI       = [1.25; 1.5; 1.75; 2.0]; % inter-trial interval.

% % Timing alternative 6 - MRI long - feedback 0.5 s
% prep.par.learn.time.stim        = 1.3;            % stimulus duration.
% prep.par.learn.time.SFI         = 1.4 : 0.1: 2.6; % stimulus-feedback interval (average 2 seconds)
% prep.par.learn.time.feedback    = 0.5;            % feedback duration.
% prep.par.learn.time.ITI         = [1.5; 1.75; 2.0; 2.25]; % inter-trial interval.

% TRANSFER PHASE.
%--------------------------------------------------------------------------
nTrial                        = 48;
prep.par.trans.nTrial         = nTrial;
prep.par.trans.n_Go_Win       = nTrial/2;
prep.par.trans.n_Go_Avoid     = nTrial/2;
prep.par.trans.n_NoGo_Win     = nTrial/2;
prep.par.trans.n_NoGo_Avoid   = nTrial/2;

% Timing.
prep.par.trans.time.stim      = 3;
prep.par.trans.time.ITI       = 0.5;


% B.    Display & keyboard definitions.
%--------------------------------------------------------------------------

prep.par.disp.screenNum       = 0; % select monitor.
prep.par.disp.clrdepth        = 32; % colour settings monitor.

% keys dependent on keymode (for participant)
if prep.par.keymode == 1 % buttonbox.
    prep.par.key.left   = 101; % index finger left button box.
    prep.par.key.right  = 97; % index finger right button box. Left button of right button box
    prep.par.key.up     = 97;% index finger right button box.
    prep.par.key.down   = 98; % middle finger right button box.
elseif prep.par.keymode == 2 % keyboard.
%     left                = input('press "Left": ','s');
%     right               = input('press "Right": ','s');
%     prep.par.key.left   = KbName(left);
%     prep.par.key.right  = KbName(right);
    prep.par.key.left   = KbName('LeftArrow');
    prep.par.key.right  = KbName('RightArrow');
    prep.par.key.up     = KbName('UpArrow');
    prep.par.key.down   = KbName('DownArrow');
end

if prep.par.instr.keymode == 1 % buttonbox.
    prep.par.key.instr.left   = 101; % index finger left button box.
    prep.par.key.instr.right  = 97; % index finger right button box. Left button of right button box
    prep.par.key.instr.up     = 97;% index finger right button box.
    prep.par.key.instr.down   = 98; % middle finger right button box.
elseif prep.par.instr.keymode == 2 % keyboard.
    prep.par.key.instr.left   = KbName('LeftArrow');
    prep.par.key.instr.right  = KbName('RightArrow');
    prep.par.key.instr.up     = KbName('UpArrow');
    prep.par.key.instr.down   = KbName('DownArrow');
end

% keys always set (for researcher).
prep.par.key.abort      = KbName('ESCAPE'); % esc button.
prep.par.key.enter      = KbName('Return'); % enter.
prep.par.key.pause      = KbName('p');
prep.par.key.resume     = KbName('r');

% C.    Drawing parameters for location and size of the pictures and text.
%--------------------------------------------------------------------------
tmp                     = get(0, 'ScreenSize');
wdw                     = tmp(3);
wdh                     = tmp(4);
prep.par.disp.wdw       = wdw;
prep.par.disp.wdh       = wdh;
clear tmp

% Colors of the stimuli and the square frame.
prep.par.col.grey        = [200 200 200];
prep.par.col.white       = [251 251 251];    %(slightly off) white.
prep.par.col.background  = [166 166 166];

% Font.
prep.par.draw.font      = 'Helvetica';
prep.par.draw.txtsize   = round(0.02*wdh);
% prep.par.draw.fx      = 7; % radius of the fixation cross
prep.par.draw.rStim     = round(wdh/12); 
prep.par.draw.rtransfer = prep.par.draw.rStim;
prep.par.draw.rfeedback = round(wdh/9);
prep.par.draw.rarrow    = round(wdh/15);
prep.par.draw.top       = wdh/12;
prep.par.draw.wdFrame   = 5; % frame width.
% prep.par.draw.txtsize   = 21;
% prep.par.draw.rStim     = 88; 
% prep.par.draw.rtransfer = 88;
% prep.par.draw.rfeedback    = 105;
% prep.par.draw.rarrow    = 70;
% prep.par.draw.top       = 88;

% drawing locations.
loc{1}                  = [wdw/2.5, wdh/2]; % centre of pie 1: centre left
loc{2}                  = [wdw - loc{1}(1), wdh/2]; % centre of pie 2: centre right
loc{3}                  = [wdw/2, wdh/3]; % centre of pie 1: centre left
loc{4}                  = [wdw/2 , wdh-loc{3}(2)]; % centre of pie 2: centre right
locarrow{1}             = [wdw/3, wdh/2]; % centre of pie 1: centre left
locarrow{2}             = [wdw - locarrow{1}(1), wdh/2]; % centre of pie 2: centre right
loc_centre              = [wdw/2, wdh/2]; % centre of screen
locinstr                = [wdw/2, (wdh/3)*2];
prep.par.draw.loc_centre= loc_centre;     %centre of stimulus and target
prep.par.draw.loc       = loc;
prep.par.draw.loc_instr = locinstr;

% setting the drawingfields of the stimuli
rectstim = [(loc_centre(1)-prep.par.draw.rStim) (loc_centre(2)-prep.par.draw.rStim)...
    (loc_centre(1)+prep.par.draw.rStim) (loc_centre(2)+prep.par.draw.rStim)];
rectinstr.midd = [(locinstr(1)-prep.par.draw.rStim) (locinstr(2)-prep.par.draw.rStim)...
    (locinstr(1)+prep.par.draw.rStim) (locinstr(2)+prep.par.draw.rStim)];
rectinstr.left = [(loc{1}(1)-prep.par.draw.rtransfer) (locinstr(2)-prep.par.draw.rtransfer)...
    (loc{1}(1)+prep.par.draw.rtransfer) (locinstr(2)+prep.par.draw.rtransfer)];
rectinstr.right = [(loc{2}(1)-prep.par.draw.rtransfer) (locinstr(2)-prep.par.draw.rtransfer)...
    (loc{2}(1)+prep.par.draw.rtransfer) (locinstr(2)+prep.par.draw.rtransfer)];
recttransfer = cell(2,1);
for z= 1:2 % location transfer phase.
    recttransfer{z} = [(loc{z+2}(1)-prep.par.draw.rtransfer) (loc{z+2}(2)-prep.par.draw.rtransfer)...
        (loc{z+2}(1)+prep.par.draw.rtransfer) (loc{z+2}(2)+prep.par.draw.rtransfer)];
end
rectfeedback = [(loc_centre(1)-prep.par.draw.rfeedback) (loc_centre(2)-prep.par.draw.rfeedback)...
        (loc_centre(1)+prep.par.draw.rfeedback) (loc_centre(2)+prep.par.draw.rfeedback)];
rectarrow.left = [(locarrow{1}(1)-prep.par.draw.rarrow) (wdh*.9-prep.par.draw.rarrow)...
    (locarrow{1}(1)+prep.par.draw.rarrow) (wdh*.9+prep.par.draw.rarrow)];
rectarrow.right = [(locarrow{2}(1)-prep.par.draw.rarrow) (wdh*.9-prep.par.draw.rarrow)...
    (locarrow{2}(1)+prep.par.draw.rarrow) (wdh*.9+prep.par.draw.rarrow)];

prep.par.draw.rect.stim         = rectstim;    %size-indication of stimulus
prep.par.draw.rect.transfer     = recttransfer;    %size-indication of transfer
prep.par.draw.rect.feedback     = rectfeedback;   %size-indication of feedback
prep.par.draw.rect.instr.midd   = rectinstr.midd;
prep.par.draw.rect.instr.left   = rectinstr.left;
prep.par.draw.rect.instr.right  = rectinstr.right;
prep.par.draw.rect.instr.arrow1 = rectarrow.right; 
prep.par.draw.rect.instr.arrow2 = rectarrow.left;

% D. event codes.
%--------------------------------------------------------------------------
prep.par.code.startInstr        = 101;
prep.par.code.startExp          = 102;
prep.par.code.endExp            = 103;
prep.par.code.startTrans        = 104;
prep.par.code.break             = 105;
prep.par.code.pause             = 106;
prep.par.code.resume            = 107;
prep.par.code.abort             = 108;
prep.par.code.startTrial        = [111;112;113;114;115;116;117;118];
prep.par.code.outcome           = [120;121;122;123];
prep.par.code.sfi               = 125;
prep.par.code.iti               = 126;
prep.par.code.practTrial        = [131;132];
prep.par.code.practOutcome      = [136;137];
prep.par.code.transTrial        = 150;
prep.par.code.endTrial          = 141;
% left = 37, right = 39, space = 32, return = 13, p = 80, r = 82, esc = 27.

% E. save prep.
%--------------------------------------------------------------------------
save(prepFile,'prep');

return
