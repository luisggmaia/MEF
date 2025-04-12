% Trellis node

classdef Node < handle
    properties
        index uint8 % index of the node
        co Co % Coordinates of the node
        cst Co % Constraints of the node
        F Co % Forces applied to the node
        d Co % Displacement of the node (global referential)
    end

    methods
        function node = Node(index, co, cst, F)
            arguments
                index uint8
                co Co
                cst Co = Co(false, false)
                F Co = Co(0, 0)
            end
            
            node.index = index;
            node.co = co;
            node.cst = cst;
            node.F = F;
        end

        function set.cst(node, constraint)
            node.cst.x = logical(constraint.x);
            node.cst.y = logical(constraint.y);
        end
        
        function add_force(node, force)
            arguments
                node
                force Co
            end

            node.F.p = node.F.p + force.p;
        end

        function remove_force(node, force)
            arguments
                node
                force Co
            end

            node.F.p = node.F.p - force.p;
        end
    end
end


