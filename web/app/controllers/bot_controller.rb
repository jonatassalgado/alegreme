class BotController < ApplicationController
	before_action :authorize_user


	def onboarding
		gon.push({
				         :env             => Rails.env,
				         :user_id         => current_user.id,
				         :user_first_name => current_user.first_name
		         })

		@swipable_items = get_swipable_items
	end


	private

	def get_swipable_items
		[
				{
						id:             0,
						name:           "Arduino Day",
						image_url:      "bot/arduino-day-2019.png",
						description:    "Evento para pessoas desenvolvedoras de software que desejam aprendar mais sobre a linguagem Arduino.",
						dominant_color: "#53456a"
				},
				{
						id:             1,
						name:           "Festa HOT",
						image_url:      "bot/festa-hot-doma.png",
						description:    "A pista mais fervida de Porto Alegre, sem moralismo, sem preconceito. No som: house, disco e os hits clássicos das últimas décadas. ",
						dominant_color: "#d85e53"
				},
				{
						id:             2,
						name:           "Carnawow",
						image_url:      "bot/carnawow.jpeg",
						description:    "O Carnawow é uma síntese de celebração e meditação. São 5 dias pra abrir tua energia, tua capacidade de sentir e criar através de sessões e meditações ativas.",
						dominant_color: "#1f4728"
				},
				{
						id:             3,
						name:           "Bike Tour nas Ruínas das Missões",
						image_url:      "bot/bike-tour-missoes.jpeg",
						description:    "Cicloturismo em São Miguel das Missões e depois do pedal vamos relaxar na acolhedora Pousada das Missões.",
						dominant_color: "#89644f"
				},
				{
						id:             4,
						name:           "Cinema mudo com música ao vivo",
						image_url:      "bot/cine-ibere-musica-aovivo.jpeg",
						description:    "Sessão no Iberê Camargo do filme O Gabinete do Dr. Caligari, um dos filmes mais importantes da história do cinema mundial. Considerado o primeiro filme de terror.",
						dominant_color: "#0b1018"
				},
				{
						id:             5,
						name:           "Feira do Aeromovel",
						image_url:      "bot/feira-do-aeromovel.jpeg",
						description:    "A feira acontece de frente para a Orla do Guaíba, na praça do antigo Aeromovel. Um público lindo ocupando a praça, expositores de marcas locais, gastronomia, cultura, arte e cidadania.",
						dominant_color: "#203465"
				},
				{
						id:             6,
						name:           "Feira Vegana Noturna",
						image_url:      "bot/feira-vegana-noturna.jpeg",
						description:    "Feira com produtos veganos que ocorre no bairro Bom Fim durante a noite.",
						dominant_color: "#656322"
				},
				{
						id:             7,
						name:           "Madrugadão Virada Nerd",
						image_url:      "bot/virada-nerd.jpeg",
						description:    "Duas madrugadas no final de semana com pizzas e jogos de tabuleiro para se divertir com amigos.",
						dominant_color: "#344456"
				},
				{
						id:             8,
						name:           "Arruaça",
						image_url:      "bot/arruaca.jpeg",
						description:    "Festa de rua das mina, das mana e das mona. DJs gurias tocando house e techno no centro da cidade, na rua.",
						dominant_color: "#305899"
				},
				{
						id:             9,
						name:           "Mindfulness no Pôr do Sol",
						image_url:      "bot/mindfulness-por-do-sol.jpeg",
						description:    "Venha participar da meditação de Atenção Plena e desfrutar de um momento de presença e desenvolvimento de tranquilidade, contemplando nosso belo cartão postal na Orla do Guaíba.",
						dominant_color: "#8C5109"
				},
				{
						id:             10,
						name:           "Trilha da Fortaleza no Parque de Itapuã",
						image_url:      "bot/trilha-da-fortaleza.jpeg",
						description:    "Localizado a 57 km da capital, o Parque de Itapuã, protege a última amostra dos ecossistemas com campos, matas, dunas, lagoas, praias e morros às margens do lago Guaíba e da laguna dos Patos.",
						dominant_color: "#62729B"
				},
				{
						id:             11,
						name:           "Exposição Cecily Brown",
						image_url:      "bot/exposicao-cecily-brown.jpeg",
						description:    "Cecily Brown é uma das artistas de maior destaque na pintura contemporânea mundial.",
						dominant_color: "#B8741D"
				},
				{
						id:             12,
						name:           "Saint Patrick's Day",
						image_url:      "bot/patricks-day.jpeg",
						description:    "Mais de 70 Torneiras de chopp artesanal, espaços temáticos, caça ao tesouro com prêmios de vale tatto, chopp e tickets de food trucks. ",
						dominant_color: "#016481"
				},
				{
						id:             13,
						name:           "Feira Me Gusta",
						image_url:      "bot/feira-me-gusta.jpeg",
						description:    "Brechó, arte, gastronomia, música e boa convivência se encontraram sob a sombra de muitas árvores, em bancos e pelos passeios da Praça Isabel.",
						dominant_color: "#697865"
				},
				{
						id:             14,
						name:           "Hackatown Mobilidade",
						image_url:      "bot/hackatown-mobilidade.jpeg",
						description:    "Dividido em três dias imersivos, o Hackatown é um espaço de cocriação de soluções para a mobilidade urbana de Porto Alegre em participação com a prefeitura e PUCRS.",
						dominant_color: "#375261"
				},
				{
						id:             15,
						name:           "Fennda na rua",
						image_url:      "bot/fennda.jpeg",
						description:    "Festa de rua das mona, das mana e das mina. Techno, house e funk é o que toca. O dresscode é ir de nude.",
						dominant_color: "#C74191"
				},
				{
						id:             16,
						name:           "Yoga na Redenção",
						image_url:      "bot/yoga-redencao.jpeg",
						description:    "Qualquer pessoa pode participar, não importa a idade, sexo, peso do corpo, crença ou religião, basta a vontade de praticar.",
						dominant_color: "#6C833C"
				},
				{
						id:             17,
						name:           "Caminhada em São José dos Ausentes",
						image_url:      "bot/caminhada-sao-jose.jpeg",
						description:    "São José dos Ausentes é conhecida pela beleza de suas paisagens, seus rios e cachoeiras. O ponto mais alto do Rio Grande do Sul, fica próximo ao Canion do Montenegro e com uma altitude de 1403m.",
						dominant_color: "#A7BED8"
				},
				{
						id:             18,
						name:           "Teatro Frida Kahlo À Revolução",
						image_url:      "bot/frida-kahlo.jpeg",
						description:    "Livremente inspirada na vida e obra da poderosa pintora mexicana com dramaturgia  e trilha sonora originais.",
						dominant_color: "#631C01"
				},
				{
						id:             19,
						name:           "Serenata Iluminada na Redenção",
						image_url:      "bot/serenata-iluminada.jpeg",
						description:    "Levamos velas, lanternas, instrumentos musicais e manifestações culturais para fazer um encontro que mistura alegria, expressão e reflexão sobre o bom uso dos espaços públicos.",
						dominant_color: "#7F7C45"
				},
				{
						id:             20,
						name:           "Picnic Cultural no Museu",
						image_url:      "bot/picnic-museu.jpeg",
						description:    "Vamos celebrar um dia lindo no pátio do Museu de Porto Alegre Joaquim Felizardo. Um lugar cheio de energia positiva para tu curtires com teus amigos, amores e familiares.",
						dominant_color: "#225070"
				}
		]
	end

end
