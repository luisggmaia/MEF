classdef Co < handle
    properties
        p
    end

    properties (Dependent)
        x
        y
        z
    end

    methods
        function co = Co(x, y, z, p)
            arguments
                x = []
                y = []
                z = []
                p = []
            end

            if isempty(p)
                co.p = [x; y; z];
            else
                co.p = p;
            end
        end

        function P = get.p(co)
            P = co.p;
        end
        function set.p(co, p)
            co.p = p;
        end

        function X = get.x(co)
            X = co.p(1);
        end
        function set.x(co, x)
            co.p(1) = x;
        end

        function Y = get.y(co)
            Y = co.p(2);
        end
        function set.y(co, y)
            co.p(2) = y;
        end
        
        function Z = get.z(co)
            Z = co.p(3);
        end
        function set.z(co, z)
            co.p(3) = z;
        end
    end
end


