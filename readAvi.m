function aviData = readAvi(path,varargin)
% Loads frames of a single .avi file

%% Initialize parameters
start = 400;
stop = 1000;

index = 1;
while index<=length(varargin)
    try
        switch varargin{index}
            case {'Start','start'} % first frame to be loaded
                if varargin{index+1} < 1
                    warning('Argument %s too small. Start set to default')
                elseif class(varargin{index+1}) ~= 'double'
                    warning('Argument %s must be integer value. Start set to default')
                else
                    start = varargin{index+1};
                end
                index = index + 2;
            case {'Stop','stop'} % last frame to be loaded
                if class(varargin{index+1}) ~= 'double'
                    warning('Argument %s must be integer value. Start set to default')
                else
                    stop = varargin{index+1};
                end
                index = index + 2;
            otherwise
                warning('Argument ''%s'' not recognized',varargin{index});
                index = index + 1;
        end
    catch
        warning('Argument %d not recognized',index);
        index = index + 1;
    end
end

if (length(path) < 5 || ~strcmp(path(end-3:end),'.avi')) || exist(path) ~= 2
    [aviFiles,p] = uigetfile('*.avi','Select .avi file','../WhiskerData/');
    
    if isnumeric(aviFiles)
        aviData.images = []; return
    end
    
    path = fullfile(p,aviFiles);
end

pathSplit = split(path,'/');
pathSplit = pathSplit{end};
pathSplit = split(pathSplit,'\');
aviData.fid = pathSplit{end}(1:7);

avi = VideoReader(path);

%% Determine frames
if stop > avi.NumberOfFrames
    stop = avi.NumberOfFrames;
end

if start > stop
    start = 1;
end

aviData.frames = start:stop;

numFrames = numel(aviData.frames);

%% Read file
avi = VideoReader(path); % must reload .avi because NumberOfFrames was called
aviData.images = read(avi,[start,stop]);

end