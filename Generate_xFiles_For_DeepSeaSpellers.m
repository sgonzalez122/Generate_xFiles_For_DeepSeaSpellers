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
mainPath = "~/Documents/Lindsey/Deep_Sea_Spellers/create_xFiles_package/";
xFilesPath = fullfile(mainPath,'xFiles');
ExcelFolderPath = fullfile(mainPath,'stim_excel_files/');
imageFolderPath = fullfile(mainPath,'stim_images/');
wordFolderPath = fullfile(mainPath,'stim_images_words/');

% Change Directory to Main Path
cd(mainPath)

% Create xFiles Folder
if (~exist('xFile','dir'))
    mkdir(xFilesPath);
end

%% User Inputs
classNum = 3;
conditions = 3;
trials = 10; 


% Sizing variables (VV)
objectVerticalSizePix = 80; % vertical size of the words in pixels.

% 680x240 is the full bitmap size
nRows_full	= 500;
nCols_full	= 500;

% 600x160 is the intermediate bitmap size
nRows_small	= 160;
nCols_small	= 600; % 600;


for iClass = 1:classNium

    for iCondition = 1:conditions
        % Assign Excel File Path
        ExcelFilePath = [ExcelFolderPath 'FILE_NAME' num2str(iClass) '.xlsx']; % Path to excel files
        
        % % Read in Condition Data
        conditionData = readtable(ExcelFilePath, 'Sheet', iCondition); %Read in Condition Table
        conditionData = conditionData(:,2:11); %Columns 2 through 11, will depend on the Excel lset up

        for iTrial = 1:trials
            % Convert data to string, split strings at New-Line Characters, and transpose
            stimData = cellstr(transpse(splitlines(string(conditionData.(trial)))));
            stimImages = [];

            for imgId = 1:size(stimData, 2)
                if contains(stimData{:, imgId}, '.png') == 0 % .bmp File
                    %%% Read in Word Bit Map %%%


                    % Read in Gray Scale Bit Map
                    wordImg_gray = imread(strcat(wordFolderPath, stimData{:, imgId}, '.bmp')); 

                    %Convert Gray Scale Image to Index Image
                    [wordImg_Ind, wordImg_Cmap] = gray2ind(wordImg_gray,500); 

                    % Converty INdex Image to Truecolor RGB Image
                    word_rgb = ind2rgb(wordImg_Ind, wordImg_Cmap); 

                    

                    % Assign to Stim Image Structure
                    stimImages(:,:,:, imgID) = word_rgb;


                elseif contains(stimData{:, imagID}, '.png') == 1 % .png File
                    %%% Read in .png Image %%%
                    img_rgb = imread(strcat(imageFolderPath, stimData{:, imgID}));

                    img_rgb = im2double(img_rgb); % convert to double

                    % Convert Black background to grey
                    greycol = 0.5010;
                    [rows, cols, panes] = size(img_rgb);
                    black_values = find( ~sum(img_rgb,3));
                    img_rgb([black_values, black_values + rows*cols, black_values + 2*rows*cols]) = greycol;
                    %imshow(img_rgb) 

                    stimImages(:,:,:, imgId) = img_rgb;


                end
            end


            %% Create sub-directories for xFiles
            
            % Create Class Sub-Folder
            classFolder = strcat(xFilesPath, '/Class_', (num2str(iClass)));
            if (~exist((classFolder),'dir'))
                mkdir(classFolder);
            end

            % Create Condition Sub-Folder
            conditionFodler = strcat(classFolder, '/Class_', num2str(iClass), '_Condition_', num2str(iCondition));
            if (~exist((conditionFolder),'dir'))
                mkdir(conditionFolder);
            end

            %% Save Out
            images = single(stimImages);
            strings = stimData; 
            %objectVerticalSizePix = ;

            save([xFilesPath filesep 'Class_' num2str(iClass) ...
                '/Class_' num2str(iClass) '_Condition_' num2str(iCondition) ... 
                '/DSS_Class_' num2str(iClass) '_condition_' num2str(iCondition) '_Trial_' num2str(iTrial) '.mat'], ...
                'images', 'strings'); %, 'objectVerticalSizePiox');


        end
    end
end

toc % End Timer
