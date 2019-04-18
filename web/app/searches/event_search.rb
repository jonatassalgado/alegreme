class EventSearch < Lupa::Search
    class Scope
        def categories
            scope.where("(categories -> 'primary' ->> 'name') IN (?)", search_attributes[:categories])   
        end
    end
end