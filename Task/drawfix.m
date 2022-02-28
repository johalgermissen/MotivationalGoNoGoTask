%==========================================================================
% script to draw a fixation cross, consisting of 2 lines
%
% Hanneke den Ouden,
% start:        16-08-2009
% last changes  02-08-2012
% Jennifer Swart
% start:        30-01-2014
% last changes  30-01-2014
%==========================================================================

wdw = prep.par.disp.wdw;
wdh = prep.par.disp.wdh;
% fx  = prep.par.draw.fx;
xCenter=wdw/2;
yCenter=wdh/2;
RectFrame = [ 0 0 20 20];
RectFrameCenter = CenterRectOnPointd(RectFrame, xCenter, yCenter);
RectFill = [ 0 0 5 5];
RectFillCenter = CenterRectOnPointd(RectFill, xCenter, yCenter);
% Screen('DrawLine',wd,prep.par.col.white,wdw/2, wdh/2-fx, wdw/2, wdh/2+fx,2);
% Screen('DrawLine',wd,prep.par.col.white,wdw/2-fx, wdh/2, wdw/2+fx, wdh/2,2);

Screen('FrameOval', wd, prep.par.col.white, RectFrameCenter, 2);
Screen('FillOval', wd, prep.par.col.white, RectFillCenter);
