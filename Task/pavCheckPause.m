function [breaktime,tm,paused] = pavCheckPause(prep,B,aborted,paused,...
    pavPhase,tm,wd,breaktime,logfile,iPart)

% check if there has been pressed to abort:
    if aborted || paused
        blackscreen;
        if aborted
            if pavPhase == 1
                tm.learn{iPart}.abort  = [tm.learn{iPart}.abort; GetSecs];
            else
                tm.trans.abort  = [tm.trans.abort; GetSecs];
            end
            pavSendTrigger(prep,B,prep.par.code.abort);
            if strcmp(prep.par.lang, 'ned')
                abd = 'Je hebt de taak gestopt.';
            elseif strcmp(prep.par.lang, 'eng')
                abd = 'You have aborted the task.';
            end
            if pavPhase == 1
                fprintf(logfile,'\ntAborted\t\t%0.7g \n\n',tm.learn{iPart}.abort - tm.taskStart{iPart});
            else
                fprintf(logfile,'\ntAborted\t\t%0.7g \n\n',tm.trans.abort - tm.taskStart{iPart});
            end
        else
            if pavPhase == 1
                tm.learn{iPart}.pause = [tm.learn{iPart}.pause; GetSecs];
            else
                tm.trans.pause = [tm.trans.pause; GetSecs];
            end
            pavSendTrigger(prep,B,prep.par.code.pause);
            if strcmp(prep.par.lang, 'ned')
                abd = 'Je hebt de taak gepauzeerd.';
            elseif strcmp(prep.par.lang, 'eng')
                abd = 'You have paused the task.';
            end
        end
        [wt] = Screen('TextBounds',wd,abd);
        xpos = round(prep.par.disp.wdw/2-wt(3)/2);
        ypos = round(prep.par.disp.wdh/2-wt(4)/2);
        Screen('Drawtext',wd,abd,xpos,ypos,prep.par.col.white);
        Screen('flip', wd,[]);
        WaitSecs(2);
    end
    
    while paused
        resp = KeyboardResponse(inf,true);
        if resp == prep.par.key.resume
            blackscreen;
            WaitSecs(1);
            clear resp
            if pavPhase == 1
                breaktime = breaktime + GetSecs - tm.learn{iPart}.pause(end);
            else
                breaktime = breaktime + GetSecs - tm.trans.pause(end);
            end
            pavSendTrigger(prep,B,prep.par.code.resume);
            paused = false;
        end
    end
    
end
