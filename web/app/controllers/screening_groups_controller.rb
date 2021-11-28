class ScreeningGroupsController < ApplicationController
	before_action :set_screening_group, only: [:like]

	include ActionView::RecordIdentifier

	def like
		if current_user
			begin
				if current_user.like? @screening_group
					current_user.unlike! @screening_group
				elsif current_user.dislike? @screening_group
					current_user.like! @screening_group, action: :update
				else
					current_user.like! @screening_group
				end
			rescue
				show_modal 'Lá se foi sua cota', 'Você só pode salvar 2 sessões por filme. Vamos manter as coisas simples por aqui 😜'
			else
				render turbo_stream: turbo_stream.replace(dom_id(@screening_group),
																									partial: 'movies/screening_group',
																									locals:  {
																										screening_group: @screening_group,
																										user:            current_user
																									})
			end
		else
			render turbo_stream: turbo_stream.replace('modal',
																								partial: 'layouts/modal',
																								locals:  {
																									title:  'Você precisa estar logado',
																									text:   'Crie uma conta para salvar seus filmes favoritos e receber recomendações únicas 🤙',
																									action: 'create-account',
																									opened: true })
		end
	end

	private

	# Use callbacks to share common setup or constraints between actions.
	def set_screening_group
		@screening_group = ScreeningGroup.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def screening_params
		params.require(:screening_group).permit()
	end

	def show_modal(title, text, action = nil)
		render turbo_stream: turbo_stream.replace('modal',
																							partial: 'layouts/modal',
																							locals:  {
																								title:  title,
																								text:   text,
																								action: action,
																								opened: true })
	end

end
