


%%%%% this script is to find the possible boundaries of gamma and omega. 

%%%% the maximum gamma could be when having a number of communities that is
%%%% half the number of nodes = 45  or a quarter = 23. the minim gamma
%%%% could be when there are less than 4 comunities as this are my
%%%% functional clusters

%%%% the maximum omega could be when there is no change across the time
%%%% dimension in at least one node. the min omega could be when there is a
%%%% change at every time point


%%
%%%% now, I will be testing this using the results from the consensus attempt

load('S_cons_testing_GnO_measures6.mat');


%% first, just looking at the general values
%%%% in general, it seems that fmr1 has higher flexibility values

counter=1;
figure;
for group=[3 1 2]
   subplot(3,3,counter);imagesc(FlexMat.(groupnames{group}));caxis([0 1]);
   title(strcat('flex/',groupnames{group},'/med=',num2str(median(FlexMat.(groupnames{group})(:)))));
   
   counter=counter+1;
end
for group=[3 1 2]
   subplot(3,3,counter);imagesc(CoheMat.(groupnames{group}));caxis([0 1]);
   title(strcat('cohe/',groupnames{group},'/med=',num2str(median(CoheMat.(groupnames{group})(:)))));
   
   counter=counter+1;
end
for group=[3 1 2]
   subplot(3,3,counter);imagesc(PromMat.(groupnames{group}));caxis([0 1]);
   title(strcat('prom/',groupnames{group},'/med=',num2str(median(PromMat.(groupnames{group})(:)))));
   
   counter=counter+1;
end


counter=1;
test=[];
for group=[3 1 2]
    test(:,counter)=FlexMat.(groupnames{group})(:);
    
    counter=counter+1;
end


figure;boxplot(test);

%     [p, tbl, stats]=anova1(test);
%     figure;
%     [c, m]=multcompare(stats,'CType','bonferroni');
    
   %%%%OR
   for group=[1 2 3]  %%% cause now they are in the right order
   kstest(test(:,group))
   end 
   
   %%%% they are not normal... so  kruskalwallis? or Friedman? I think it
   %%%% would be friedman cause is not replicates on the same conditions
        %[p, tbl, stats]=kruskalwallis(test);
        [p, tbl, stats]=friedman(test,1);
    figure;
    [c, m]=multcompare(stats,'CType','bonferroni');
    
    
    %%%%% would it be better to do a ranksum comparison? it looks at the
    %%%%% differences in the median. I think this is more accurate. In this
    %%%%% case the difference between WTvsfmr1 is sig. 
    
%     [p, tbl, stats]=ranksum(test(:,1),groups_flexibilityTest(:,3));
%     p
    



%%

%%% looking at the concensus
counter=1;
figure;
for i=1:25
    
    for j=1:20
        
   subplot(25,20,counter);imagesc(Big_FMR1_OPT{i,j}.control.S_cons);
   counter=counter+1;
    end
    
end

%%%% looking at a random raw 
counter=1;
figure;
for i=1:25
    
    for j=1:20
      sample=randperm(100,1);  
   subplot(25,20,counter);imagesc(Big_FMR1_OPT{i,j}.control.S_test(:,:,sample));
   counter=counter+1;
    end
    
end

%%
MAT_O_limits=[];
MAT_G_limits=[];
for i=1:25
    
    for j=1:20
        
        temp_mat=Big_FMR1_OPT{i,j}.control.S_cons;
        nodes=size(temp_mat,1);
        times=size(temp_mat,2);
        
        %%% testing for number of communities
        temp=[];
        for t=1:times
            temp(t)=max(temp_mat(:,t));           
        end
        
        if max(temp)>60  %%% I am testing with a quarter too
            
           MAT_G_limits(i,j)=1;
         elseif min(temp)<4  %%% 4 as is the number of my hab clusters... 
             MAT_G_limits(i,j)=-1;
        else
            MAT_G_limits(i,j)=0;
        end
            
        %%%% testing changes in time (min and max omega)
        temp=[];
        temp_lim=[];
        for n=1:nodes
            
            for t=2:length(temp_mat(n,:)) %%%% i am taking from timepoint 2 to compare with previous timepoint
                if temp_mat(n,t)==temp_mat(n,t-1)
                    temp(n,t)=1;
                else
                    temp(n,t)=0;
                end
                               
            end
            
            if temp(n,2)==0 && temp(n,12)==0 %%% to check the first and recovery looms
                temp_lim(n)=0;
            else
                temp_lim(n)=1;
            end
        end
        
        if sum(temp_lim)>68 %%%% i am not taking into account the 1 node cause it never changes community as is the reference node for being the first    
        MAT_O_limits(i,j)=1; 
        else
        MAT_O_limits(i,j)=0;    
        end
    
        
    end
    
end

figure;imagesc(MAT_G_limits);
figure;imagesc(MAT_O_limits);

%%%% to check the differences in flexibility with the
%%%% checking_GnO_measures.m script

good=intersect(find(MAT_G_limits==0),find(MAT_O_limits==0));

goodMat=zeros(size(MAT_G_limits));
goodMat(good)=1;
figure;imagesc(goodMat);

[g,o]=find(goodMat);


