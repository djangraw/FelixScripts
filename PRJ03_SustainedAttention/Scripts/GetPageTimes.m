function [tPageStart,tPageEnd, pageNum] = GetPageTimes(events,pageTag)

% [tPageStart,tPageEnd, pageNum] = GetPageTimes(events,pageTag)
%
% INPUTS:
% - events is a struct with fields display.time and display.name, typically
% imported using ImportReadingImageData.m.
% - pageTag is a string indicating the text that precedes a page number in
% a display.name. [default = 'Page']
% OUTPUTS:
% - tPageStart and tPageEnd are n-element vectors indicating the EyeLink
% times at which each page display started and ended.
% - pageNum is an n-element vector of the number of each page.
%
% Created 5/7/15 by DJ.
% Updated 9/22/15 by DJ - added custom pageTag input.
% Updated 1/15/16 by DJ - allow last event to be a page event
% Updated 8/19/16 by DJ - switched from message events to display events

% Extract info
if ~exist('pageTag','var') || isempty(pageTag)
    pageTag = 'Page';
end
iPageEvents = find(strncmp(pageTag,events.display.name,length(pageTag)));

% get page times & numbers
nPages = numel(iPageEvents);
tPageStart = events.display.time(iPageEvents);
if iPageEvents(end)==numel(events.display.time)
    tPageEnd = [events.display.time(iPageEvents(1:end-1)+1); inf];
else
    tPageEnd = events.display.time(iPageEvents+1);
end

% get page numbers
pageNum = zeros(1,nPages);
for i=1:nPages
    pageNum(i) = str2double(events.display.name{iPageEvents(i)}(length(pageTag)+1:end));
end