# Inverse Optimal Control with Suboptimality Loss
The project is an implementation of the paper **_Learning for Control: An Inverse Optimization Approach**, co-authored by Syed Adnan Akhtar, Arman Sharifi Kolarijani, and Peyman Mohajerin Esfahani at TU Delft, Netherlands. Please refer to the paper for more details

- **[Learning for Control: An Inverse Optimization Approach](https://ieeexplore.ieee.org/document/9336679)** [Paper]
- Demonstration Video (in progress)

The repo has been tested to be working on MATLAB 2018-2020 (Ubuntu 16.04 & Windows 10)

# Prerequisites
The code requires installation of the following 
- MOSEK - A toolbox to solve LPs, QPs, SOCPs, SDPs and MIPs. Please find more information [here](https://www.mosek.com/).
- YALMIP - A toolbox to provide an interfact to the solver. Please find more information [here](https://yalmip.github.io/).
- MATLAB.

# How-to
This section explains how to use the code to learn a quadratic cost function from a demonstration data and its constraints. The code can be readilly executed due to the presence of an example data. 

1. Clone the package locally on your computer 

   `git clone https://github.com/syedadnanakhtar/inverseLearning_subOpt`

2. Create a data object 

   `d = data(fullfile(path,filename));`
   
   where `path` and `filename` are character array of the path and filename respectively.

3.  Assign the state data `x` and the action data `u`

    `d.x = <State data>;`
   
    `d.u = <Action data>;`
   
    Note that the data must be in a row format, where each row corresponds to the data pointing to a single time instance. The dimensions of the state and action data can be conveniently checked by `d.nStates` and `d.nActions`.
   
4. Define a feature list. For eg, if you want the features to be constructed as [x x-a], where `a` is some constant vector, then use the following command

   `d.featureList = {'obj.x' 'obj.x - a'};`
   
   Note that `x` is prefixed with an `obj`. If you need more than one constant vectors in the feature list, use `a{1}`, `a{2]`...
   
5. Construct features  
   `d.constructFeatures();`
  
6. Define constraints
   The constraints are encoded in the structure `const` which has three fields: `const.M',`const.W`, and `const.L`. The constraints take the form Mu <= Wx + L. Please refer to the paper for more info. 
   
7. Learn the cost function `theta` by running the command 

   `[obj, theta] = learnCostSubOpt(d,const);`
   
   The function accepts the data object `d` and constraints `const`, and returns the total objective function value (cost), as well as the cost function `theta`.
   
 8. Forward simulate with the learned cost function
 
    `[xSeq, objective] = simulate(x0,theta,d.featureList,const,simLength,a);`
    
    where `x0` is the initial state, `simLength` is the simulated horizon. The rest of the variables have their usual meanings. 
    
    
 ## Example Dataset
 The project contains an example data of a human that is reaching for a goal object. The data has 8 joint angles of human upper body including lumbar-extension, lumbar bending, lumbar-rotation, shoulder-adduction, shoulder-rotation, shoulder-flexion, elbow-flexion, and pronation-supination.
 
 A simple kinematical state space is considered for learning : `x(t+1) = Ax(t) + Bu(t)`
 
 The dataset containts the states x (joint angles), as well as u (change in joint angles). 


# Contact and Citation

Should you come across any bug in my code or have any question, please feel free to send me an email at `syed.akhtar[at]tum[dot]de`




If you find this project helpful, please consider citing our paper.
```
@ARTICLE{9336679,
  author={Akhtar, Syed Adnan and Kolarijani, Arman Sharifi and Esfahani, Peyman Mohajerin},
  journal={IEEE Control Systems Letters}, 
  title={Learning for Control: An Inverse Optimization Approach}, 
  year={2022},
  volume={6},
  number={},
  pages={187-192},
  doi={10.1109/LCSYS.2021.3050305}}
```

