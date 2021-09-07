import numpy as np

from func import Data
from func import learnCostSubOpt

if __name__ == '__main__':

    # State data
    x = np.array([[1, 2, 3, 4, 5],
                  [0, 4, 3, 7, 1]])

    # Actions data
    u = np.array([[6, 5, 4, 3, 2],
                  [4, 5, 7, 2, 4]])

    # Define data object
    d = Data(x, u)

    # Define feature list. Prefix x and u with self
    d.featureList = np.array(['self.x', 'self.x-self.u'])

    # Construct Features
    d.constructFeatures()

    # Learn the cost function
    theta = learnCostSubOpt(x, u)


