% Beam element

classdef Elem < handle
    properties
        index uint8 % index of the element
        node_i Node % first node of the element
        node_f Node % second node of the element
        E double % Element modulus of elasticity
        S double % Element cross-sectional area
        I double % Element moment of inertia
        q function_handle % Element load. Positive, if acting in the same direction as the element (i -> f)
        p function_handle % Element orthogonal load.
    end

    properties (Dependent)
        L_e double % Length of the element
        s double % Sine of the angle between the element and the x-axis
        c double % Cosine of the angle between the element and the x-axis
        R_e % Rotation matrix
        K_e % Global stiffness matrix
        F_e % Global force vector
        d % Global displacements
        d_local % Local displacements
        u_e function_handle % Local x displacement
        v_e function_handle % Local y displacement
        theta_e function_handle % Local rotation
        N_e function_handle % Axial force in the element
        V_e function_handle % Shear force in the element
        M_e function_handle % Bending moment in the element
    end

    properties (Access = private)
        h = []
        t = []
    end

    methods
        function elem = Elem(index, node_i, node_f, E, S, I, q, p)
            arguments
                index uint8
                node_i Node
                node_f Node
                E double
                S double
                I double
                q function_handle = @(x) 0;
                p function_handle = @(x) 0;
            end
            
            elem.index = index;
            elem.node_i = node_i;
            elem.node_f = node_f;
            elem.E = E;
            elem.S = S;
            elem.I = I;
            elem.q = q;
            elem.p = p;
        end

        function l_e = get.L_e(elem)
            l_e = sqrt((elem.node_f.co.x - elem.node_i.co.x)^2 + (elem.node_f.co.y - elem.node_i.co.y)^2);
        end
        
        function coss = get.c(elem)
            coss = (elem.node_f.co.x - elem.node_i.co.x)/elem.L_e;
        end

        function sinn = get.s(elem)
            sinn = (elem.node_f.co.y - elem.node_i.co.y)/elem.L_e;
        end

        function r_e = get.R_e(elem)
            sinn = elem.s;
            coss = elem.c;

            r_e = [coss, -sinn, 0,    0,     0, 0;
                   sinn,  coss, 0,    0,     0, 0;
                      0,     0, 1,    0,     0, 0;
                      0,     0, 0, coss, -sinn, 0;
                      0,     0, 0, sinn,  coss, 0;
                      0,     0, 0,    0,     0, 1];
        end

        function k_e = get.K_e(elem)
            r_e = elem.R_e;
            l_e = elem.L_e;
            a = elem.S;
            e = elem.E;
            i = elem.I;

            k_e = [e*a/l_e,             0,            0, -e*a/l_e,             0,            0;
                         0,  12*e*i/l_e^3,  6*e*i/l_e^2,        0, -12*e*i/l_e^3,  6*e*i/l_e^2;
                         0,   6*e*i/l_e^2,    4*e*i/l_e,        0,  -6*e*i/l_e^2,    2*e*i/l_e;
                  -e*a/l_e,             0,            0,  e*a/l_e,             0,            0;
                         0, -12*e*i/l_e^3, -6*e*i/l_e^2,        0,  12*e*i/l_e^3, -6*e*i/l_e^2;
                         0,   6*e*i/l_e^2,    2*e*i/l_e,        0,  -6*e*i/l_e^2,   4*e*i/l_e];
            
            k_e = r_e*k_e*transpose(r_e);

        end

        function f_e = get.F_e(elem)
            Q = elem.q;
            P = elem.p;
            l_e = elem.L_e;
            r_e = elem.R_e;

            f_e = r_e*l_e*integral(@(x) [Q(l_e*x)*(1 - x); P(l_e*x)*(2*x^3 - 3*x^2 + 1); P(l_e*x)*l_e*(x^3 - 2*x^2 + x); Q(x*l_e)*x; P(l_e*x)*(-2*x^3 + 3*x^2); P(x)*l_e*(x^3 - x^2)], 0, 1, "ArrayValued", true);
        end

        function add_q_load(elem, load)
            arguments
                elem
                load function_handle
            end

            elem.q = @(x) elem.q(x) + load(x);
        end

        function add_p_load(elem, load)
            arguments
                elem
                load function_handle
            end

            elem.p = @(x) elem.p(x) + load(x);
        end

        function remove_q_load(elem, load)
            arguments
                elem
                load function_handle
            end

            elem.q = @(x) elem.q(x) - load(x);
        end

        function remove_p_load(elem, load)
            arguments
                elem
                load function_handle
            end

            elem.p = @(x) elem.p(x) - load(x);
        end

        function d = get.d(elem)
            d = [elem.node_i.d.p; elem.node_f.d.p];
        end

        function d = get.d_local(elem)
            d = transpose(elem.R_e)*elem.d;
        end

        function u = get.u_e(elem)
            d_loc = elem.d_local;
            u_1 = d_loc(1);
            u_2 = d_loc(4);

            u = @(t) u_1 + (u_2 - u_1)*t;
        end

        function v = get.v_e(elem)
            l_e = elem.L_e;
            d_loc = elem.d_local;
            v_1 = d_loc(2);
            theta_1 = d_loc(3);
            v_2 = d_loc(5);
            theta_2 = d_loc(6);

            v = @(t) v_1*(2*t^3 - 3*t^2 + 1) + theta_1*l_e*(t^3 - 2*t^2 + t) + v_2*(-2*t^3 + 3*t^2) + theta_2*l_e*(t^3 - t^2);
        end

        function theta = get.theta_e(elem)
            l_e = elem.L_e;
            d_loc = elem.d_local;
            v_1 = d_loc(2);
            theta_1 = d_loc(3);
            v_2 = d_loc(5);
            theta_2 = d_loc(6);

            theta = @(t) v_1/l_e*(6*t^2 - 6*t) + theta_1*(3*t^2 - 4*t + 1) + v_2/l_e*(-6*t^2 + 6*t) + theta_2*(3*t^2 - 2*t);
        end

        function n_e = get.N_e(elem)
            d_loc = elem.d_local;
            u_1 = d_loc(1);
            u_2 = d_loc(4);

            n_e = @(t) elem.E*elem.S/elem.L_e*(u_2 - u_1);
        end

        function v_e = get.V_e(elem)
            l_e = elem.L_e;
            d_loc = elem.d_local;
            v_1 = d_loc(2);
            theta_1 = d_loc(3);
            v_2 = d_loc(5);
            theta_2 = d_loc(6);

            v_e = @(t) elem.E*elem.I*(v_1*(12/l_e^3) + theta_1*(6/l_e^2) + v_2*(-12/l_e^3) + theta_2*(6/l_e^2));
        end

        function m_e = get.M_e(elem)
            l_e = elem.L_e;
            d_loc = elem.d_local;
            v_1 = d_loc(2);
            theta_1 = d_loc(3);
            v_2 = d_loc(5);
            theta_2 = d_loc(6);

            m_e = @(t) elem.E*elem.I*(v_1/l_e^2*(12*t - 6) + theta_1/l_e*(6*t - 4) + v_2/l_e^2*(-12*t + 6) + theta_2/l_e*(6*t - 2));
        end

        function plot(elem, color)
            arguments
                elem
                color string = 'black'
            end

            x = [elem.node_i.co.x, elem.node_f.co.x];
            y = [elem.node_i.co.y, elem.node_f.co.y];

            if isempty(elem.h)
                elem.h = plot(x, y, '-', 'Color', color, 'lineWidth', 2);
            else
                set(elem.h, 'Color', color);
            end
            if isempty(elem.t)
                xl = xlim;
                yl = ylim;
                elem.t = text(sum(x)/2 + 0.01*(xl(2) - xl(1)), sum(y)/2 + 0.01*(yl(2) - yl(1)), num2str(elem.index), 'Color', color);
            else
                set(elem.t, 'Color', color);
            end
        end

        function update_plot(node)
            arguments
                node
            end

            x = [node.node_i.co.x, node.node_f.co.x];
            y = [node.node_i.co.y, node.node_f.co.y];

            if ~isempty(node.h)
                set(node.h, 'XData', x, 'YData', y);
            end
            if ~isempty(node.t)
                xl = xlim;
                yl = ylim;
                node.t = text(sum(x)/2 + 0.01*(xl(2) - xl(1)), sum(y)/2 + 0.01*(yl(2) - yl(1)), num2str(node.index));
            end
        end

        function unplot(elem)
            arguments
                elem
            end

            delete(elem.h);
            delete(elem.t);
        end
    end
end


