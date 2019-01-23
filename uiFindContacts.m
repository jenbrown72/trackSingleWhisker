function contacts = uiFindContacts(aviData,trial,varargin)
% Creates a GUI that allows the user to manually click through frames of .avi
% files loaded into the aviData struct and select frames in which contact
% is made. Returns a cell containing arrays of contact points for each
% video

%% Parse and load input arguments
contacts = {};

index = 1;
while index<=length(varargin)
    try
        switch varargin{index}
            case {'Contacts','contacts'}
                contacts = varargin{index+1};
                index = index+2;
            otherwise
                warning('Argument ''%s'' not recognized',varargin{index});
                index = index + 1;
        end
    catch
        warning('Argument %d not recognized',index);
        index = index + 1;
    end
end

if isempty(contacts)
    contacts = cell(trial,1);
end

if isempty(aviData)
    aviData.images = ones(512,640);
    aviData.frames = 1;
elseif ischar(aviData) || iscellstr(aviData)
    aviData = readAvi(aviData);
end

aviData.images = squeeze(aviData.images);
numImages = length(aviData.frames);

%% Create and display GUI
currFrame = aviData.frames(1);
findex = 1;

gd.fig = figure(...
    'Name',         sprintf('%s trial %d',aviData.fid,trial),...
    'NumberTitle',  'off',...
    'KeyPressFcn',  @(hObject,eventdata)KeyPress(hObject,eventdata,guidata(hObject)));
gd.axes = axes(...
    'Units',        'normalized',...    
    'Position',     [0,0,1,.9]);
gd.frameNum = uicontrol(...
    'Style',        'text',...
    'Position',     [10,30,200,20],...
    'FontSize',     12,...
    'HorizontalAlignment', 'left',...
    'String',       sprintf('Frame %d (%d of %d)',currFrame,findex,numImages));
gd.frameMode = uicontrol(...
    'Style',        'text',...
    'Position',     [10,10,200,20],...
    'FontSize',     12,...
    'ForegroundColor', 'red',...
    'HorizontalAlignment', 'left',...
    'String',       '');
guidata(gd.fig,gd);

DisplayFrame(gd);
waitfor(gd.fig);

    function ChangeFrame(gd)
        UpdateText(currFrame,findex,gd);
        DisplayFrame(gd);
    end

    function DisplayFrame(gd)
        
        % Display image
        axes(gd.axes)
        if size(aviData.images,1)>1
            if ndims(aviData.images) == 3
                imagesc(squeeze(aviData.images(:,:,findex)));
            elseif ndims(aviData.images) == 4
                imagesc(squeeze(aviData.images(:,:,:,findex)));
            end
        else
            imagesc(aviData.images);
        end
        colormap gray;
        axis equal off;
        
    end
        
    function KeyPress(hObject,eventdata,gd)
        
        if ismember(eventdata.Key,{'leftarrow','rightarrow','a','d'})
            switch eventdata.Key
                case {'rightarrow','d'}
                    if findex == numImages
                        findex = 1;
                    else
                        findex = findex+1;
                    end

                case {'leftarrow','a'}
                    if findex == 1
                        findex = numImages;
                    else
                        findex = findex-1;
                    end
            end
            currFrame = aviData.frames(findex);
            ChangeFrame(gd);
            
        elseif isequal(eventdata.Key,'space')
            AddContact(currFrame,findex,gd);
            
        elseif isequal(eventdata.Key,'backspace')
            RemoveContact(currFrame,findex,gd);
        end
    end

    function AddContact(frameNumber,index,gd)
        
        contacts{trial,1} = sort([contacts{trial,1} frameNumber]);
        
        disp(join(string(contacts{trial,1}),', '));
        UpdateText(frameNumber,index,gd);
        DisplayFrame(gd);
    end

    function RemoveContact(frameNumber,index,gd)
        
        for i = 1:length(contacts{trial,1})
            if contacts{trial,1}(i) == frameNumber
                if i == 1
                    contacts{trial,1} = contacts{trial,1}(2:end);
                else
                    contacts{trial,1} = contacts{trial,1}([1:i-1,i+1:end]);
                end
                
                if isempty(contacts{trial,1})
                    disp('empty');
                else
                    disp(join(string(contacts{trial,1}),', '));
                end
                
                UpdateText(frameNumber,index,gd);
                DisplayFrame(gd);
                
                break
            elseif contacts{trial,1}(i) > frameNumber
                break
            end
        end
    end

    function UpdateText(frameNumber,index,gd)
        gd.frameNum.String = sprintf('Frame %d (%d of %d)',frameNumber,index,numImages);
        
        contactCount = sum(contacts{trial,1}==frameNumber);
        if contactCount == 0
            gd.frameMode.String = '';
        elseif contactCount == 1
            gd.frameMode.String = 'SELECTED';
        else
            gd.frameMode.String = sprintf('SELECTED x%d',contactCount);
        end
    end
    
end