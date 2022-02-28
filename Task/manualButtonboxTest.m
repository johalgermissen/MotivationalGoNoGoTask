% mini script to test the button boxes.
delete(instrfind); % otherwise it won't find the port! ('COM#').
B = Bitsi('com1');
[resp,t] = B.getResponse(10,true) % 10 sec to test