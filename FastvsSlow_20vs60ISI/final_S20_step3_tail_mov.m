
%%% this script is to get the ROIs that correlated to the movements. I do
%%% it with a linear regression. I found that 0.2 was a good threshold.

%%% for fish s20

%%%% first you need to load what you need

cd /QRISdata/Q0291/Emmanuel_MeDiCi/FvsS_20vs60_CNMF/matlab

load('BrainReg_S20.mat')
load('final_S20_step1.mat','MatFiles_s20','ZS_s20','idx_Fish_s20','idx_Plane_s20','rawregressS20','idx_rsq_test_s20short','High_corr_Nb_s20','High_corr_Nb_s20_short');
load('Zbrain_Masks.mat');
load('final_S20_step1.mat','gooodmaps');


load('allfish_s20looms_tailmov2.mat','-mat');

%%

allfish_s20looms_tailmov=cell2mat(allfish_s20looms_tailmov(2:end,:));


%%%first to generate the regressors for the movements. 
Fish_movements={}; %%%first we make a structure to put the data in
for fish=1:size(allfish_s20looms_tailmov,2) %%%we make a variable 'fish' as long as the columns from the Behavioural_responses variable which has the data copied from excel
    for i=1:2 %%%% Note: here I had a loop to work with the different strenght responses but in the new analysis i am not doing that.
        %%% cause I have resposnes from 1-4 depending on the strenght of the moment.
        
        temp=find(allfish_s20looms_tailmov(:,fish)==i); %%%to find the type of responses in turn. 
        temp=round(temp/5);%%%% i this is to round it to the frame rate that we use for the SPIM videos. the tail movies have a 10 Hz and the SPIM is 2Hz. 
        temp(temp<1)=[];
        temp(temp>(length(allfish_s20looms_tailmov)-1))=[];        
        Fish_movements{fish,i}=temp;
        
        
    end
    
    %%% this is loop is to locate the moments the loom is ON.
    %%% but I need to make a vector with the momennts the loom is on. 
    if fish==11 %%at the moment is 11 (for s20)
        temp=find(allfish_s20looms_tailmov(:,fish)==2);
        temp=round(temp/5);
        temp(temp<1)=[];
        temp(temp>(length(allfish_s20looms_tailmov)-1))=[];        
        Fish_movements{fish,1}=temp;
    end
end


%%%this is to put Gcamp spikes to the fish movements. 
Movements=zeros(size(allfish_s20looms_tailmov,2)-1,1,size(ZS_s20,2)); %%%to mae a 3D array the size of the number of fish (18 at the moment), the type of movement (1) and the lenght of the SPIM movies (depending on the variable). 
%GCaMP6=[5.13796058542217,10.3756715204800,11.8173714529814,12.2425184714093,10.8571417354877,8.80831829681196,6.91339112244670,5.46959264663869,4.30868766622567,3.42533619066766,2.75378443486879,2.18017250852183,1.72816235135824,1.32732537295463,1.00684435500268,0.730210038304555,0.530242444093118,0.362253250339685,0.227668255288566,0.0869242416152502]';
GCaMP6=[0,0.5,1.69644104899772,5.13796058542217,8.27886020152244,10.3756715204800,11.8173714529814,12.2425184714093,10.8571417354877,8.80831829681196,6.91339112244670,5.46959264663869,4.30868766622567,3.42533619066766,2.75378443486879,2.18017250852183,1.72816235135824,1.32732537295463,1.00684435500268,0.730210038304555,0.530242444093118,0.362253250339685,0.227668255288566,0.0869242416152502,0.000718266708050853,-0.0828334873368325]';
for fish=1:size(allfish_s20looms_tailmov,2)-1
    for movement=1  %movement=1:4
        idx=Fish_movements{fish,movement};%%%%to take the timepoints of the movements.  
        if idx
            for i=idx'
                Movements(fish,movement,i:i+size(GCaMP6,1)-1)=GCaMP6/6;%%% to place the Gcamp spikes in the places where the movements occur
            end
        end
    end
end
Movements=Movements(:,:,1:size(ZS_s20,2));


%%

%%% this is the fish list. but I want find a way to put them on top of
%%% every fish behavioural gcamp trace

% Fish_with_behav_f20=[1 7 13 17 21 25 29 34 38 40 44 48];
% 
% Fish_with_behav_f60=[3 4 8 9 15 19 26 32 37 41 47];
% 
 Fish_with_behav_s20=[5 10 14 18 22 24 28 33 36 43 45];
% 
%Fish_with_behav_s60=[6 11 12 16 20 23 27 30 31 35 39 42 46];

Fish_with_behav_s20=intersect(unique(idx_Fish_s20),Fish_with_behav_s20);



%%% to show where when all the looms are presented


loomtimes=zeros(1,size(ZS_s20,2)); %%%to mae a 3D array the size of the number of fish (18 at the moment), the type of movement (1) and the lenght of the SPIM movies (depending on the variable). 

idx=Fish_movements{11,1};%%%%to take the timepoints of the movements.  %%%% the index of the cell changes with the datasets!!!
       
  for i=idx'
   loomtimes(1,i)=0.5;%%% to place the Gcamp spikes in the places where the movements occur
  end
        
 


figure;plot(loomtimes);


%%

%%% i will check how it looks with a linear regression with the all the movements to the
%%%%Gcamps of the actual brain imaging of each fish.I am taking away the
%%%%first 3 looms. for s20 it would be from 180 onwards

%         Movements2=squeeze(Movements(:,1,:)); %%% done before
%         Movements2=squeeze(Movements2);
%        plot(Movements2(fish,:))

%%% I might aslo try to select only the
%%% parts where the movement responses could be happening. 

ModelResults_allmovPerFish={};
counter=1;
rsquare_loom_allmov={};
for fish=1:length(Fish_with_behav_s20)
   if ismember(Fish_with_behav_s20(fish),unique(idx_Fish_s20))
%for fish= Fish_with_behav_s20
   %if ismember(fish,unique(idx_Fish_s20))  
    temp_ZS=ZS_s20(find(idx_Fish_s20==Fish_with_behav_s20(fish)),:);ModelResults_temp=[];
    %temp_ZS=ZS_s20(find(idx_Fish_s20==fish),:);ModelResults_temp=[];
        parfor i=1:size(temp_ZS,1)  %%%parfor is to do it in parallel
    
        %%% this is to to the linear regression: LM = stepwiselm(X,Y) fits a linear regression model using the column
        %%vector Y as a response variable and the columns of the matrix X as
        %%%predictor variables, performs stepwise regression, and returns the
        %%final result as the linear model LM.
        
        mdl=fitlm(squeeze(squeeze(Movements(find(Fish_with_behav_s20==Fish_with_behav_s20(fish)),:)))',temp_ZS(i,:));
         
        %mdl=fitlm(rawregress_CN',temp_ZS(i,:)); %%to test if the code is working
         
        %%% this one is to take just the timepoints where the looms should
        %%% be on... i might need to fidle with it to add extra timepoints
        %%% before and after.
        %mdl=fitlm(squeeze(squeeze(Movements(find(Fish_with_behav_s20==fish),find(Movements2(find(Fish_with_behav_s20==fish),:)))))',temp_ZS(i,find(Movements2(find(Fish_with_behav_s20==fish),:))));
    
        
        %%%this is to put the results in the ModelResulsts variable
        ModelResults_temp(i).coef=mdl.Coefficients;
        ModelResults_temp(i).MSE=mdl.MSE;
        ModelResults_temp(i).Fitted=mdl.Fitted;
        ModelResults_temp(i).rsquared=mdl.Rsquared.Adjusted;
        end
        
        ModelResults_allmovPerFish{counter}=ModelResults_temp;
       
        rsquare_loom_allmov{counter}=[ModelResults_temp.rsquared];
        
         counter=counter+1;
        
   else
   end
end


%%

%%%this is to get the idx of the ROIs that passed the rsq2 thereshold that we choose to the movements
%%%(regardless of the loom). it solves the problem of the indexing. 
%%% i think 0.2 is a good threshold


idx_rsq_Mov={};
rsquare_loom_allmov2={};
counter=1;
for fish=1:length(Fish_with_behav_s20)
   if ismember(Fish_with_behav_s20(fish),unique(idx_Fish_s20))  
    temp_idx=find(idx_Fish_s20==Fish_with_behav_s20(fish)); idx_Mov_temp=[];   
    rsq_temp=[ModelResults_allmovPerFish{1,counter}.rsquared];
    idx_Mov_temp=temp_idx(find(rsq_temp>0.2 & rsq_temp<1),:);
    idx_rsq_Mov{counter}=idx_Mov_temp;
    rsquare_loom_allmov2{counter}=rsq_temp;
    counter=counter+1;
   else
   end    
end

clear idx_Mov_temp temp_idx rsq_temp counter

idx_rsq_Mov=vertcat(idx_rsq_Mov{:});
figure; imagesc(ZS_s20(idx_rsq_Mov,:), [-0.5 4]);colormap hot


rsquare_loom_allmov2=horzcat(rsquare_loom_allmov2{:});

figure;histogram(rsquare_loom_allmov2);


save('Tail_mov_S20.mat','idx_rsq_Mov','rsquare_loom_allmov2','ModelResults_allmovPerFish','loomtimes','Fish_with_behav_s20','Movements','-v7.3');


%%

%%% To get the ROIs of of the movements 


   
    
    CSV_temp=ROI_temp2(idx_rsq_Mov,:);

    CSV_temp(:,3)=CSV_temp(:,3); %%% why?

    CSV_temp(:,4)=1;

    filename=strcat('__Coords_Tail_mov_s20_','.csv');

    csvwrite(filename,CSV_temp);


%%
%%%%and this is to plot the means of the traces of the ROIs that had an r2
%%%%value above the threshold set above.
%%%% It makes a figure with a subplot of each fish. 
 


   
    counter=1;
    figure; 
    xplot=floor(sqrt(length(Fish_with_behav_s20)));yplot=ceil(length(Fish_with_behav_s20)/xplot);
    for fish=Fish_with_behav_s20
        if ismember(fish,unique(idx_Fish_s20)) %%isempty(Correlation_movement_post3{fish})~=1 % idx_Fish_s20==Fish_with_behav_s20(fish)
        temp_ZS=ZS_s20(find(idx_Fish_s20==fish),:);        
        rsq_temp=[ModelResults_allmovPerFish{1,counter}.rsquared];
        subplot(xplot,yplot,counter);plot(mean(temp_ZS(find(rsq_temp>0.2 & rsq_temp<1),:),1));
        hold on
%       Movements2=squeeze(Movements(:,i,:)); %%% this was already done before
%       Movements2=squeeze(Movements2);
        plot(Movements2(find(Fish_with_behav_s20==fish),:))
        plot(loomtimes);
        hold off
        
        %mdl=stepwiselm(Stimuli',mean(temp_ZS(find(Correlation(i,:)>Threshold),:),1),'linear','Criterion','adjrsquared','Intercept',true,'Upper','interactions','Verbose',0);
        %title(num2str([mdl.Rsquared.Adjusted]));
        title(strcat(' nb of ROIs : ', num2str(length(find(rsq_temp>0.2 & rsq_temp<1)))));
        
         counter=counter+1;
        else
        end
    end

    clear temp_ZS rsq_temp counter



%%
%%% this is to play a bit with the movement and the clusters data 



figure;
scatter3(ROI_temp2(idx_rsq_test_s20short,1),ROI_temp2(idx_rsq_test_s20short,2),ROI_temp2(idx_rsq_test_s20short,3)); %%% this is my rotation
hold on;
scatter3(ROI_temp2(idx_rsq_Mov,1),ROI_temp2(idx_rsq_Mov,2),ROI_temp2(idx_rsq_Mov,3)); %%% this is my rotation


figure;
scatter(ROI_temp2(idx_rsq_test_s20short,1),ROI_temp2(idx_rsq_test_s20short,2),'.'); %%% this is my rotation
hold on;
scatter(ROI_temp2(idx_rsq_Mov3,1),ROI_temp2(idx_rsq_Mov3,2),'.'); %%% this is my rotation


figure;
scatter(ROI_temp2(intersect(find(idx_Fish_s20==1),idx_rsq_test_s20short),1),ROI_temp2(intersect(find(idx_Fish_s20==1),idx_rsq_test_s20short),2),'.'); %%% this is my rotation
hold on;
scatter(ROI_temp2(intersect(find(idx_Fish_s20==1),idx_rsq_Mov),1),ROI_temp2(intersect(find(idx_Fish_s20==1),idx_rsq_Mov),2),'.'); %%% this is my rotation


idx_temp1=idx_rsq_test_s20short(find(High_corr_Nb_s20_short==3));
idx_temp2=idx_rsq_test_s20short(find(High_corr_Nb_s20_short==1));

figure;
scatter3(ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_rsq_test_s20short),1),ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_rsq_test_s20short),2),ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_rsq_test_s20short),3),'.'); %%% this is my rotation
hold on;
scatter3(ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_rsq_Mov),1),ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_rsq_Mov),2),ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_rsq_Mov),3),'.'); %%% this is my rotation
hold on;
scatter3(ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_temp1),1),ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_temp1),2),ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_temp1),3),'.'); %%% this is my rotation
hold on;
scatter3(ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_temp2),1),ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_temp2),2),ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_temp2),3),'.'); %%% this is my rotation

hold on;
scatter3(ROI_temp2(intersect(PerBrainRegions.Subpallium.idx,idx_rsq_test_s20short),1),ROI_temp2(intersect(PerBrainRegions.Subpallium.idx,idx_rsq_test_s20short),2),ROI_temp2(intersect(PerBrainRegions.Subpallium.idx,idx_rsq_test_s20short),3),'.'); %%% this is my rotation
hold on;
scatter3(ROI_temp2(intersect(PerBrainRegions.Subpallium.idx,idx_rsq_Mov),1),ROI_temp2(intersect(PerBrainRegions.Subpallium.idx,idx_rsq_Mov),2),ROI_temp2(intersect(PerBrainRegions.Subpallium.idx,idx_rsq_Mov),3),'.'); %%% this is my rotation


%%% to look at the nonhab cluster in the pallium per individual fish
figure; 
%scatter3(ROI_temp2(intersect(PerBrainRegions.Telencephalon.idx,idx_rsq_test_s20short),1),ROI_temp2(intersect(PerBrainRegions.Telencephalon.idx,idx_rsq_test_s20short),2),ROI_temp2(intersect(PerBrainRegions.Telencephalon.idx,idx_rsq_test_s20short),3)); %%% this is my rotation
hold on;
     for fish=Fish_with_behav_s20
        if ismember(fish,unique(idx_Fish_s20)) %%isempty(Correlation_movement_post3{fish})~=1 % idx_Fish_s20==Fish_with_behav_s20(fish)
        idx_temp_fish=intersect(find(idx_Fish_s20==fish),idx_rsq_test_s20short);
        idx_temp_nonhab=idx_rsq_test_s20short(find(High_corr_Nb_s20_short==1));
        idx_temp_nonhab_fish=intersect(idx_temp_nonhab,idx_temp_fish);
        scatter3(ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_temp_nonhab_fish),1),ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_temp_nonhab_fish),2),ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_temp_nonhab_fish),3),'.'); %%% this is my rotation

          hold on;
   
        else
        end
    end

    clear idx_temp_fish idx_temp_nonhab idx_temp_nonhab_fish



%%% moving neurons in the subpallium of fish 1
idx_temp1=intersect(PerBrainRegions.Subpallium.idx,idx_rsq_Mov);

figure;imagesc(ZS_s20(intersect(idx_temp1,find(idx_Fish_s20==1)),:));

figure;plot(mean(ZS_s20(intersect(idx_temp1,find(idx_Fish_s20==1)),:)));

%%% moving neurons in the pallium of fish 1
idx_temp2=intersect(PerBrainRegions.Pallium.idx,idx_rsq_Mov);
idx_temp3=intersect(PerBrainRegions.Pallium.idx,idx_rsq_Mov2);

figure;imagesc(ZS_s20(intersect(idx_temp2,find(idx_Fish_s20==1)),:));
figure;imagesc(ZS_s20(intersect(idx_temp3,find(idx_Fish_s20==1)),:));

figure;plot(mean(ZS_s20(intersect(idx_temp2,find(idx_Fish_s20==1)),:)));
figure;plot(mean(ZS_s20(intersect(idx_temp3,find(idx_Fish_s20==1)),:)));

figure;
scatter3(ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_rsq_test_s20short),1),ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_rsq_test_s20short),2),ROI_temp2(intersect(PerBrainRegions.Pallium.idx,idx_rsq_test_s20short),3),'.'); %%% this is my rotation
hold on;
scatter3(ROI_temp2(intersect(idx_temp2,find(idx_Fish_s20==1)),1),ROI_temp2(intersect(idx_temp2,find(idx_Fish_s20==1)),2),ROI_temp2(intersect(idx_temp2,find(idx_Fish_s20==1)),3),'.'); %%% this is my rotation
hold on;
scatter3(ROI_temp2(intersect(idx_temp3,find(idx_Fish_s20==1)),1),ROI_temp2(intersect(idx_temp3,find(idx_Fish_s20==1)),2),ROI_temp2(intersect(idx_temp3,find(idx_Fish_s20==1)),3),'.'); %%% this is my rotation





