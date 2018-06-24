function ISCtool(varargin)

switch length(varargin)
    case 0
        fMRI_GUI_export;
    case 1
        fMRI_GUI_export(varargin{1});
    otherwise
        error('Too many inputs!')
        return
end