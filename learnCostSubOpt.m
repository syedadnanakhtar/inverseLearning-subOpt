function [obj,thetaInv] = learnCostSubOpt(dat,const)

    %dat has the following fields
    %dat.x: the states of the system in row format
    %dat.u: the optimal input in row format
    n = dat.length;
    n_in = dat.nFeatures;%dimension of algorithm-input data sample
    n_out = dat.nActions;%dimension of algorithm-output data sample
    theta_uu = sdpvar(n_out,n_out,'symmetric');
    theta_xu = sdpvar(n_in,n_out);
    lambda = sdpvar(n,size(const.M,1));
    gamma = sdpvar(n,1);
    ops = sdpsettings('verbose',0,'solver','mosek');
    obj = 0;
    cnst = [];
    fprintf('%d datatpoints are found.\nIOC with suboptimality loss initiated...\n',n);

    for i=1:n
        obj= obj + 2*(dat.phi(i,:)) * theta_xu * (dat.u(i,:)') + ...
            (dat.u(i,:)) * theta_uu * (dat.u(i,:)');
        obj = obj + 0.25*gamma(i) + lambda(i,:)*(const.W*dat.x(i,:)'+const.L); 
        temp = (const.M'*lambda(i,:)'+ 2*theta_xu'*(dat.phi(i,:)'));
        cnst = [cnst, [theta_uu temp; temp' gamma(i)] >= 0];
    end
    cnst = [cnst, theta_uu >= eye(n_out)];
    cnst = [cnst, lambda(:) >= 0];
    cnst = [cnst, theta_xu(:) >= -10, theta_xu(:) <= 10];
    cnst = [cnst, theta_uu(:) >= -10, theta_uu(:) <= 10];
    diag = optimize(cnst,obj,ops);
    theta_xu = value(theta_xu);
    theta_uu = value(theta_uu);
    thetaInv = [zeros(n_in,n_in) theta_xu;theta_xu' theta_uu];
    thetaInv(isnan(thetaInv))=0;
    if diag.problem ~= 0
        fprintf('Inverse Optimization unsuccessful! [Problem Code:%d]\n',diag.problem);
    else
        fprintf('Cost learned successfully! [Features: %d, Actions: %d, Theta: %dx%d]\n',...
            n_in,n_out,(n_in+n_out),(n_in+n_out));
    end
end