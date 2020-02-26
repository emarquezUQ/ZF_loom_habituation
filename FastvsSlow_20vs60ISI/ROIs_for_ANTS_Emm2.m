%%%%This script is to get the ROIs for the ANTs
%%%% it is based in gilles ANTs-ROI_code.m in github


%%% to get the data
MatFiles=dir('*analysis_matlab.mat');


%%%to get the individual fish nambes or number
idx_Fish_name={};
for i=1:length(MatFiles)
    name=strcat(MatFiles(i).name);
    [Fish,~]=regexp(name,'fish(\d+)_','tokens','match');Fish=Fish{1}; %%%to get the number of the fish 
    if iscell(Fish)
        Fish=Fish{1};
    end
    idx_Fish_name{i}=Fish;
end
clearvars i Fish  name 
Fish_list=unique(idx_Fish_name);


%Creates ROI csv files
Errored_ROI={};
progressbar(0,0,0);
for fish_nb=1:length(Fish_list)
    if iscell(Fish_list)
        IndexC=strfind({MatFiles.name}, Fish_list{fish_nb});
    else
        IndexC=strfind({MatFiles.name}, num2str(Fish_list(fish_nb)));
    end       
    MatFiles_fish = find(not(cellfun('isempty', IndexC)));
    progressbar(fish_nb/length(Fish_list));
    Centroids=zeros(1,5);    
    for file_nb=1:length(MatFiles_fish)
        progressbar([],file_nb/length(MatFiles_fish));
        name=MatFiles(MatFiles_fish(file_nb)).name;
        Rs=load(name, 'ROIs');
        Rs=Rs.ROIs;
        %F=load(name, 'idx_components');%Include all the ROIs
        %F=F.idx_components+1;
        %Rs=Rs(:,F);
        cor_name=strrep(name,'analysis_matlab','correlation');
        cor_im=load(cor_name);cor_im=cor_im.Correlation_image;
        dims=size(cor_im);
        if file_nb==1
            temp_roi=0;
        else
            temp_roi=temp_roi+size(ROI,3);
        end
        ROI=reshape(full(Rs),dims(1),dims(2),size(Rs,2));counter=1;
        [slice,~]=regexp(name,'Slice(\d+)_','tokens','match');slice=str2num(slice{1}{1});
        for roi_nb=1:size(ROI,3)
            progressbar([],[],roi_nb/size(ROI,3));
            temp=regionprops(uint16(squeeze(ROI(:,:,roi_nb)))==max(max(uint16(squeeze(ROI(:,:,roi_nb))))),'Centroid');
            Centroids(roi_nb+temp_roi,5)=roi_nb+temp_roi;
            %Centroids(roi_nb+temp_roi,1:2)=temp.Centroid; With the resize
            %need to multiply coords by 1.5
            temp=temp.Centroid;
            Centroids(roi_nb+temp_roi,1:2)=temp;
            Centroids(roi_nb+temp_roi,3)=slice;
        end     
        
    end    
    if iscell(Fish_list)
        image_name=strcat('_ROIsFish',Fish_list{fish_nb},'b.csv');
    else
        image_name=strcat('_ROIsFish',num2str(Fish_list(fish_nb)),'b.csv');
    end
    csvwrite(image_name,Centroids);
end
clearvars slice fish_nb roi_nb ROI Centroids IndexC file_nb

%-------------------------------
%%
% Read the output of ANTs to extract the ROIs centroid
%

CSV_Files=dir('_2Warped*.csv');
%CSV_Files=dir('_Warped*.csv');
ROIs=struct();
for i=1:length(CSV_Files);
    temp=csvread(CSV_Files(i).name,1);
    %Fishname=regexp(CSV_Files(i).name,'Fish(\d+_\w+).csv','tokens');Fishname=Fishname{1}{1};
    Fishname=regexp(CSV_Files(i).name,'FishResized(\d+_\w+).csv','tokens');Fishname=Fishname{1}{1};
    %Fishname=regexp(CSV_Files(i).name,'Betas(\d+_\w+).csv','tokens');Fishname=Fishname{1}{1};
    ROIs(i).name=Fishname;    
    ROIs(i).coord=temp(:,1:3);
    ROIs(i).idx=temp(:,5);
    %ROIs(i).cluster=temp(:,6);
end
clearvars i temp CSV_Files Fishname



%%


%%% this bit has changes that Gilles made on the 2018/07/09


%Creates ROI csv files

Errored_ROI={};

progressbar(0,0,0);

for fish_nb=1:length(Fish_list)
    %fish_name=strcat('_fish',num2str(Fish_list(fish_nb)),'_'); %%% gilles
    fish_name=strcat('_fish',(Fish_list(fish_nb)),'_');
    IndexC=strfind({MatFiles.name},fish_name);
    MatFiles_fish = find(not(cellfun('isempty', IndexC)));
    progressbar(fish_nb/length(Fish_list));
    Centroids=zeros(1,5);    

    for file_nb=1:length(MatFiles_fish)
        progressbar([],file_nb/length(MatFiles_fish));
        name=MatFiles(MatFiles_fish(file_nb)).name;
        Rs=load(name, 'ROIs');
        Rs=Rs.ROIs;
        F=load(name, 'idx_components');%Include all the ROIs
        F=F.idx_components+1;
        Rs=Rs(:,F);
        cor_name=strrep(name,'analysis_matlab','correlation');
        cor_im=load(cor_name);cor_im=cor_im.Correlation_image;
        dims=size(cor_im);
        if file_nb==1
            temp_roi=0;
        else
            temp_roi=temp_roi+size(ROI,3);
        end
        ROI=reshape(full(Rs),dims(1),dims(2),size(Rs,2));counter=1;
        [slice,~]=regexp(name,'Slice(\d+)_','tokens','match');slice=str2num(slice{1}{1});
        for roi_nb=1:size(ROI,3)
            progressbar([],[],roi_nb/size(ROI,3));
            temp=regionprops(uint16(squeeze(ROI(:,:,roi_nb)))==max(max(uint16(squeeze(ROI(:,:,roi_nb))))),'Centroid');
            Centroids(roi_nb+temp_roi,5)=roi_nb+temp_roi;
            %Centroids(roi_nb+temp_roi,1:2)=temp.Centroid; With the resize
            %need to multiply coords by 1.5
            temp=temp.Centroid;
            Centroids(roi_nb+temp_roi,1:2)=temp;
            Centroids(roi_nb+temp_roi,3)=slice;
        end     
    end    
    if iscell(Fish_list)
        image_name=strcat('_ROIsFish',Fish_list{fish_nb},'.csv');
    else
        image_name=strcat('_ROIsFish',num2str(Fish_list(fish_nb)),'.csv');
    end
    csvwrite(image_name,Centroids);
end

clearvars slice fish_nb roi_nb ROI Centroids IndexC file_nb

 
