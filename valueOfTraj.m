function [objective,cumulativeCost] = valueOfTraj(d,theta)

objective = zeros(d.length,1);
cumulativeCost = zeros(d.length,1);

for  i = 1:d.length
    objective(i) = [d.phi(i,:) d.u(i,:)] * theta * [d.phi(i,:) d.u(i,:)]';
    if i>1
        cumulativeCost(i) = cumulativeCost(i-1) + objective(i);
    else
        cumulativeCost(i) = objective(i);
    end
end
end