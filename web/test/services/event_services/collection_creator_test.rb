require 'test_helper'
require_relative '../../../app/services/event_services/collection_creator'
require_relative '../../../app/services/event_services/event_fetcher'

class CollectionCreatorTest < ActiveSupport::TestCase
	def setup
		@user = create(:user)
	end

	test 'should return collection of today events' do
		Timecop.freeze('2019-05-28 12:00:00')

		create(:event, ocurrences: {
				'dates': ['2019-05-28 12:00:00']
		})
		create(:event, ocurrences: {
				'dates': ['2019-05-29 12:00:00']
		})
		create(:event, ocurrences: {
				'dates': ['2019-05-30 12:00:00']
		})

		collection = EventServices::CollectionCreator.new(@user)
		assert_equal 2, collection.call('today-and-tomorrow')[:events].count, 'should return 2 events'
	end


	test 'should return collection of personas events' do
		in_persona          = create(:event, ml_data: {
				personas: {
						'outlier':   false,
						'primary':   {
								'name':  'hipster',
								'score': '0.996777',
						},
						'secondary': {
								'name':  'zeen',
								'score': '0.003223',
						}
				}
		})
		not_in_user_persona = create(:event, ml_data: {
				personas: {
						'outlier':   false,
						'primary':   {
								'name':  'geek',
								'score': '0.996777',
						},
						'secondary': {
								'name':  'zeen',
								'score': '0.003223',
						}
				}
		})
		category = create(:category)
		in_persona.categories << category


		collection = EventServices::CollectionCreator.new(@user)

		assert_includes collection.call('user-personas')[:events], in_persona, 'should return events with same user persona'
		refute_includes collection.call('user-personas')[:events], not_in_user_persona, 'should not return events without user persona'
		refute_equal [], collection.call('user-personas')[:ocurrences], 'should return ocurrences of events filtered'
		refute_equal [], collection.call('user-personas')[:categories], 'should return categories of events filtered'
		refute_equal [], collection.call('user-personas')[:kinds], 'should return kinds of events filtered'
	end

	test 'should return collection of personas events limited by 1' do
		create(:event, ml_data: {
				personas: {
						'outlier':   false,
						'primary':   {
								'name':  'hipster',
								'score': '0.996777',
						},
						'secondary': {
								'name':  'zeen',
								'score': '0.003223',
						}
				}
		})
		create(:event, ml_data: {
				personas: {
						'outlier':   false,
						'primary':   {
								'name':  'hipster',
								'score': '0.996777',
						},
						'secondary': {
								'name':  'zeen',
								'score': '0.003223',
						}
				}
		})

		collection = EventServices::CollectionCreator.new(@user)
		assert_equal 1, collection.call('user-personas', limit: 1)[:events].count
	end

	test 'should return collection of events filterd in 2019-05-29 ocurrence' do
		Timecop.freeze('2019-05-28 12:00:00')

		create(:event, ocurrences: {
				'dates': ['2019-05-28 12:00:00']
		})
		create(:event, ocurrences: {
				'dates': ['2019-05-29 12:00:00']
		})
		create(:event, ocurrences: {
				'dates': ['2019-05-30 12:00:00']
		})

		collection = EventServices::CollectionCreator.new(@user)

		assert_equal 1, collection.call('user-personas', ocurrences: ['2019-05-29'])[:events].count, 'should return 1 event'
		assert_equal 2, collection.call('user-personas', ocurrences: ['2019-05-29', '2019-05-30'])[:events].count, 'should return 2 events'
	end

	test 'should return all ocurrences filter of active events' do
		Timecop.freeze('2019-05-28 12:00:00')

		create(:event, ocurrences: {
				'dates': ['2019-05-28 12:00:00']
		})
		create(:event, ocurrences: {
				'dates': ['2019-05-29 12:00:00']
		})
		create(:event, ocurrences: {
				'dates': ['2019-05-30 12:00:00']
		})

		collection = EventServices::CollectionCreator.new(@user)

		assert_equal 3, collection.call('user-personas', ocurrences: ['2019-05-29'], limit: 1, all_existing_filters: true)[:ocurrences].count, 'should return 3 ocurrences'
		assert_equal 1, collection.call('user-personas', ocurrences: ['2019-05-29'], limit: 1, all_existing_filters: false)[:ocurrences].count, 'should return 1 ocurrence'
	end
end
