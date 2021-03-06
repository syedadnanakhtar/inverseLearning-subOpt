%Main script to load data and perform inverse learning with suboptimality
%loss

%Setup paths and files
path = 'D:\invLearning\';
filename = 'RM1_Healthy_0001.csv';

%Read the file containing the data in a table format
dat = readtable(fullfile(path,filename));

%Create a data object
d = data(fullfile(path,filename));

%Define the states(x) and the actions(u)
d.x = [dat.lumbar_extension	dat.lumbar_bending dat.lumbar_rotation dat.arm_flex_r dat.arm_add_r...
    dat.arm_rot_r dat.elbow_flex_r dat.pro_sup_r];
d.u = [dat.u_lumbar_extension	dat.u_lumbar_bending dat.u_lumbar_rotation...
    dat.u_arm_flex_r dat.u_arm_add_r dat.u_arm_rot_r dat.u_elbow_flex_r dat.u_pro_sup_r];

%Read the number of states and actions
fprintf('The data has %d states and %d actions.\n', d.nStates, d.nActions);


%Define features
%If needed, you can add more constants in the feature list by a{2},...
%Add 'obj.' before x or u.
a{1} = d.x(end,:);%The pose of the human when the object is grasped (Constant)
d.featureList = {'obj.x','obj.x-a{1}'};


%Construct features
%If features are just a function of states and actions, then you can
%construct features with any argument: by d.constructFeatures();
d.constructFeatures(a);

%Print the number of features
fprintf('Number of constructed features is %d\n', d.nFeatures);

%Define Constraints: Mu <= Wx + L
const.M = [eye(d.nActions) ; -eye(d.nActions)];
const.W = zeros(1,d.nStates);
const.L = 5*ones(2*d.nActions,1);

%Learn quadratic cost.
[obj, theta] = learnCostSubOpt(d,const);

%Simulate with the learned cost function

%Specify the initial state
x0 = d.x(1,:);

%Specify the length of the simulation
simLength = 400;

%% Simulate the system with the learned cost
[xSeq, objective] = simulate(x0,theta,d.featureList,const,simLength,a{1});

