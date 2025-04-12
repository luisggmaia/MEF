% Trellis structure

classdef Est
    properties
        nodes (1, :) Node % Nodes of the trellis
        elems (1, :) Elem % Elements of the trellis
    end

    properties (Access = private, Dependent)
        n_nodes
        n_elems
    end

    properties (Dependent)
        K
        F
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

            b = all(~([est.nodes.index] == index));
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
                index uint8
            end
            
            if est.node_exist(index)
                est.nodes([est.nodes.index] == index) = [];
            else
                error('Node index does not exist!');
            end
        end

        function add_force(est, index, force)
            arguments
                est
                index uint8
                force Co
            end

            est.get_node(index).add_force(force);
        end

        function remove_force(est, index, force)
            arguments
                est
                index uint8
                force Co
            end

            est.get_node(index).remove_force(force);
        end

        function b = elem_exist(est, index)
            arguments
                est
                index uint8
            end

            b = all(~([est.elems.index] == index));
        end

        function create_elem(est, index, index_node_i, index_node_f, E, S, q)
            arguments
                est
                index uint8
                index_node_i uint8
                index_node_f uint8
                E double
                S double
                q double
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
                index uint8
            end
            
            elem = est.elems([est.elems.index] == index);
            
            if isempty(elem)
                error('Element index does not exist!');
            end
        end

        function delete_elem(est, index)
            arguments
                est
                index uint8
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
                index uint8
                load double
            end

            est.get_elem(index).add_load(load);
        end

        function remove_load(est, index, load)
            arguments
                est
                index uint8
                load double
            end

            est.get_elem(index).remove_load(load);
        end

        function k = get.K(Est)

        end
    end
end


