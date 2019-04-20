class EventSearch < Lupa::Search
    class Scope
        def categories
            scope.where("(categories -> 'primary' ->> 'name') IN (?)", search_attributes[:categories])   
        end

        def personas
            scope.where("(personas -> 'primary' ->> 'name') IN (?)", search_attributes[:personas])   
        end
    end
end