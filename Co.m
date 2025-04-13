classdef Co < handle
    properties (Access = private)
        xx
        yy
    end

    properties (Dependent)
        x
        y
        p
    end

    methods
        function co = Co(x, y, p)
            arguments
                x = []
                y = []
                p (2, :) = []
            end

            if isempty(p)
                co.xx = x;
                co.yy = y;    
            else
                co.xx = p(1);
                co.yy = p(2);
            end
        end

        function P = get.p(co)
            P = [co.xx; co.yy];
        end
        function set.p(co, p)
            co.xx = p(1);
            co.yy = p(2);
        end

        function X = get.x(co)
            X = co.xx;
        end
        function set.x(co, x)
            co.xx = x;
        end

        function Y = get.y(co)
            Y = co.yy;
        end
        function set.y(co, y)
            co.yy = y;
        end
    end
end