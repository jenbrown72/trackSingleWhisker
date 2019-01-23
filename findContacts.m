% Main code for reading each Avi to an array and then displaying frames
% stored in the array in the GUI

% If 'files' variable (directory of selected folder) not in workspace, 
% opens a dialog box to select a folder
if ~exist('files','var')
    folder = uigetdir('../WhiskerData/','Select folder');
    files = dir(fullfile(folder,'*.avi'));
end

% If array of contacts not in workspace, creates an empty array
if ~exist('contacts','var')
    contacts = cell(length(files),1);
end

% Create cell with first n indices of each trial type
% count = zeros(2,8);
% inds = cell(1,16);
% for i = 1:length(trialType)
%     if trialType(i) ~= 5
%         if lick_trial(i) == 1
%             row = 1;
%         else
%             row = 2;
%         end
%         
%         col = stimsequence(i);
%         if row == 1
%             j = col;
%         else
%             j = col + 8;
%         end
%         
%         count(row,col) = count(row,col) + 1;
%         if length(inds{1,j}) < 10
%             inds{1,j} = [inds{1,j} i];
%         end
%     end
% end
% inds = sort(cell2mat(inds));

% Loop through 'files'; read and open GUI for each Avi, one at a time
dataSubset = angle4;
% dataSubset = angleIDS{1};
for ii = 1:length(dataSubset)
%     i = ii;
 i = dataSubset(ii);
    if isempty(contacts{i,1})
        fprintf('\nReading trial %d to array...\n',i);
        path = fullfile(files(i).folder,files(i).name);
        avi = readAvi(path);
        contacts = uiFindContacts(avi,i,'contacts',contacts);
        % Allows you to exit loop by not selecting a contact time
%         if isempty(contacts{i,1})
%             break
%         end
    end
end
