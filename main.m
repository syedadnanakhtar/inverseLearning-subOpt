%Main script to load data and perform inverse learning with suboptimality
%loss

%Setup paths and files
path = 'D:\invLearning\';
filename = 'RM2_Healthy_0001.csv';

%Read a file
dat = readtable(fullfile(path,filename));

%Create a data object
d = data( fullfile(path,filename));

%Define the states(x) and the action(u)
d.x = [dat.lumbar_extension	dat.lumbar_bending dat.lumbar_rotation dat.arm_flex_r dat.arm_add_r...
    dat.arm_rot_r dat.elbow_flex_r dat.pro_sup_r];
d.u = [dat.u_lumbar_extension	dat.u_lumbar_bending dat.u_lumbar_rotation...
    dat.u_arm_flex_r dat.u_arm_add_r dat.u_arm_rot_r dat.u_elbow_flex_r dat.u_pro_sup_r];

%Read the number of states and actions
d.nStates;
d.nActions;


%% Define features
d.featureList = {'obj.x','abs(obj.x)'};

%Construct features
d.constructFeatures();


%Define Constraints
const.W = zeros(1,d.nStates);const.L = 0;const.M = 0;

%Learn cost
[obj, theta] = learnCostSubOpt(d,const);
