% Beam element

classdef Elem < handle
    properties
        index uint8 % index of the element
        node_i Node % first node of the element
        node_f Node % second node of the element
        E double % Element modulus of elasticity
        S double % Element cross-sectional area
        I double % Element moment of inertia
        q double % Element load. Positive, if acting in the same direction as the element (i -> f)
        p double % Element orthogonal load.
    end

    properties (Dependent)
        L_e
        s
        c
        R_e
        K_e % Global
        F_e % Global
        N_e
    end

    properties (Access = private)
        h
        t
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
                q double = 0
                p double = 0
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

            f_e = r_e*[Q*l_e/2; P*l_e/2; P*l_e^2/12; Q*l_e/2; P*l_e/2; -P*l_e^2/12];
        end

        function n_e = get.N_e(elem)
            n_e = elem.E*elem.S/elem.L_e*(elem.c*(elem.node_f.d.x - elem.node_i.d.x) + elem.s*(elem.node_f.d.y - elem.node_i.d.y));
        end

        function add_q_load(elem, load)
            arguments
                elem
                load double
            end

            elem.q = elem.q + load;
        end

        function add_p_load(elem, load)
            arguments
                elem
                load double
            end

            elem.p = elem.p + load;
        end

        function remove_q_load(elem, load)
            arguments
                elem
                load double
            end

            elem.q = elem.q - load;
        end

        function remove_p_load(elem, load)
            arguments
                elem
                load double
            end

            elem.p = elem.p - load;
        end

        function d = global_displacement(elem, t) % Ajeitar
            arguments
                elem
                t double % 0 < t < 1
            end

            d = Co(elem.node_i.d.p + (elem.node_f.d.p - elem.node_i.d.p)*t);
        end

        function d = local_displacement(elem, t) % Ajeitar
            arguments
                elem
                t double % 0 < t < 1
            end
            
            d = Co(transpose(elem.R_e)*(elem.node_i.d.p + (elem.node_f.d.p - elem.node_i.d.p)*t));
        end

        function plot(elem, color)
            arguments
                elem
                color string
            end

            x = [elem.node_i.co.x, elem.node_f.co.x];
            y = [elem.node_i.co.y, elem.node_f.co.y];

            elem.h = plot(x, y, '-', 'Color', color);
            elem.t = text(sum(x)/2, sum(y)/2, num2str(elem.index));
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


