%Main script to load data and use learning algorithms

%% Setup paths and files
path = 'D:\PhD\Datasets\Dataset_Aug-Sep\Hussain\6dof\';
featureList = {'obj.x','obj.x - obj.goalPose'};

%Generate motion files from all 6DOF data
filelist = dir([path '*.mat']);
for i=1:size(filelist,1)
    filename = filelist(i).name;
    genPoseFrom6D(filename,path,path);
end


%% Generate Data objects by appending all data

%Get all the data with healthy movement
filelist = dir([path '*RM' '*healthy' '*.mot']);

%Create a data object
d = data( fullfile(path,filelist(1).name), -1, -1);

%Define features to learn and construct features
d.featureList = featureList;
d.constructFeatures();

%Append data
for i=2:size(filelist,1)
    filename = filelist(i).name;
    temp = data(fullfile(path,filename),-1,-1);
    temp.featureList = featureList;
    temp.constructFeatures();
    d.append(temp);
end

%% Learn cost function and simulate
%w = learnCostWanxin(d1);
[obj, theta] = learnCostSubOpt(d);

%Forward simulate with the learned cost function. 
%[phiSim,xSim,obj_RM2Healthy_Sim] = simulate(d1,theta);

%% Compare healthy and compensated motions of appended data

%All files with healthy motion
filelist = dir([path '*RM' '*healthy' '*.mot']);
nFiles = size(filelist,1);

%Create a plot object to plot healthy motion
figure('Name','Cost Analysis','NumberTitle','Off','Position',[300 50 1000 600]);
xlabel('Time t(s)','Interpreter','latex','FontSize', 15);
ylabel('Elapsed cost $$\Big( \sum_{i=0}^{t}F_\theta \Big)$$','Interpreter','latex','FontSize', 15);
hold on
for i=1:nFiles
    d = data( fullfile(path,filelist(i).name), -1, -1);
    d.featureList = featureList;
    d.constructFeatures();
    [~, costToGo] = valueOfTraj(d,theta);
    plot(1:d.length,costToGo,'b');
end

%All files with compensatory movement
filelist = dir([path '*RM' '*comp' '*.mot']);
nFiles = size(filelist,1);
for i=1:nFiles
    d = data( fullfile(path,filelist(i).name), -1, -1);
    d.featureList = featureList;
    d.constructFeatures();
    [~, costToGo] = valueOfTraj(d,theta);
    plot(1:d.length,costToGo,'r');
end


%% Analyze Costs
% d2 = data(fullfile(path,[filename '.mot']),-1,-1);
% d2.featureList = featureList;
% d2.constructFeatures();
% [~,costToGo_RM2Healthy] = valueOfTraj(d1,theta);
% 
% 
% %Value of RM2 Compensated
% d3 = data(fullfile(path,['2_RM2_comp01' '.mot']),200,440);
% d3.featureList = featureList;
% d3.constructFeatures();
% [~,costToGo_RM2Comp] = valueOfTraj(d3,theta);
% 
% %Cumulative cost
% costToGo_RM2Healthy_Sim = zeros(d1.length,1);
% for i=1:d1.length
%     costToGo_RM2Healthy_Sim(i) = sum(obj_RM2Healthy_Sim(1:i));
% end



%% Plot 
% figure('Name','Cost Analysis','NumberTitle','Off','Position',[300 50 1000 600]);
% plot((1:d1.length)/100,costToGo_RM2Healthy);
% xlabel('Time t(s)','Interpreter','latex','FontSize', 15);
% ylabel('Elapsed cost $$\Big( \sum_{i=0}^{t}F_\theta \Big)$$','Interpreter','latex','FontSize', 15);
% hold on
% plot((1:d3.length)/100,costToGo_RM2Comp);
% legend('Healthy Motion','Compensated Motion');

%% Real-time plot
% clearvars F h_healthy h_comp h_sim
% close all;
% f = figure('Name','Cost Analysis','NumberTitle','Off','Position', [300 50 1000 600]);
% xlabel('time (s)','Interpreter','latex','FontSize', 15);
% ylabel('Elapsed cost $$\Big( \sum_{i=0}^{t}F_\theta \Big)$$','Interpreter','latex','FontSize', 15);
% h_comp = animatedline('Color','r','Linewidth',1.5,'DisplayName','Compensatory');
% h_healthy = animatedline('Color','b','Linewidth',1.5,'DisplayName','Healthy');
% h_sim = animatedline('Color','g','Linewidth',1.5,'DisplayName','Simulated');
% %Text
% txt = 'Compensatory Movement Detected';
% t = text(1.45,80,txt,'FontSize',15,'Color','r');
% t.Visible = 'off';
% %Line for threshold
% lin = yline(15,'k','DisplayName','Threshold','Linewidth',1.5);
% 
% %Annotation for compensatory motion detection
% arrow = annotation('textarrow',[0.48,0.44], [0.8,0.55],'Linewidth',2);
% arrow.HorizontalAlignment = 'Left';
% arrow.Visible = 'off';
% legend('Position',[0.2,0.76,0.12,0.08],'FontSize',20);
% 
% %Annotation for threshold
% arrowTh1 = annotation('textarrow',[0.4,0.4], [0.37,0.255],'Linewidth',2);
% arrowTh2 = annotation('textarrow',[0.4,0.4], [0.42,0.54],'Linewidth',2);
% t_th = text(1.35,-15,'Threshold','FontSize',15);
% arrowTh1.Visible = 'off';arrowTh2.Visible = 'off'; t_th.Visible = 'off';
% 
% xlim([0 min(d1.length,d3.length)/100]);
% ylim([-80 100]);
% 
% nZeros = 130;        
% for j=1:nZeros
%         addpoints(h_comp,j/100,0);
%         addpoints(h_healthy,j/100,0);
%         addpoints(h_sim,j/100,0);
%         drawnow
%         F(j) = getframe(gcf);
% end
% arrowTh1.Visible = 'on';
% arrowTh2.Visible = 'on'; 
% t_th.Visible = 'on';
% for i=1:min(d1.length,d3.length)        
%     addpoints(h_comp,(i+nZeros)/100,costToGo_RM2Comp(i));
%     addpoints(h_healthy,(i+nZeros)/100,costToGo_RM2Healthy(i));
%     addpoints(h_sim,(i+nZeros)/100,costToGo_RM2Healthy_Sim(i));
%     drawnow
%     if i>60%mod(i,50) == 0 && strcmp(t.Visible,'off')
%             t.Visible = 'on';
%             arrow.Visible = 'on';
% %         elseif mod(i,50) == 0 && strcmp(t.Visible,'on')
% %             t.Visible = 'off';
% %             arrow.Visible = 'off';
%     end
%     
%     %Draw line
% 
%     F(i+nZeros) = getframe(gcf);
% end
% video = VideoWriter('D:\PhD\Non-Technical\T3-3_Review1_Sep2021\healthy_vs_comp.avi','MPEG-4');
% video.FrameRate = 100;
% open(video);
% writeVideo(video,F);
% close(video);


%% Save data to file
% q.labels = {'time','pelvis_tilt','pelvis_rotation','pelvis_tx','pelvis_ty','pelvis_tz','hip_flexion_r'...
%     'hip_adduction_r','hip_rotation_r','knee_angle_r','ankle_angle_r','subtalar_angle_r','mtp_angle_r'...
%     'hip_flexion_l','hip_adduction_l','hip_rotation_l','knee_angle_l','ankle_angle_l','subtalar_angle_l'...
%     'mtp_angle_l','lumbar_extension','lumbar_bending','lumbar_rotation','arm_flex_r','arm_add_r'...
%     'arm_rot_r','elbow_flex_r','pro_sup_r','wrist_flex_r','wrist_dev_r','arm_flex_l','arm_add_l'...
%     'arm_rot_l','elbow_flex_l','pro_sup_l','wrist_flex_l','wrist_dev_l'};
% q.data = [ [1:d1.length]'/10 zeros(d1.length,19) xSim(1:d1.length,:) zeros(d1.length,9)];
% write_motionFile(q,['D:\PhD\Codes\inverse_optimal_control\opensim-model\' filename 'Sim.mot']);
% fprintf('%sSim.mot successfully writen at %s.\n',filename,datetime('now'));