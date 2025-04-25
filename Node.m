% Beam node

classdef Node < handle
    properties
        index uint8 % index of the node
        co Co % Coordinates of the node (global referential)
        cst Co % Constraints of the node (global referential, (cst_x, cst_y, cst_theta))
        F Co % Forces and moment applied to the node (global referential, (F_x, F_y, M))
        d Co % Displacement of the node (global referential, (d_x, d_y, d_theta))
    end

    properties (Access = private)
        h = []
        t = []
    end

    methods
        function node = Node(index, co, cst, F)
            arguments
                index uint8
                co Co
                cst Co = Co(false, false, false)
                F Co = Co(0, 0, 0)
            end
            
            node.index = index;
            node.co = co;
            node.cst = cst;
            node.F = F;
            node.d = Co(0, 0, 0);
        end

        function set.co(node, co)
            node.co = co;
            node.update_plot( )
        end

        function set.cst(node, constraint)
            constraint.p = logical(constraint.p);
            node.cst = constraint;
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

        function plot(node, color)
            arguments
                node
                color string = 'black'
            end

            if isempty(node.h)
                node.h = plot(node.co.x, node.co.y, '.', 'Color', color, 'MarkerSize', 15);
            else
                set(node.h, 'Color', color);
            end
            if isempty(node.t)
                node.t = text(node.co.x, node.co.y, num2str(node.index));
            else
                set(node.t, 'Color', color);
            end
        end

        function update_plot(node)
            arguments
                node
            end

            if ~isempty(node.h)
                set(node.h, 'XData', node.co.x, 'YData', node.co.y);
            end
            if ~isempty(node.t)
                set(node.t, 'XData', node.co.x, 'YData', node.co.y);
            end
        end

        function unplot(node)
            arguments
                node
            end

            delete(node.h);
            delete(node.t);
        end
    end
end


