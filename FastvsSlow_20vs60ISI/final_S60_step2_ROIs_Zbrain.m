
%%%% this si to get the ROIs of the interesting clusters to put them in
%%%% unity and to comparethem with the Zbrain masks.

%%%%in this case is for the s60

cd /QRISdata/Q0291/Emmanuel_MeDiCi/FvsS_20vs60_CNMF/matlab


load('final_S60_step1.mat','MatFiles_s60','ZS_s60','idx_Fish_s60','idx_Plane_s60','rawregressS60','idx_rsq_test_s60short','High_corr_Nb_s60','High_corr_Nb_s60_short');




Fish_list_s60=num2str(unique(idx_Fish_s60));



%%%% this is for testing with only s60 fish

%%%% now, this is the part where i used the warped datasets to get the
%%%% brain locations of my ROIs.
list=str2num(Fish_list_s60);
CSV_Files=dir('_2Warped*_Resized.csv');
%CSV_Files=dir('_2Warped1_*.csv'); %% to test with first one
ROIs=struct();truth=[]; counter=1;
for i=1:length(CSV_Files)
      
    Fishname=regexp(CSV_Files(i).name,'_2Warped(\d+)_Resized.csv','tokens');Fishname=Fishname{1}{1};    
    
    for j=1:length(Fish_list_s60)
     
    if str2num(Fishname)==list(j)
    
    %if ismember(str2num(Fishname),str2num(Fish_list_s60))
    
    temp_warp=csvread(CSV_Files(i).name,1);    
    ROIs(j).name=Fishname;    
    ROIs(j).coord=temp_warp(:,1:3);
    ROIs(j).idx=temp_warp(:,5);
    truth(j)=size(temp_warp,1)==sum(idx_Fish_s60==str2num(Fishname)) %%% important!! i need to have an idx_Fish with all the fish.
    
     counter=counter+1;
    else
    end
    end  
end



%%% this is to get the ROIs of all the fish (or the ones i used the warped files off) and put them all together.
i=1;ROI_pool=ROIs(i).coord;
for i=2:length(ROIs)
    ROI_pool=[ROI_pool; ROIs(i).coord];
end



%%% note: it was crashing cause the slice 49 of fish 46 had the same
%%% goodnumber than the previous one. i fixed by deleting that row (456).

Sort_ROIs=[];temp_nb=0;%truth=[];
MatFiles_names={MatFiles_s60.name};
for fish_nb=1:length(Fish_list_s60)
    %temp_warp=num2str(Fish_list(fish_nb)); %Gilles
    
    temp_warp=str2num(Fish_list_s60);
    temp_warp=temp_warp(fish_nb);
	IndexC=strfind({MatFiles_s60.name}, strcat('_fish',num2str(temp_warp),'_')); 
    
    fish_name=strcat('_fish',num2str(temp_warp),'_'); %%% I added this to get the fish name
    
    MatFiles_fish = find(not(cellfun('isempty', IndexC)));
    for file_nb=1:length(MatFiles_fish)
        if MatFiles_fish(file_nb)==1
            numbersForROIs=[1 MatFiles_s60(1).GoodNumber];
            
        else
            numbersForROIs=[MatFiles_s60(MatFiles_fish(file_nb)-1).GoodNumber+1 MatFiles_s60(MatFiles_fish(file_nb)).GoodNumber]; 
        end
        if ismember(numbersForROIs,Sort_ROIs)
            
            %%% note: %%% i need to get the fish_name again
            MatFiles_fish(file_nb)
            fish_name
            break
        end
        Sort_ROIs=[Sort_ROIs numbersForROIs(1):1:numbersForROIs(2)];        
    end    
    if ~length(Sort_ROIs)-temp_nb==sum(idx_Fish_s60==temp_warp)
        %~length(Sort_ROIs)-temp_nb==sum(idx_Fish==str2num(cell2mat(Fish_list_small(fish_nb)))) %%% i added the str2num and cell2mat
        fish_name
        break
    end
    temp_nb=length(Sort_ROIs);
end
clearvars slice fish_nb roi_nb ROI Centroids IndexC file_nb



ROI_fish(Sort_ROIs,:)=ROI_pool; %%% Sort_ROIs and ROI_pool need, to have the same amount of elements .doesnt work... different numbers. ask gilles. I think i know, it is cause i just have the warped images of s60 and s60 but not from the rest. i changed that but still doesnt work...
ROI_fish(:,3)=ROI_fish(:,3)/2;   %%% i need to divide by 2 the z axis


ROI_temp=round(ROI_fish);           %%% here i am rounding the values of the coordenates cause in the masks they are integers 

%clearvars ROI_pool

 %ROTATE ROI_fish IF NEEDED !!!!!!!!!!!
ROI_temp2=ROI_temp;
ROI_temp2(:,1)=ROI_temp(:,2); 
ROI_temp2(:,2)=ROI_temp(:,1); 

%%% I need to get the Zbrain_Masks

load('Zbrain_Masks.mat');


 figure;scatter(Zbrain_Masks{294,3}(:,1),Zbrain_Masks{294,3}(:,2)); %%% this is telencephalon in Zbrain
%%% and I need them to look to the right. 

%figure;
hold on; scatter(ROI_temp2(find(idx_Fish_s60==6),1),ROI_temp2(find(idx_Fish_s60==6),2)); %%% this is my rotation
%%%as I have it at the moment is looking to the right. 

%%% chekcing in 3D
figure;scatter3(ROI_temp2(find(idx_Fish_s60==6),1),ROI_temp2(find(idx_Fish_s60==6),2),ROI_temp2(find(idx_Fish_s60==6),3)); %%% this is my rotation
hold on;scatter3(Zbrain_Masks{294,3}(:,1),Zbrain_Masks{294,3}(:,2),Zbrain_Masks{294,3}(:,3));

load('final_S60_step1.mat','gooodmaps');
 
%%% To get the ROIs of each cluster. First with the raw 7.
for i=1:length(unique(High_corr_Nb_s60))

    idx_temp1=find(High_corr_Nb_s60==i);  %Or Whatever idx you?re using to identify the relevant clusters (idxKmeans_final for example)

    idx_temp2=idx_rsq_test_s60short(idx_temp1);
    
    CSV_temp=ROI_temp2(idx_temp2,:);

    CSV_temp(:,3)=CSV_temp(:,3); %%% why?

    CSV_temp(:,4)=1;

    filename=strcat('__Coords_clust_s60_CL7_',num2str(i),'.csv');

    csvwrite(filename,CSV_temp);

end

%%% to check 
%figure;plot(mean(ZS_s60(idx_temp2,:)));

%%% To get the ROIs of each cluster. now iwht the 4 main ones.
for i=gooodmaps

    idx_temp1=find(High_corr_Nb_s60_short==i);  %Or Whatever idx you?re using to identify the relevant clusters (idxKmeans_final for example)

    idx_temp2=idx_rsq_test_s60short(idx_temp1);
    
    CSV_temp=ROI_temp2(idx_temp2,:);

    CSV_temp(:,3)=CSV_temp(:,3); %%% why?

    CSV_temp(:,4)=1;

    filename=strcat('__Coords_clust_s60_CL4_',num2str(i),'.csv');

    csvwrite(filename,CSV_temp);

end

%%% to check 
%figure;plot(mean(ZS_s60(idx_temp2,ZS_short_S60)));

figure;scatter(ROI_temp2(idx_rsq_test_s60short,1),ROI_temp2(idx_rsq_test_s60short,2));

%%

%%% this is to look at brain regions

RegionList2={'Telencephalon','Pallium','Subpallium','Thalamus','Pretectum','Tectum','Hindbrain','Msystem','coeruleus'};

%progressbar;
for i=1:length(RegionList2)
    %progressbar(i/length(RegionList2));
    regionName=RegionList2{i};
    if strcmp(regionName,'Telencephalon')
        Mask=Zbrain_Masks{294,3};
    elseif strcmp(regionName,'Hindbrain')
        Hindbrain_Mask=Zbrain_Masks{259,3};
        Mask=Zbrain_Masks{131,3};
        IsInEyes_temp=ismember(Hindbrain_Mask,Mask,'rows');IsInEyes_temp=find(IsInEyes_temp==1);%remove cerebellum
        Hindbrain_Mask(IsInEyes_temp,:)=[];
        Mask=Zbrain_Masks{295,3};
        IsInEyes_temp=ismember(Hindbrain_Mask,Mask,'rows');IsInEyes_temp=find(IsInEyes_temp==1);%remove MON
        Hindbrain_Mask(IsInEyes_temp,:)=[];
        Mask=Hindbrain_Mask;
    elseif strcmp(regionName,'Msystem')
        Mask=[];
        Mask_temp=[];
        Msystem_masks=[184 186 187];
        for j=1:3
           %Mask_temp=Zbrain_Masks{Msystem_masks(j),3};
           Mask=vertcat(Mask,Zbrain_Masks{Msystem_masks(j),3});
        end
    
        clear Mask_temp
    else
        Mask=[];
        IndexC=strfind({Zbrain_Masks{:,2}}, regionName);
        IndexC=find(not(cellfun('isempty', IndexC)));
        for j=IndexC
            if isempty(Mask)
                Mask=Zbrain_Masks{j,3};
            else
                Mask=vertcat(Mask,Zbrain_Masks{j,3});
            end
        end
    end
    Mask=unique(Mask,'rows');
    IsInBrainRegion=ismember(ROI_temp2,Mask,'rows');
    PerBrainRegions.(regionName).idx=find(IsInBrainRegion==1);    
end


save('BrainReg_S60.mat','PerBrainRegions','ROI_temp2','RegionList2','-v7.3');


figure;imagesc(ZS_s60(intersect(PerBrainRegions.Telencephalon.idx,idx_rsq_test_s60short),:), [-0.5 4]);colormap hot

figure;imagesc(ZS_s60(intersect(PerBrainRegions.Thalamus.idx,idx_rsq_test_s60short),:), [-0.5 4]);colormap hot

figure;imagesc(ZS_s60(intersect(PerBrainRegions.Pretectum.idx,idx_rsq_test_s60short),:), [-0.5 4]);colormap hot

figure;imagesc(ZS_s60(intersect(PerBrainRegions.Tectum.idx,idx_rsq_test_s60short),:), [-0.5 4]);colormap hot

%%% to have a panoramic view of the CL4
figure;scatter(ROI_temp2(idx_rsq_test_s60short,1),ROI_temp2(idx_rsq_test_s60short,2));
hold on;
for i=gooodmaps

idx_temp1=find(High_corr_Nb_s60_short==i);  %%% 1 is fasthab in s60

idx_temp2=idx_rsq_test_s60short(idx_temp1);



scatter(ROI_temp2(idx_temp2,1),ROI_temp2(idx_temp2,2));
hold on;
end




RegionList3={'Pallium','Subpallium','Thalamus','Tectum','Hindbrain'};
counter=1;
%%% to plot the means per region
figure;
for j=1
    
    idx_temp=find(High_corr_Nb_s60_short==j);
    
    for i=1:length(RegionList3)
    regionName=RegionList3{i};
    %idx_temp2=intersect(PerBrainRegions.(regionName).idx,idx_rsq_test_f20short(idx_temp));
    %means_fasthab_CL4{i}=mean(ZS_f20(idx_temp2,:));
    %subplot(3,3,counter);
    plot(mean(ZS_s60(intersect(PerBrainRegions.(regionName).idx,idx_rsq_test_s60short(idx_temp)),55:100)));
   hold on; 
   counter=counter+1;
    
    end

    
   
end

%print(gcf,'mean1st_perReg_fasthab_CL4_s60','-dpdf','-bestfit');
