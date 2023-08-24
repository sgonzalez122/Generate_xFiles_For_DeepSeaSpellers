% File: Generate_xFilesForMagicWords.m
% Programer: Stephen A. Gonzalez
% Date Created: 4/28/2023
% Purpose: 
%   This script will generate xFiles, to be used for creating tasks in xDiva
%   xFiles are created using either .png images or .mat file bitmaps.
%
% --------------------------------------------------------------------------- 
% Required files: 
%   Folder containing .png image files          ("images" folder)
%   Folder containing .xslx condition files     ("conditions" folder) 
%
% ---------------------------------------------------------------------------
% Output(s)
%   xFile: .mat file to be used in xDiva for task design                            ("xFiles" folder)
%   
%


%% Clear Workspace
tic
clear
close all
clc
cd ~/Documents/Fang/Magic_Words_Spring_2023/ %Set Working Directory

mainPath = '~/Documents/Fang/Magic_Words_Spring_2023/';
xFilesPath = fullfile(mainPath,'xFiles');

% Create main directory for X-Files
if (~exist('xFiles', 'dir'))
    mkdir(xFilesPath);
end
%% Set up user inputs
classNum = 3; % Number of Class's

conditions = 3; %Range of Conditions

trials = 10; %Number of Trials in each Condition

% Sizing variables (VV)
objectVerticalSizePix = 80; % vertical size of the words in pixels.

% 680x240 is the full bitmap size
nRows_full	= 500;
nCols_full	= 500;

% 600x160 is the intermediate bitmap size
nRows_small	= 160;
nCols_small	= 600; % 600;

for classi = 1:classNum
    for condition = 1:conditions
        %Change file paths for your computer
        excelFile = [pwd filesep 'conditions/MW_CLASS' num2str(classi) '.xlsx'];  %Path to excel files
        emojiFilePath = [pwd filesep 'emoji_Images/']; %Path to Emoji Images
        wordFilePath = [pwd filesep 'word_Images/']; %Path to Word Images
    
        %% Choosing version and initializing variables
        conditionData = readtable(excelFile, 'Sheet', condition);  %Read in Excel File
        conditionData = conditionData(:,2:11);
        %digitImageFile = matfile(digitImageMatFile);
        
        for trial = 1:trials
            % Convert data to string, split strings, and transpose like above
            % Added 1 to the trial iterator to account for the stimNum Column
            stimData = cellstr(transpose(splitlines(string(conditionData.(trial)))));
            
            stimImages = [];
    
            %% Draft code
            for imgID = 1:size(stimData, 2)
                if contains(stimData{:, imgID},'.png') == 1 % .PNG File
                    emoji_rgb = imread(strcat(emojiFilePath, stimData{:, imgID}));

                    %if classi == 3
                    %    temp = find(emoji_rgb==1);
                    %    emoji_rgb(temp) = 0;
                    %end

                    emoji_rgb = im2double(emoji_rgb); %convert to double

                    %Convert black background to grey    
                    greycol = 0.5010;
                    [rows, cols, panes] = size(emoji_rgb);
                    blacks = find( ~sum(emoji_rgb,3) );
                    emoji_rgb( [blacks, blacks + rows*cols, blacks + 2*rows*cols]) = greycol;
                    %imshow(emoji_rgb)

                    stimImages(:,:,:, imgID) = emoji_rgb;
                  

                elseif contains(stimData{:, imgID},'.png') == 0 % TEXT File
                    %Read in Word Bit Map
                    wordImg_gray = imread(strcat(wordFilePath, stimData{:, imgID}, '.bmp')); % Read in Gray Scale bit map
                    [wordImg_Ind, wordImg_Cmap] = gray2ind(wordImg_gray,500); % Convert Gray Scale Image ==> Index Image
                    word_rgb = ind2rgb(wordImg_Ind, wordImg_Cmap); % Convert Index Image ==> Truecolor RGB Image

                    stimImages(:,:,:, imgID) = word_rgb; %Assign to structure
                    
                    %{
                    wordIMG = imread(strcat(wordFilePath, stimData{:, imgID}, '.bmp'));
                    imshow(wordIMG);

                    [wordIMG_Ind, wordImgCmap] = gray2ind(wordIMG,500);

                    imshow(wordIMG_Ind, wordImgCmap);

                     word_Ind2rgb = ind2rgb(wordIMG_Ind,wordImgCmap);

                    word_Gray2RGB = grs2rgb(wordIMG);
                    imshow(word_Gray2RGB); 
                    %}
                

                    
                    %Genereate Text .mat File
                    %image = makeTextImages(stimData{:, imgID}, nRows_small, nCols_small);  
                end
            end
                
    
            %% Saving the output files
            images = single(stimImages);
            strings = stimData;
            %objectVerticalSizePix = ;
           
            % Create sub-directories for X-Files
            classFolder = strcat(xFilesPath, '/Class_', (num2str(classi)));
            if (~exist((classFolder),'dir'))
                mkdir(classFolder);
            end

            conditionFolder = strcat(classFolder, '/Class_', num2str(classi), '_Condition_', num2str(condition)+1);
            if (~exist((conditionFolder),'dir'))
                mkdir(conditionFolder);
            end

            save([pwd filesep 'xFiles/Class_'  num2str(classi) ...
                '/Class_' num2str(classi) '_Condition_' (num2str(condition)+1) ...
                '/MW_Class_' num2str(classi) '_condition_' (num2str(condition)+1) '_Trial_' num2str(trial) '.mat'], ...
                'images', 'strings'); %, 'objectVerticalSizePix');
         
            
        end
    end
end

toc
