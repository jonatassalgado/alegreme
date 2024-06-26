require 'test_helper'

class FeedsControllerTest < ActionDispatch::IntegrationTest
	def setup
		@user = create(:user)
		sign_in @user
	end

	test "should get index with personas events" do
		Timecop.freeze('2019-05-28 12:00:00')

		@event = create(:event, {
				ocurrences: {
						'dates': ['2019-05-28 12:00:00']
				}
		})

		get feed_url

		assert_response :success, 'should open feed with success'
		assert_match 'Eventos e atividades em Porto Alegre', @response.body, 'should render onboarding component'
		assert_match 'Eventos acontecendo hoje e amanhã', @response.body, 'should render today and tomorrow section'
		assert_match 'Serenata Iluminada', @response.body, 'should load one event'
		assert_match 'Explore os eventos que pessoas com gostos parecidos estão salvando', @response.body, 'should render user personas section'
	end

	test "should get index without personas events" do
		Timecop.freeze('2019-05-28 12:00:00')

		@event = create(:event, details: {
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

		get feed_url

		assert_response :success, 'should open feed with success'
		assert_match 'Eventos e atividades em Porto Alegre', @response.body, 'should render onboarding component'
		assert_match 'Eventos acontecendo hoje e amanhã', @response.body, 'should render today and tomorrow section'
		refute_match 'Serenata Iluminada', @response.body, 'should not load events'
		assert_match 'Explore os eventos que pessoas com gostos parecidos estão salvando', @response.body, 'should render user personas section'
	end


end
