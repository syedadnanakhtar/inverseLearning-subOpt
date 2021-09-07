import numpy as np


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


def learnCostSubOpt(x, u):
    theta = 2
    return theta