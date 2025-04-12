% Trellis element

classdef Elem < handle
    properties
        index uint8 % index of the element
        node_i Node % first node of the element
        node_f Node % second node of the element
        q double % Element load. Positive, if acting in the same direction as the element (i -> f)
        E double % Element modulus of elasticity
        S double % Element cross-sectional area
    end

    properties (Dependent)
        L_e
        s
        c
        R_e
        K_e
        F_e
    end

    methods
        function elem = Elem(index, node_i, node_f, E, S, q)
            arguments
                index uint8
                node_i Node
                node_f Node
                E double
                S double 
                q double = 0
            end
            
            elem.index = index;
            elem.node_i = node_i;
            elem.node_f = node_f;
            elem.E = E;
            elem.S = S;
            elem.q = q;
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

            r_e = [coss, -sinn, 0, 0;
                   sinn, coss, 0, 0;
                   0, 0, coss, -sinn;
                   0, 0, sinn, coss];
        end

        function k_e = get.K_e(elem)
            sinn = elem.s;
            coss = elem.c;

            k_e = elem.E*elem.S/elem.L_e*[coss^2, coss*sinn, -coss^2, -coss*sinn;
                                       coss*sinn, sinn^2, -coss*sinn, -sinn^2;
                                       -coss^2, -coss*sinn, coss^2, coss*sinn;
                                       -coss*sinn, -sinn^2, coss*sinn, sinn^2];
        end

        function f_e = get.F_e(elem)
            sinn = elem.s;
            coss = elem.c;

            f_e = elem.q*elem.L_e/2*[coss; sinn; coss; sinn];
        end

        function add_load(elem, load)
            arguments
                elem
                load double
            end

            elem.q = elem.q + load;
        end

        function remove_load(elem, load)
            arguments
                elem
                load double
            end

            elem.q = elem.q - load;
        end
        
        function d = global_displacement(elem, t)
            arguments
                elem
                t double % 0 < t < 1
            end

            d = Co(elem.node_i.d.x + (elem.node_f.d.x - elem.node_i.d.x)*t, elem.node_i.d.y + (elem.node_f.d.y - elem.node_i.d.y)*t);
        end

        function d = local_displacement(elem, t)
            arguments
                elem
                t double % 0 < t < 1
            end
            
            d = Co(elem.node_i.d + (elem.node_f.d - elem.node_i.d)*t;
        end
    end
end


