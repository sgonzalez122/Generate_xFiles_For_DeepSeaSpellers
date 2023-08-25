% File: Generate_xFiles_For_DeepSeaSpellers.m
% Programer: Stephen A. Gonzalez
% Date Created: 8/23/2023
% Purpose: 
%   Creates xFiles used for creating tasks in xDiva
%   xFiloes are created using either .png images or Matlab bitmaps (.bmp)
%
% --------------------------------------------------------------------------- 
% Required files: 
%   Folder containing .png  image files               ("stim_images" folder)
%   Folder containing .bmp  image files               ("stim_images_woreds")
%   Folder containing .xslx Stimulus Excel Files      ("stim_excel_files" folder) 
%
% ---------------------------------------------------------------------------
% Output(s)
%   xFile: .mat file to be used in xDiva for task design    ("xFiles" folder)



%% Set Up
tic %Start Timer 

clear; close all ; clc; % Clear Workspace

% mainPath = ~/Documents/YOUR PATH/create_xFiles_package/
mainPath = "~/Documents/Lindsey/Deep_Sea_Spellers/create_xFiles_package_AV/";
xFilesPath = fullfile(mainPath,'xFiles');
ExcelFolderPath = fullfile(mainPath,'stim_excel_files/');
imageFolderPath = fullfile(mainPath,'stim_images/');
wordFolderPath = fullfile(mainPath,'stim_images_words/');

if exist('stim_audio','dir') ~= 0
    audioFilePath = fullfile(mainPath,'stim_audio/');

    soundLength_ms = 500;       % Basing these off of the OneBack_Tracker Excell Sheet
    soundSamplingRate = 24000;  % Basing these off of the OneBack_Tracker Excell Sheet
end

% Change Directory to Main Path
cd(mainPath)

% Create xFiles Folder
if (~exist('xFile','dir'))
    mkdir(xFilesPath);
end

%% User Inputs
classNum = 3;
%conditions = 4; % Number of Sheets in the Excel file, this includes the practice Trial Sheet
%trials = 10; 


% Sizing variables (VV)
objectVerticalSizePix = 80; % vertical size of the words in pixels.

% 680x240 is the full bitmap size
nRows_full	= 500;
nCols_full	= 500;

% 600x160 is the intermediate bitmap size
nRows_small	= 160;
nCols_small	= 600; % 600;


for iClass = 1:classNum
        % Assign Excel File Path
        ExcelFilePath = strcat(ExcelFolderPath, 'DSS_Class_', num2str(iClass), '_AV.xlsx'); % Path to excel files
        sheetNames = sheetnames(ExcelFilePath);
        sheetNum = length(sheetNames);
        
       
        
    for iSheet = 1:sheetNum

         if contains(sheetNames(iSheet), 'practice', 'IgnoreCase',true)
            conditionCounter = 0; 
         end

         if (~exist('conditionCounter', 'Var'))
             conditionCoutner = iSheet;
         end
        
        % Read in Condition Data
        conditionData = readtable(ExcelFilePath, 'Sheet', iSheet); %Read in Condition Table
        
        trials = width(conditionData)-1; % Determin and Assign Number of Trials

        conditionData = conditionData(:,2:(trials+1)); % Remove first column from dataset
        

        if any(contains(conditionData.Properties.VariableNames,'Audio','IgnoreCase',true))
            trials = trials/2; % Cut Trial numbers in half
        end

        for iTrial = 1:trials

            if any(contains(conditionData.Properties.VariableNames,'Audio','IgnoreCase',true))
                trialIndices = find(contains(conditionData.Properties.VariableNames, num2str(iTrial))); % Find Trial Indices
                trialSubset = conditionData(:,trialIndices); % Extract Trial Subset
                

                stimData = cellstr(transpose(splitlines(string(trialSubset.(1))))); %First Column must be Image Files
                stimImages = []; 

                audioData = transpose(splitlines(strings(trialSubset.(2))));
                stimAudio = [];


                % desired sound length in seconds; if input sound is shorter, silence will
                % be added to the end, and if input sound is longer, it will be cut from the end to
                % this length
                desiredSoundLength = soundLength_ms / 1000;
                soundRateHz = soundSamplingRate;

                desiredNumberOfSamples = desiredSoundLength * soundRateHz;

            else
                % Convert data to string, split strings at New-Line Characters, and transpose
                stimData = cellstr(transpose(splitlines(string(conditionData.(iTrial)))));
                stimImages = [];
            end
            

            for imgID = 1:size(stimData, 2)
                if contains(stimData{:, imgID}, '.png') == 0 % .bmp File
                    %%% Read in Word Bit Map %%%


                    % Read in Gray Scale Bit Map
                    wordImg_gray = imread(strcat(wordFolderPath, stimData{:, imgID}, '.bmp')); 

                    %Convert Gray Scale Image to Index Image
                    [wordImg_Ind, wordImg_Cmap] = gray2ind(wordImg_gray,500); 

                    % Converty INdex Image to Truecolor RGB Image
                    word_rgb = ind2rgb(wordImg_Ind, wordImg_Cmap); 

                    

                    % Assign to Stim Image Structure
                    stimImages(:,:,:, imgID) = word_rgb;


                elseif contains(stimData{:, imgID}, '.png') == 1 % .png File
                    %%% Read in .png Image %%%
                    img_rgb = imread(strcat(imageFolderPath, stimData{:, imgID}));

                    img_rgb = im2double(img_rgb); % convert to double

                    % Convert Black background to grey
                    greycol = 0.5010;
                    [rows, cols, panes] = size(img_rgb);
                    black_values = find( ~sum(img_rgb,3));
                    img_rgb([black_values, black_values + rows*cols, black_values + 2*rows*cols]) = greycol;
                    %imshow(img_rgb) 

                    stimImages(:,:,:, imgID) = img_rgb;


                end
            end
           
            %% Stim Pair Generation
            if any(contains(conditionData.Properties.VariableNames,'Audio','IgnoreCase',true))
                for tokenID = 1:length(audioData)
                    currentAudio = soundsInput(tokenID);
                    currentAudioData = audioread(audioFilePath + currentAudio);
                    %currentCongruentString = congruentDots(tokenID);
                    %currentIncongruentString = incongruentDots(tokenID);
                    currentNumberOfSamples = length(currentAudioData);
                    if currentNumberOfSamples > desiredNumberOfSamples
                        currentAudioData = (currentAudioData(1:desiredNumberOfSamples, :));
                    elseif currentNumberOfSamples < desiredNumberOfSamples
                        currentAudioData = [currentAudioData; zeros(desiredNumberOfSamples - currentNumberOfSamples, 1)];
                    end
                    stimAudio = [stimAudio, currentAudioData];
                end
            end

            %% Create sub-directories for xFiles
            
            % Create Class Sub-Folder
            classFolder = strcat(xFilesPath, '/Class_', (num2str(iClass)));
            if (~exist((classFolder),'dir'))
                mkdir(classFolder);
            end
            
            if contains(sheetNames(iSheet), 'practice', 'IgnoreCase',true)
                % Create Practice Sub-Folder
                practiceFolder = strcat(classFolder, '/Class_', num2str(iClass), '_Practice');
                if (~exist((practiceFolder), 'dir'))
                    mkdir(practiceFolder);
                end

            elseif ~(contains(sheetNames(iSheet), 'practice', 'IgnoreCase',true))
                % Create Condition Sub-Folder
                conditionFolder = strcat(classFolder, '/Class_', num2str(iClass), '_Condition_', num2str(conditionCounter));
                if (~exist((conditionFolder),'dir'))
                    mkdir(conditionFolder);
                end
            end

            %% Save Out
            images = single(stimImages);
            strings = stimData; 
            %objectVerticalSizePix = ;
            
            if contains(sheetNames(iSheet), 'practice', 'IgnoreCase',true)    % If there are Practice Trials
                if ~exist('stimAudio', 'var') && ~exist('soundRateHz', 'var') % If there is NO Audio Data
                    save([xFilesPath filesep 'xFiles/Class_' num2str(iClass) ...                       % Class Folder 
                        '/Class_' num2str(iClass) '_Practice/' ...                                     % Practice Folder
                        '/DSS_Class_' num2str(iClass) '_Practice_Trial_' num2str(iTrial) '.mat'], ...  % File Name
                        'images', 'strings'); %, 'objectVerticalSizePix');                             % Output Variables

                elseif exist('stimAudio', 'var') && exist('soundRateHz', 'var') % If Audio Data Exists
                    save([xFilesPath filesep 'xFiles/Class_' num2str(iClass) ...                       % Class Folder 
                        '/Class_' num2str(iClass) '_Practice/' ...                                     % Practice Folder
                        '/DSS_Class_' num2str(iClass) '_Practice_Trial_' num2str(iTrial) '.mat'], ...  % File Name
                        'images', 'strings', 'stimAudio', 'soundRateHz'); %, 'objectVerticalSizePix'); % Output Variables
                end


            elseif ~(contains(sheetNames(iSheet), 'practice', 'IgnoreCase',true)) % If there are NO Practice Trials
                if  ~exist('stimAudio', 'var') && ~exist('soundRateHz', 'var')    % If there is NO Audio Data
                    save([xFilesPath filesep 'Class_' num2str(iClass) ...                                                            % Class Folder
                        '/Class_' num2str(iClass) '_Condition_' num2str(conditionCoutner) ...                                        % Condition Folder
                        '/DSS_Class_' num2str(iClass) '_condition_' num2str(conditionCoutner) '_Trial_' num2str(iTrial) '.mat'], ... % File Name
                        'images', 'strings'); %, 'objectVerticalSizePix');                                                           % Output Variables
                    
                elseif exist('stimAudio', 'var') && exist('soundRateHz', 'var') % If Audio Data Exists
                    save([xFilesPath filesep 'Class_' num2str(iClass) ...                                                            % Class Folder
                        '/Class_' num2str(iClass) '_Condition_' num2str(conditionCoutner) ...                                        % Condition Folder
                        '/DSS_Class_' num2str(iClass) '_condition_' num2str(conditionCoutner) '_Trial_' num2str(iTrial) '.mat'], ... % File Name
                        'images', 'strings','stimAudio', 'soundRateHz'); %, 'objectVerticalSizePix');                                % Output Variables
                end
            end

        end
        conditionCounter = conditionCounter + 1;
    end
end

toc % End Timer
