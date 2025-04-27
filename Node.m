% Beam node

classdef Node < handle
    properties
        index uint8 % index of the node
        co Co % Coordinates of the node (global referential)
        cst Co % Constraints of the node (global referential, (cst_x, cst_y, cst_theta))
        F_star Co % Forces and moment applied to the node (global referential, (F_x, F_y, M))
        R Co % Reaction forces and moment of the node (global referential, (R_x, R_y, M))
        k Co % Additional stiffness (e. g. by some spring) (globa referential (k_x, k_y, k_theta))
        d Co % Displacement of the node (global referential, (d_x, d_y, d_theta))
    end

    properties (Access = private)
        h = []
        t = []
    end

    properties (Dependent)
        F
    end

    methods
        function node = Node(index, co, cst, F_star, R, k)
            arguments
                index uint8
                co Co
                cst Co = Co(false, false, false)
                F_star Co = Co(0, 0, 0)
                R Co = Co(0, 0, 0)
                k Co = Co(0, 0, 0)
            end
            
            node.index = index;
            node.co = co;
            node.cst = cst;
            node.F_star = F_star;
            node.R = R;
            node.k = k;
            node.d = Co(0, 0, 0);
        end

        function set.co(node, co)
            arguments
                node
                co Co
            end

            node.co = co;
            node.update_plot( )
        end

        function set.cst(node, constraint)
            arguments
                node
                constraint Co
            end

            constraint.p = logical(constraint.p);
            node.cst = constraint;
        end

        function F = get.F(node)
            F = Co([], [], [], node.F_star.p + node.R.p);
        end
        
        function add_force(node, force)
            arguments
                node
                force Co
            end

            node.F_star.p = node.F_star.p + force.p;
        end

        function remove_force(node, force)
            arguments
                node
                force Co
            end

            node.F_star.p = node.F_star.p - force.p;
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
                xl = xlim;
                yl = ylim;
                node.t = text(node.co.x + 0.01*(xl(2) - xl(1)), node.co.y + 0.01*(yl(2) - yl(1)), num2str(node.index), 'Color', color);
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
                xl = xlim;
                yl = ylim;
                set(node.t, 'XData', node.co.x + 0.01*(xl(2) - xl(1)), 'YData', node.co.y + 0.01*(yl(2) - yl(1)));
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


