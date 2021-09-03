function [phi,x, objective] = simulate(d,theta)

ops = sdpsettings('verbose',0,'solver','mosek');
n_in = d.nFeatures;%dim of algorithm-input data sample
n_out = d.nActions;
theta_xu = theta(1:n_in,n_in+1:end);
theta_ux = theta(n_in+1:end,1:n_in);
theta_uu = theta(n_in+1:end,n_in+1:end);
theta_uu = (theta_uu+theta_uu')/2;
const.W = zeros(1,d.nStates);const.L = 0;const.M = 0;
objective = zeros(d.length,1);
phi = d.phi(1,:);
featureList{1} = replace(d.featureList{1},'obj.','');
featureList{2} = replace(d.featureList{2},'obj.','');
goalPose = d.goalPose;

for i=1:d.length
    %Calculate the one-step prediction optimal input using YALMIP
    u = sdpvar(n_out,1);
    
    %Constraints
    con = [-5*ones(n_out,1)<= u <= 5*ones(n_out,1)];
    %con = [con, const.M*u <= const.W*phi(end,1:d.nStates)' + const.L];
    
    %Objective function    
    obj = u'*theta_uu*u+ phi(end,:)*(theta_xu+theta_ux')*u;
    
    %Check if there is any error
    diag = optimize( con , obj, ops);
    if diag.problem ~= 0
        fprintf('Suboptimal Input Optimization unsuccessful! [Error Code:%d]\n',diag.problem);
    end
    
    %Update the state by taking the optimal action
    x = phi(end,1:d.nStates) + value(u)';
    
    %Construct features
   
    %Get coordinates of end-effector 
    end_eff = getEndEffCoord(x);
    
    phiTemp = [];
    for i=1:size(featureList,2)
        phiTemp = [phiTemp eval(featureList{i})];
    end
%     phi = [phi; xNew end_eff-d.goalObj];
    phi = [phi;phiTemp];

    %Stage cost
    objective(i) = value(obj);
end
x = phi(:,1:d.nStates);
fprintf('Successfully simulated motion with the learned cost function.\n');
end