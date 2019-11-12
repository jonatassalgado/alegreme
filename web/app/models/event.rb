class Event < ApplicationRecord

	THEMES     = ['lazer', 'saúde', 'atividade física', 'educação', 'cultura', 'alimentação', 'compras', 'cidadania', 'outlier', 'spam'].sort.freeze
	PERSONAS   = %w(aventureiro cult geek hipster praieiro underground zeen geral outlier).sort.freeze
	CATEGORIES = %w(anúncio festa curso teatro show cinema exposição feira esporte meetup hackaton palestra sarau festival brecho fórum slam protesto experiência outlier).sort.freeze
	STOPWORDS  = %w(a acerca adeus agora ainda alem algmas algo algumas alguns ali além ambas ambos ano anos antes ao aonde aos apenas apoio apontar apos após aquela aquelas aquele aqueles aqui aquilo as assim através atrás até aí baixo bastante bem boa boas bom bons breve cada caminho catorze cedo cento certamente certeza cima cinco coisa com como comprido conhecido conselho contra contudo corrente cuja cujas cujo cujos custa cá da daquela daquelas daquele daqueles dar das de debaixo dela delas dele deles demais dentro depois desde desligado dessa dessas desse desses desta destas deste destes deve devem deverá dez dezanove dezasseis dezassete dezoito dia diante direita dispoe dispoem diversa diversas diversos diz dizem dizer do dois dos doze duas durante dá dão dúvida e ela elas ele eles em embora enquanto entao entre então era eram essa essas esse esses esta estado estamos estar estará estas estava estavam este esteja estejam estejamos estes esteve estive estivemos estiver estivera estiveram estiverem estivermos estivesse estivessem estiveste estivestes estivéramos estivéssemos estou está estás estávamos estão eu exemplo falta fará favor faz fazeis fazem fazemos fazer fazes fazia faço fez fim final foi fomos for fora foram forem forma formos fosse fossem foste fostes fui fôramos fôssemos geral grande grandes grupo ha haja hajam hajamos havemos havia hei hoje hora horas houve houvemos houver houvera houveram houverei houverem houveremos houveria houveriam houvermos houverá houverão houveríamos houvesse houvessem houvéramos houvéssemos há hão iniciar inicio ir irá isso ista iste isto já lado lhe lhes ligado local logo longe lugar lá maior maioria maiorias mais mal mas me mediante meio menor menos meses mesma mesmas mesmo mesmos meu meus mil minha minhas momento muito muitos máximo mês na nada nao naquela naquelas naquele naqueles nas nem nenhuma nessa nessas nesse nesses nesta nestas neste nestes no noite nome nos nossa nossas nosso nossos nova novas nove novo novos num numa numas nunca nuns não nível nós número o obra obrigada obrigado oitava oitavo oito onde ontem onze os ou outra outras outro outros para parece parte partir paucas pegar pela pelas pelo pelos perante perto pessoas pode podem poder poderá podia pois ponto pontos por porque porquê portanto posição possivelmente posso possível pouca pouco poucos povo primeira primeiras primeiro primeiros promeiro propios proprio própria próprias próprio próprios próxima próximas próximo próximos puderam pôde põe põem quais qual qualquer quando quanto quarta quarto quatro que quem quer quereis querem queremas queres quero questão quieto quinta quinto quinze quáis quê relação sabe sabem saber se segunda segundo sei seis seja sejam sejamos sem sempre sendo ser serei seremos seria seriam será serão seríamos sete seu seus sexta sexto sim sistema sob sobre sois somente somos sou sua suas são sétima sétimo só tal talvez tambem também tanta tantas tanto tarde te tem temos tempo tendes tenha tenham tenhamos tenho tens tentar tentaram tente tentei ter terceira terceiro terei teremos teria teriam terá terão teríamos teu teus teve tinha tinham tipo tive tivemos tiver tivera tiveram tiverem tivermos tivesse tivessem tiveste tivestes tivéramos tivéssemos toda todas todo todos trabalhar trabalho treze três tu tua tuas tudo tão tém têm tínhamos um uma umas uns usa usar vai vais valor veja vem vens ver verdade verdadeiro vez vezes viagem vindo vinte você vocês vos vossa vossas vosso vossos vários vão vêm vós zero à às área é éramos és último).freeze

	extend FriendlyId
	friendly_id :slug_candidates, use: :slugged

	def slug_candidates
		[
				[:details_name, :categories_primary_name],
				[:details_name, :place_details_name, :categories_primary_name],
				[:details_name, :place_details_name, :categories_primary_name, :first_day_time]
		]
	end

	include ImageUploader::Attachment.new(:image)
	include Rails.application.routes.url_helpers

	include EventDecorators::Details
	include EventDecorators::Geographic
	include EventDecorators::Ocurrences
	include EventDecorators::Theme
	include EventDecorators::Personas
	include EventDecorators::Categories
	include EventDecorators::Tags
	include EventDecorators::Kinds
	include EventDecorators::MLData
	include EventDecorators::LDJson

	include EventQueries::Scopes

	acts_as_followable

	# validate :validate_attrs_that_should_be_a_hash
	# validate :validate_attrs_that_should_be_a_array

	# after_save :reindex, if: proc { |event| event.details_changed? }
	# after_destroy :reindex, :destroy_entries

	belongs_to :place
	has_and_belongs_to_many :organizers
	has_and_belongs_to_many :categories
	# has_and_belongs_to_many :kinds

	accepts_nested_attributes_for :place, :organizers

	# delegate :details_name, to: :place, prefix: true, allow_nil: true

	searchkick(word:        [:name, :description, :category, :place, :organizers],
	           word_start:  [:name, :place, :organizers],
	           word_end:    [:name, :place, :organizers],
	           word_middle: [:name, :place, :organizers],
	           text_start:  [:name],
	           text_middle: [:name],
	           text_end:    [:name],
	           suggest:     [:name],
	           callbacks:   false,
	           language:    'portuguese',
	           highlight:   %i[name],
	           batch_size:  100)

	def search_data
		{
				name:        details_name,
				description: ml_data_cleanned,
				category:    categories_primary_name,
				place:       place_details_name,
				organizers:  organizers.map(&:details_name)
		}
	end

	def ml_data_all
		nouns = ml_data['nouns']
		verbs = ml_data['verbs']
		adjs  = ml_data['adjs']

		nouns.union(verbs, adjs)
	end


	def cover_url(type = :list)
		image[type].url if image && image[type].exists?
	end

	def url
		event_path(self)
	end

	def first_day_time
		ocurrences['dates'].first
	end


	def datetimes
		datetimes = []

		ocurrences['dates'].each_with_index do |date, _index|
			datetimes << DateTime.parse(date).strftime('%Y-%m-%d %H:%M:%S')
		end

		datetimes
	end


	private

	def destroy_entries
		users = User.where id: saved_by

		users.each do |user|
			user.taste['events']['saved'].delete id
			user.taste['events']['total_saves'] -= 1
		end
	end

end
