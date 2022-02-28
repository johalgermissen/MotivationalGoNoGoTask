%==========================================================================
% Script to unclutter the main runscript. Sets up all variables needed to
% run the task
%
% Hanneke den Ouden,
% start:        16-08-2009
% last changes  02-08-2012
%
% Jennifer Swart,
% start:        03-02-2014
% last changes  30-04-2015
%
% Jessica M‰‰tt‰,
% start:        20-04-2015
% last changes  29-04-2015
%==========================================================================

% A. General setup.
%--------------------------------------------------------------------------
today       = date;


% B. Initialize logfile and storage.
%--------------------------------------------------------------------------

results     = {};
tm          = {};

% allocate storage.

nt                        = prep.par.pract.nTrial;
nStimPract                = prep.par.pract.nStim;
results.pract.RT          = NaN(nStimPract,nt);
results.pract.acc         = NaN(nStimPract,nt);
results.pract.response    = NaN(nStimPract,nt);
results.pract.outcome     = NaN(nStimPract,nt);
results.pract.go          = NaN(nStimPract,nt);
tm.pract.stim             = NaN(nStimPract,nt);
tm.pract.response         = NaN(nStimPract,nt);
tm.pract.sfi              = NaN(nStimPract,nt);
tm.pract.outcome          = NaN(nStimPract,nt);
tm.pract.iti              = NaN(nStimPract,nt);
tm.pract.trialend         = NaN(nStimPract,nt);
tm.pract.pause            = [];
tm.pract.resume           = [];
tm.pract.warning          = [];
tm.pract.abort            = [];
clear nStimPract

nPart                     = prep.par.nPart;
for iPart = 1:nPart
    nt                        = prep.par.learn.nTrial(iPart);
    results.learn{iPart}.RT          = NaN(nt,1);
    results.learn{iPart}.acc         = NaN(nt,1);
    results.learn{iPart}.response    = NaN(nt,1);
    results.learn{iPart}.outcome     = NaN(nt,1);
    results.learn{iPart}.go          = NaN(nt,1);
    tm.learn{iPart}.stim             = NaN(nt,1);
    tm.learn{iPart}.response         = NaN(nt,1);
    tm.learn{iPart}.sfi              = NaN(nt,1);
    tm.learn{iPart}.outcome          = NaN(nt,1);
    tm.learn{iPart}.iti              = NaN(nt,1);
    tm.learn{iPart}.trialend         = NaN(nt,1);
    tm.learn{iPart}.pause            = [];
    tm.learn{iPart}.resume           = [];
    tm.learn{iPart}.warning          = [];
    tm.learn{iPart}.abort            = [];
    tm.learn{iPart}.break            = [];
end

nt                        = prep.par.trans.nTrial;
results.trans.RT          = NaN(nt,1);
results.trans.response    = NaN(nt,1);
results.trans.choice      = NaN(nt,1);
tm.trans.stim             = NaN(nt,1);
tm.trans.response         = NaN(nt,1);
tm.trans.iti              = NaN(nt,1);
tm.trans.trialend         = NaN(nt,1);
tm.trans.pause            = [];
tm.trans.resume           = [];
tm.trans.warning          = [];
tm.trans.abort            = [];

% initialise logfile and put some info at the start.
logfile         = fopen(logFileName,'w+');
fprintf(logfile, 'Pavlovian task \n\n');
fprintf(logfile, 'Date:      \t\t\t%s\n',today);
fprintf(logfile, 'Subject ID:\t\t%d\n',sID);
fprintf(logfile, 'LEARNING PHASE.  \n\n');
timingfile      = fopen(timingFileName,'w+');
prep.timingfile = timingfile;
fprintf(timingfile, 'Value\tTime\n');

% initialise serial port.
if prep.par.comport == 1
   B = serial(prep.par.comB);
   fopen(B);
   % to create a serial port, the software is supported on the 2011 version,
% but not 2008. 
end


% C. Prepare pictures and sounds.
%--------------------------------------------------------------------------
% Load all the image files.

% feeback images.
tmp.outcome{1}    = importdata(fullfile(prep.dir.imgs,'rew.jpg'));
tmp.outcome{2}    = importdata(fullfile(prep.dir.imgs,'pun.jpg'));
tmp.outcome{3}    = importdata(fullfile(prep.dir.imgs,'no_rew.jpg'));
tmp.outcome{4}    = importdata(fullfile(prep.dir.imgs,'no_pun.jpg'));

% instructions.
instr = dir(fullfile(prep.dir.instructions,'Slide*.jpg'));
instr = {instr.name};
for iPage = 1:length(instr)
    tmp.instructions{iPage}    = importdata(fullfile(prep.dir.instructions,instr{iPage}));
end

% short instructions.
instrShort = dir(fullfile(prep.dir.ShortInstructions,'Slide*.jpg'));
instrShort = {instrShort.name};
for iShort = 1:length(instrShort) 
	tmp.ShortInstructions{iShort} = importdata(fullfile(prep.dir.ShortInstructions,instrShort{iShort}));
end 

% instructions next part.
instrNextPart = dir(fullfile(prep.dir.nextPart,'Slide*.jpg'));
instrNextPart = {instrNextPart.name};
for iNext = 1:length(instrNextPart)
    tmp.nextPart{iNext}    = importdata(fullfile(prep.dir.nextPart,instrNextPart{iNext}));
end

% instructions transfer.
instrToTransfer = dir(fullfile(prep.dir.toTransfer,'Slide*.jpg'));
instrToTransfer = {instrToTransfer.name};
for iTrans = 1:length(instrToTransfer)
    tmp.toTransfer{iTrans}    = importdata(fullfile(prep.dir.toTransfer,instrToTransfer{iTrans}));
end

% cue images.
for iPart = 1:nPart    
    stim    = prep.par.stimColor{iPart};
    for iStim = 1:length(stim)
        tmp.stimulus{iPart,iStim}    = importdata(fullfile(prep.dir.imgs,sprintf('%s.jpg',stim{iStim})));
    end
end % end iPart-loop.

% practice cue images.
for iPract = 1:prep.par.pract.nStim
    tmp.examp{iPract}    = importdata(fullfile(prep.dir.imgs,sprintf('examp%d.jpg',iPract))); 
end



% D. Setup screen and prepare textures.
%--------------------------------------------------------------------------
if debug == 1 % Use when in debugging mode
    Screen('Preference', 'Verbosity', 4)
    % Uncomment to test for smaller screen
    %  wd          = Screen('OpenWindow', 0, [0 0 0], [0 0 512 384]);
    % Uncomment to test for MR screen res.
    wd          = Screen('OpenWindow', 0, [0 0 0], [0 0 1024 768]);
else % % Use when in run mode
    Screen('Preference', 'Verbosity', 0)
    if skipMRI == 1
        wd = Screen('OpenWindow', 0, [0 0 0], []);
    else
        wd = Screen('OpenWindow', 0, [0 0 0], []); % MRI pc screen 1, Dummyscanner pc screen 0
    end
    HideCursor;
end

% get the size of the screen.
[wdw, wdh]      = Screen('WindowSize', wd);
backgroundCol   = prep.par.col.background;
black           = BlackIndex(wd);
white           = WhiteIndex(wd);
Screen(wd,'TextStyle',1); % Bold
Screen(wd,'TextFont',prep.par.draw.font);
Screen(wd,'TextSize',prep.par.draw.txtsize);
Screen(wd,'TextColor',prep.par.col.white);
HideCursor;

% make the textures for the feedback.
% feedback images. 
for j = 1:length(tmp.outcome)
    img.outcome{j}     = Screen('MakeTexture',wd,tmp.outcome{j});
end

% instruction images. 
for j = 1:length(tmp.instructions)
    img.instructions{j}     = Screen('MakeTexture',wd,tmp.instructions{j});
end

% short instruction
for j = 1:length(tmp.ShortInstructions)
	img.ShortInstructions{j} = Screen('MakeTexture',wd,tmp.ShortInstructions{j});
end

% instruction next part. 
for j = 1:length(tmp.nextPart)
    img.nextPart{j}     = Screen('MakeTexture',wd,tmp.nextPart{j});
end

% instruction to transfer. 
for j = 1:length(tmp.toTransfer)
    img.toTransfer{j}     = Screen('MakeTexture',wd,tmp.toTransfer{j});
end

% cue images.
for iPart = 1:nPart
    for j= 1:length(tmp.stimulus)
        img.stim{iPart,j}      = Screen('MakeTexture',wd,tmp.stimulus{iPart,j});
    end
end

% transfer images.
img.trans = img.stim;

% practice cue images.
for j= 1:length(tmp.examp)
    img.examp{j}      = Screen('MakeTexture',wd,tmp.examp{j});
end
clear tmp

% present black screen for 1 sec before starting.
Screen('FillRect',wd,backgroundCol);
Screen('Flip', wd);
WaitSecs(1);

