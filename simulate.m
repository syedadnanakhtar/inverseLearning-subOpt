function [xSeq, objective] = simulate(x,theta,featureList,const,len,varargin)

    ops = sdpsettings('verbose',0,'solver','mosek');
    for i=1:nargin-5
        a{i} = varargin{i};
    end
    
    nStates = size(x,2);
    nFeatures = 0;
    for i=1:size(featureList,2)
        featureList{i} = replace(featureList{i},'obj.','');
        nFeatures = nFeatures + size(eval(featureList{i}),2);
    end
    nActions = size(theta,1) - nFeatures;
    
    theta_xu = theta(1:nFeatures,nFeatures+1:end);
    theta_ux = theta(nFeatures+1:end,1:nFeatures);
    theta_uu = theta(nFeatures+1:end,nFeatures+1:end);
    theta_uu = (theta_uu+theta_uu')/2;
       
    objective = zeros(len,1);
    xSeq = zeros(len,nStates);
       
    for i=1:len
        
        phi = [];
        for j=1:size(featureList,2)
            phi = [phi eval(featureList{j})];
        end
 
        %Calculate the one-step prediction optimal input using YALMIP
        u = sdpvar(nActions,1);

        %Constraints
       % con = [-5*ones(nActions,1)<= u <= 5*ones(nActions,1)];
       
        con = [const.M*u <= const.W*x' + const.L];

        %Objective function    
        obj = u'*theta_uu*u+ phi*(theta_xu+theta_ux')*u;

        %Check if there is any error
        diag = optimize( con , obj, ops);
        if diag.problem ~= 0
            fprintf('Suboptimal Input Optimization unsuccessful! [Error Code:%d]\n',diag.problem);
        end

        %Update the state by taking the optimal action
        x = x + value(u)';
        xSeq(i,:) = x;

        %Stage cost
        objective(i) = value(obj);
    end
    fprintf('Successfully simulated trajectory with the learned cost function.\n');
end