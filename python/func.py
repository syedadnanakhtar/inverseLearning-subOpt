import numpy as np
import mosek
import sys
import cvxpy as cp

inf = 0.0


class Data:
    def __init__(self, x, u):
        self.x = np.array(x)
        self.u = np.array(u)
        self.phi = None
        self.featureList = None

    def constructFeatures(self):
        self.phi = np.array(eval(self.featureList[0]))
        for i in range(1, self.featureList.size,1):
            temp = np.array(eval(self.featureList[i]))
            self.phi = np.append(self.phi, temp, axis=1)

    def nStates(self):
        return self.x.size

    def nActions(self):
        return self.u.size

    def nFeatures(self):
        return self.phi.size


def streamprinter(text):
    sys.stdout.write(text)
    sys.stdout.flush()


def learnCostSubOpt(x, u):
    x = x[0, :]
    u = u[0, :]

    nStates = x.shape[1]
    nActions = u.shape[1]
    
    # Define optimization variables
    theta_uu = cp.Variable((nActions, nActions), symmetric=True)
    theta_xu = cp.Variable((nStates, nActions), symmetric=True)
    lambda_t = cp.Variable((2, 1))

    # Define contraint matrices
    M = np.matrix([[1, 0, 0, 0, 0], [0, -1, 0, 0, 0]])
    W = np.matrix([[5], [5]])

    # Define constraints
    constraints = [theta_uu >> np.eye(nActions), lambda_t >= 0]

    # Construct the objective function
    obj = cp.quad_form(x.T, theta_uu) + 2 * x @ theta_xu @ u.T
    obj = obj + W.T @ lambda_t
    obj = obj + cp.matrix_frac(M.T @ lambda_t + 2 * x @ theta_xu @ u.T, theta_uu)

    # Define the problems
    prob = cp.Problem(cp.Minimize(obj), constraints)

    # Solve the problem
    prob.solve()

    # Return the value of theta
    theta = np.array([[np.zeros((nStates, nStates))], [theta_xu.value],
                      [theta_xu.value.T], [theta_uu.value]])

    theta = np.concatenate((np.zeros((nStates, nStates)), theta_xu.value), axis=1)
    theta = np.concatenate((theta, np.concatenate((theta_xu.value.T, theta_uu.value), axis=1)), axis=0)

    return theta
