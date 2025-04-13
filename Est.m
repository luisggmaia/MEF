% Trellis structure

classdef Est < handle
    properties
        nodes (1, :) Node = Node.empty(1, 0); % Nodes of the trellis
        elems (1, :) Elem = Elem.empty(1, 0); % Elements of the trellis
    end

    properties (Access = private, Dependent)
        n_nodes
        n_elems
    end

    properties (Dependent)
        K
        F
        cst
        d
        N
    end

    methods
        function n_no = get.n_nodes(est)
            n_no = length(est.nodes);
        end

        function n_el = get.n_elems(est)
            n_el = length(est.elems);
        end
        
        function b = node_exist(est, index)
            arguments
                est
                index uint8
            end

            b = any([est.nodes.index] == index);
        end

        function create_node(est, index, co, cst, F)
            arguments
                est
                index uint8
                co Co
                cst Co = Co(false, false)
                F Co = Co(0, 0)
            end

            if ~est.node_exist(index)
                est.nodes(end + 1) = Node(index, co, cst, F);
            else
                error('Node index already exists!')
            end
        end

        function node = get_node(est, index)
            arguments
                est
                index uint8
            end

            node = est.nodes([est.nodes.index] == index);

            if isempty(node)
                error('Node index does not exist!');
            end
        end

        function delete_node(est, index)
            arguments
                est
                index uint8 % Index of the node.
            end
            
            if est.node_exist(index)
                est.nodes([est.nodes.index] == index) = [];
            else
                error('Node index does not exist!');
            end
        end

        function set_cst(est, index, constraint)
            arguments
                est
                index uint8 % Index of the node.
                constraint Co
            end

            node = est.get_node(index);
            node.cst = constraint;
        end

        function add_force(est, index, force)
            arguments
                est
                index uint8 % Index of the node.
                force Co
            end

            est.get_node(index).add_force(force);
        end

        function remove_force(est, index, force)
            arguments
                est
                index uint8 % Index of the node.
                force Co
            end

            est.get_node(index).remove_force(force);
        end

        function b = elem_exist(est, index)
            arguments
                est
                index uint8 % Index of the element.
            end

            b = any([est.elems.index] == index);
        end

        function create_elem(est, index, index_node_i, index_node_f, E, S, q)
            arguments
                est
                index uint8 % Index of the element.
                index_node_i uint8
                index_node_f uint8
                E double
                S double
                q double = 0
            end

            b_elem = est.elem_exist(index);
            b_node_i = est.node_exist(index_node_i);
            b_node_f = est.node_exist(index_node_f);
            
            if ~b_elem && b_node_i && b_node_f
                node_i = est.get_node(index_node_i);
                node_f = est.get_node(index_node_f);
                est.elems(end + 1) = Elem(index, node_i, node_f, E, S, q);
            else
                error('Element index already exists or one of the nodes does not exist!')
            end
        end

        function elem = get_elem(est, index)
            arguments
                est
                index uint8 % Index of the element.
            end
            
            elem = est.elems([est.elems.index] == index);
            
            if isempty(elem)
                error('Element index does not exist!');
            end
        end

        function delete_elem(est, index)
            arguments
                est
                index uint8 % Index of the element.
            end
            
            if est.elem_exist(index)
                est.elems([est.elems.index] == index) = [];
            else
                error('Element index does not exist!');
            end
        end

        function add_load(est, index, load)
            arguments
                est
                index uint8 % Index of the element.
                load double
            end

            est.get_elem(index).add_load(load);
        end

        function remove_load(est, index, load)
            arguments
                est
                index uint8 % Index of the element.
                load double
            end

            est.get_elem(index).remove_load(load);
        end

        function pos = get_node_pos(est, index)
            arguments
                est
                index uint8 % Index of the node.
            end

            if est.node_exist(index)
                pos = find([est.nodes.index] == index);
            else
                error('Node index does not exist!');
            end
        end

        function k = get.K(est)
            k = zeros(2*est.n_nodes, 2*est.n_nodes);

            for e = est.elems
                i = 2*est.get_node_pos(e.node_i.index) - 1;
                j = 2*est.get_node_pos(e.node_f.index) - 1;

                k([i:i + 1, j:j + 1], [i:i + 1, j:j + 1]) = k([i:i + 1, j:j + 1], [i:i + 1, j:j + 1]) + e.K_e;
            end
        end

        function f = get.F(est)
            f = zeros(2*est.n_nodes, 1);

            for n = est.nodes
                i = 2*est.get_node_pos(n.index) - 1;
                f(i:i + 1) = f(i:i + 1) + n.F.p;
            end

            for e = est.elems
                i = 2*est.get_node_pos(e.node_i.index) - 1;
                j = 2*est.get_node_pos(e.node_f.index) - 1;

                f([i:i + 1, j:j + 1]) = f([i:i + 1, j:j + 1]) + e.F_e;
            end
        end

        function constraints = get.cst(est)
            constraints = false(2*est.n_nodes, 1);

            for n = est.nodes
                i = 2*est.get_node_pos(n.index) - 1;
                constraints(i:i + 1) = n.cst.p;
            end
        end

        function dd = get.d(est)
            dd = zeros(2*est.n_nodes, 1);
            nodes_cst = 1:1:2*est.n_nodes;
            nodes_cst = nodes_cst(~est.cst);

            dd(nodes_cst) = est.K(nodes_cst, nodes_cst)\est.F(nodes_cst);
            
            for n = est.nodes
                i = 2*est.get_node_pos(n.index) - 1;
                n.d.p = dd(i:i + 1);
            end
        end

        function n = get.N(est)
            n = zeros(est.n_elems, 1);

            for e = est.elems
                n(e.index) = e.N_e;
            end
        end
    end
end


