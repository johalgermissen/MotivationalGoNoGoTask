function t = disptxt(txt,wd,wdw,wdh,align, top, col,wait,dontblank)

nrow=length(txt);
for k=1:nrow
    [wt] = Screen('TextBounds',wd,txt{k});
    if align
        xpos = wdw*0.1;
    else %centre
        xpos = round(wdw/2-wt(3)/2);
    end
    if top
        ypos = round(wdh/12+2*(k-1)*wt(4));
    else %centre
        ypos = round(wdh/2+2*(k-1-nrow/2)*wt(4));
    end
    Screen('Drawtext',wd,txt{k},xpos,ypos,col);
end

t = GetSecs;
if dontblank; Screen('flip', wd,[],1);
else         Screen('flip', wd);
end

if wait;  WaitSecs(0.2); KbWait;end
