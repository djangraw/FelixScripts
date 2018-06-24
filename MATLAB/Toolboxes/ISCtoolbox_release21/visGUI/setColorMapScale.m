function handles = setColorMapScale(handles)

%if handles.maxSc ~= 0
%    handles.ScaleMax1 = handles.maxSc;
%else
%    handles.ScaleMax1 = 1;
%end
%if handles.Threshold >= handles.maxSc
%   handles.Threshold = handles.maxSc/2;
%end


if handles.ScaleMax1 < handles.Threshold
    handles.ScaleMax1 = handles.Threshold;
end
if handles.ScaleMax1 > handles.maxSc
    handles.ScaleMax1 = handles.maxSc;
end
if handles.maxSc <= 0
    handles.ScaleMax1 = 0.01;
end

if handles.ScaleMin1 > handles.Threshold
    handles.ScaleMin1 = handles.Threshold;
end
if handles.ScaleMin1 < handles.minSc
    handles.ScaleMin1 = handles.minSc;
end
if handles.ScaleMin1 > handles.ScaleMax1
   handles.ScaleMax1 = handles.ScaleMin1 + 0.01;
end

%%%% Always maximum scaling range:
handles.ScaleMax1 = handles.maxSc;
handles.ScaleMin1 = handles.minSc;


