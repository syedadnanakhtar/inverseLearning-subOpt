%Class definition of the class data
classdef data < handle
    properties
        filename
        x%states
        u%Output of algorithm/System inputs/actions
        phi%features
        featureList%Description of features
        length%Number of data points
        nFeatures%Number of features
        nStates%number of states x
        nActions%number of actions u 
    end

    methods
        %Contructor
        function obj = data(a)
            obj.filename = a;    
        end        
        
        %Function to construct features
        function [obj] = constructFeatures(obj,a)
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
    end
end