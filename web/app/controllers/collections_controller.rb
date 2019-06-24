class CollectionsController < ApplicationController

  def index
    @collections ||= EventServices::CollectionCreator.new(current_or_guest_user, params)
    response = params[:identifier]


    send "#{response.underscore}"

  end


  private

  def today_and_tomorrow
    @items = @collections.call('today-and-tomorrow')
    @locals = {
        items: @items,
        titles: {
            principal: "Eventos acontecendo hoje e amanhã"
        },
        identifier: 'today-and-tomorrow',
        type: :large,
        filters: {
            categories: true,
            kinds: true
        }
    }

    respond_with_js
  end


  def cinema
    @items = @collections.events_for_cinema(group_by: 10)
    @locals = {
        items: @items,
        titles: {
            principal: "Cinema nesta semana"
        },
        identifier: 'cinema',
        type: :large,
        filters: {
            ocurrences: true
        }
    }


    respond_with_js
  end

  def show_and_party
    @items = @collections.events_for_show_and_party(group_by: 5)
    @locals = {
        items: @items,
        titles: {
            principal: "Shows e festa no mês"
        },
        identifier: 'show-and-party',
        type: :large,
        filters: {
            ocurrences: true
        }
    }


    respond_with_js
  end

  def user_personas
    Rails.cache.fetch("#{current_or_guest_user}_user_personas", expires_in: 1.hour) do
      @items = @collections.call('user-personas', all_existing_filters: true)
    end

    @locals = {
        items: @items,
        titles: {
            principal: "Indicados para você no mês"
        },
        identifier: 'user-personas',
        type: :large,
        filters: {
            ocurrences: true,
            kinds: true,
            categories: true
        }
    }

    respond_with_js
  end

  def respond_with_js
    respond_to do |format|
      format.js {render 'index'}
    end
  end

end
