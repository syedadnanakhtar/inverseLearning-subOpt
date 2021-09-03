%Class definition of the class data
classdef data < handle
    properties (Access = public)
        filename
        x%states
        u%Output of algorithm/System inputs/actions
        phi%features
        featureList%Description of features
        length
        nFeatures
        nStates%number of states x
        nActions%number of actions u 
        goalPose%Joint angles at the goal issues
        goalObj%3D coordinates of the goal obj
        end_eff%3D coordinates of the end eff
        startidx
        endidx
    end

    methods
        %Contructor
        function obj = data(a,startidx,endidx)
            obj.filename = a;
            q = read_motionFile(a);
            obj.x =q.data(1:end-1,[21:28]);
            obj.u = q.data(2:end,21:28) - q.data(1:end-1,21:28);
            if startidx ~= -1
                obj.x = obj.x(startidx:end,:);
                obj.u = obj.u(startidx:end,:);
            end
            if endidx ~= -1
                obj.x = obj.x(1:endidx,:);
                obj.u = obj.u(1:endidx,:);
            end        
 
        end        
        %Function to construct features
        function [obj] = constructFeatures(obj)
            %function to construct features
            n = size(obj.featureList,2);
            obj.phi = [];
            for i=1:n
                obj.phi = [obj.phi eval(obj.featureList{i})];
            end
        end
        
        %Append data
        function obj = append(obj,obj2)
            obj.x = [obj.x;obj2.x];
            obj.u = [obj.u;obj2.u];
            obj.phi = [obj.phi;obj2.phi]; 
            fprintf('Successfully appended %s\n',obj2.filename);
        end
    end
        methods   
        %Getter functions
        function val = get.goalObj(obj)
            q = read_motionFile(obj.filename);
            idx = find(strcmp(q.labels,'goal_tx'));
            val = q.data(50,idx:idx+2);

        end
        function val = get.goalPose(obj)
            val = obj.x(end,:);   
        end
        function val = get.length(obj)
            val = size(obj.x,1);
        end
        function val = get.nStates(obj)
            val = size(obj.x,2);
        end
        function val = get.nFeatures(obj)
            val = size(obj.phi,2);
        end
        function val = get.nActions(obj)
            val = size(obj.u,2);
        end
        function val = get.end_eff(obj)
            q = read_motionFile(obj.filename);
            idx = find(strcmp(q.labels,'end_eff_tx'));
            val = q.data(1:obj.length,idx:idx+2);
        end      
    end
end