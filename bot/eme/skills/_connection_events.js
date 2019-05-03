/* This module kicks in if no Botkit Studio token has been provided */

module.exports = function(controller) {
  const http = require("http");

  var patterns = {
    positive: /iria|iria certo|sim|claro|j(a|á)|l(a|á)|partiu|aham|foi/gi,
    negative: /n(a|ã)o iria|n(a|ã)o|nunca|nem/gi,
    neutral: /talvez|quiça|quem|sabe|se|p(a|á)/gi
  };

  var typing = {
    slow: 100,
    normal: 100,
    fast: 100
  };

  var events = [
    {
      id: 0,
      name: "<b>Arduino Day</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/arduino-day-2019.png`,
      description:
        "Evento para pessoas desenvolvedoras de software que desejam aprendar mais sobre a linguagem Arduino."
    },
    {
      id: 1,
      name: "<b>Festa HOT</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/festa-hot-doma.png`,
      description:
        "A pista mais fervida de Porto Alegre, sem moralismo, sem preconceito. No som: house, disco e os hits clássicos das últimas décadas. "
    },
    {
      id: 2,
      name: "<b>Carnawow</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/carnawow.jpeg`,
      description:
        "O Carnawow é uma síntese de celebração e meditação. São 5 dias pra abrir tua energia, tua capacidade de sentir e criar através de sessões e meditações ativas."
    },
    {
      id: 3,
      name: "<b>Bike Tour nas Ruínas das Missões</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/bike-tour-missoes.jpeg`,
      description:
        "Cicloturismo em São Miguel das Missões e depois do pedal vamos relaxar na acolhedora Pousada das Missões."
    },
    {
      id: 4,
      name: "<b>Cinema mudo com música ao vivo</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/cine-ibere-musica-aovivo.jpeg`,
      description:
        "Sessão no Iberê Camargo do filme O Gabinete do Dr. Caligari, um dos filmes mais importantes da história do cinema mundial. Considerado o primeiro filme de terror."
    },
    {
      id: 5,
      name: "<b>Feira do Aeromovel</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/feira-do-aeromovel.jpeg`,
      description:
        "A feira acontece de frente para a Orla do Guaíba, na praça do antigo Aeromovel. Um público lindo ocupando a praça, expositores de marcas locais, gastronomia, cultura, arte e cidadania."
    },
    {
      id: 6,
      name: "<b>Feira Vegana Noturna</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/feira-vegana-noturna.jpeg`,
      description:
        "Feira com produtos veganos que ocorre no bairro Bom Fim durante a noite."
    },
    {
      id: 7,
      name: "<b>Madrugadão Virada Nerd</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/virada-nerd.jpeg`,
      description:
        "Duas madrugadas no final de semana com pizzas e jogos de tabuleiro para se divertir com amigos."
    },
    {
      id: 8,
      name: "<b>Arruaça</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/arruaca.jpeg`,
      description:
        "Festa de rua das mina, das mana e das mona. DJs gurias tocando house e techno no centro da cidade, na rua."
    },
    {
      id: 9,
      name: "<b>Mindfulness no Pôr do Sol</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/mindfulness-por-do-sol.jpeg`,
      description:
        "Venha participar da meditação de Atenção Plena e desfrutar de um momento de presença e desenvolvimento de tranquilidade, contemplando nosso belo cartão postal na Orla do Guaíba."
    },
    {
      id: 10,
      name: "<b>Trilha da Fortaleza no Parque de Itapuã</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/trilha-da-fortaleza.jpeg`,
      description:
        "Localizado a 57 km da capital, o Parque de Itapuã, protege a última amostra dos ecossistemas com campos, matas, dunas, lagoas, praias e morros às margens do lago Guaíba e da laguna dos Patos."
    },
    {
      id: 11,
      name: "<b>Exposição Cecily Brown</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/exposicao-cecily-brown.jpeg`,
      description:
        "Cecily Brown é uma das artistas de maior destaque na pintura contemporânea mundial."
    },
    {
      id: 12,
      name: "<b>Saint Patrick's Day</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/patricks-day.jpeg`,
      description:
        "Mais de 70 Torneiras de chopp artesanal, espaços temáticos, caça ao tesouro com prêmios de vale tatto, chopp e tickets de food trucks. "
    },
    {
      id: 13,
      name: "<b>Feira Me Gusta</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/feira-me-gusta.jpeg`,
      description:
        "Brechó, arte, gastronomia, música e boa convivência se encontraram sob a sombra de muitas árvores, em bancos e pelos passeios da Praça Isabel."
    },
    {
      id: 14,
      name: "<b>Hackatown Mobilidade</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/hackatown-mobilidade.jpeg`,
      description:
        "Dividido em três dias imersivos, o Hackatown é um espaço de cocriação de soluções para a mobilidade urbana de Porto Alegre em participação com a prefeitura e PUCRS."
    },
    {
      id: 15,
      name: "<b>Fennda na rua</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/fennda.jpeg`,
      description:
        "Festa de rua das mona, das mana e das mina. Techno, house e funk é o que toca. O dresscode é ir de nude."
    },
    {
      id: 16,
      name: "<b>Yoga na Redenção</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/yoga-redencao.jpeg`,
      description:
        "Qualquer pessoa pode participar, não importa a idade, sexo, peso do corpo, crença ou religião, basta a vontade de praticar."
    },
    {
      id: 17,
      name: "<b>Caminhada em São José dos Ausentes</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/caminhada-sao-jose.jpeg`,
      description:
        "São José dos Ausentes é conhecida pela beleza de suas paisagens, seus rios e cachoeiras. O ponto mais alto do Rio Grande do Sul, fica próximo ao Canion do Montenegro e com uma altitude de 1403m."
    },
    {
      id: 18,
      name: "<b>Teatro Frida Kahlo À Revolução</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/frida-kahlo.jpeg`,
      description:
        "Livremente inspirada na vida e obra da poderosa pintora mexicana com dramaturgia  e trilha sonora originais."
    },
    {
      id: 19,
      name: "<b>Serenata Iluminada na Redenção</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/serenata-iluminada.jpeg`,
      description:
        "Levamos velas, lanternas, instrumentos musicais e manifestações culturais para fazer um encontro que mistura alegria, expressão e reflexão sobre o bom uso dos espaços públicos."
    },
    {
      id: 20,
      name: "<b>Picnic Cultural no Museu</b>",
      imageUrl: `${location.protocol}${location.host}/images/bot/picnic-museu.jpeg`,
      description:
        "Vamos celebrar um dia lindo no pátio do Museu de Porto Alegre Joaquim Felizardo. Um lugar cheio de energia positiva para tu curtires com teus amigos, amores e familiares."
    }
  ];

  controller.on("hello", conductOnboarding);
  controller.on("welcome_back", conductOnboarding);

  function conductOnboarding(bot, message) {
    bot.startConversation(message, function(err, convo) {
      // SELF PRESENTATION
      convo.ask({
        text: "Oi! Eu sou o <b>Eme</b>",
        typingDelay: typing.normal,
        action: "self_presentation"
      });

      convo.addMessage(
        {
          text:
            "Trabalho aqui no projeto <b>Alegreme</b> e vou te ajudar a ter uma <i>agenda de eventos de Porto Alegre com a sua cara</i>.",
          typingDelay: typing.normal
        },
        "self_presentation"
      );

      convo.addQuestion(
        {
          text: "Para isso vou precisar saber o que você gosta. <b>Ok?</b>",
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: "Ok, pode perguntar",
              payload: "Ok, pode perguntar"
            }
          ]
        },
        [
          {
            pattern: /ok|sim|claro|vamos|pode/gi,
            callback: function(res, convo) {
              if (convo.vars.personaSuitability == undefined) {
                convo.setVar("personaSuitability", []);
              }
              convo.gotoThread("how_works");
              convo.next();
            }
          }
        ],
        {},
        "self_presentation"
      );

      // HOW WORKS
      convo.addMessage(
        {
          text:
            "Vou te mostrar alguns eventos que acontecem em Porto Alegre e te <b>perguntar se gostaria de ir ou não</b>",
          typingDelay: typing.normal
        },
        "how_works"
      );

      convo.addMessage(
        {
          text:
            "Com base no seu gosto por alguns eventos, <b>vou definir sua persona</b>, o qual me ajudará a indicar eventos futuros",
          typingDelay: typing.slow
        },
        "how_works"
      );

      convo.addMessage(
        {
          text: "Vamos ao primeiro evento",
          typingDelay: typing.slow
        },
        "how_works"
      );

      convo.addMessage(
        {
          text: events[0].name,
          typingDelay: typing.slow,
          files: [
            {
              url: events[0].imageUrl,
              image: true
            }
          ]
        },
        "how_works"
      );

      convo.addMessage(
        {
          text: events[0].description,
          typingDelay: typing.normal,
          action: "pitchArduino"
        },
        "how_works"
      );

      // 0
      convo.addQuestion(
        {
          text: "<b>Você iria neste evento?</b>",
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: "Iria certo",
              payload: "Iria certo"
            },
            {
              title: "Talvez",
              payload: "Talvez"
            },
            {
              title: "Não me vejo indo",
              payload: "Não iria"
            }
          ]
        },
        [
          {
            pattern: patterns.negative,
            callback: function(res, convo) {
              convo.vars.personaSuitability[0] = "-1";
              pitchHot(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.positive,
            callback: function(res, convo) {
              convo.vars.personaSuitability[0] = "1";
              pitchHot(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.neutral,
            callback: function(res, convo) {
              convo.vars.personaSuitability[0] = "0";
              pitchHot(res, convo);
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              bot.reply(
                convo.source_message,
                "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
              );
              convo.silentRepeat();
            }
          }
        ],
        {},
        "pitchArduino"
      );

      // 1
      const pitchHot = function(res, convo) {
        convo.say({
          text: "Legal! E neste evento",
          typingDelay: typing.fast
        });

        convo.say({
          text: events[1].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[1].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[1].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[1] = "-1";
                pitchMindfullness(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[1] = "1";
                pitchMindfullness(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[1] = "0";
                pitchMindfullness(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 2
      const pitchMindfullness = function(res, convo) {
        convo.say({
          text: events[2].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[2].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[2].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[2] = "-1";
                pitchBikeTour(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[2] = "1";
                pitchBikeTour(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[2] = "0";
                pitchBikeTour(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 3
      const pitchBikeTour = function(res, convo) {
        convo.say({
          text: events[3].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[3].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[3].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[3] = "-1";
                pitchCineIbere(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[3] = "1";
                pitchCineIbere(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[3] = "0";
                pitchCineIbere(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 4
      const pitchCineIbere = function(res, convo) {
        convo.say({
          text: events[4].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[4].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[4].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[4] = "-1";
                pitchFeiraAeromovel(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[4] = "1";
                pitchFeiraAeromovel(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[4] = "0";
                pitchFeiraAeromovel(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 5
      const pitchFeiraAeromovel = function(res, convo) {
        convo.say({
          text: events[5].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[5].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[5].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[5] = "-1";
                pitchFeiraNoturnaVegana(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[5] = "1";
                pitchFeiraNoturnaVegana(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[5] = "0";
                pitchFeiraNoturnaVegana(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 6
      const pitchFeiraNoturnaVegana = function(res, convo) {
        convo.say({
          text: events[6].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[6].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[6].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[6] = "-1";
                pitchMadrugadaoNerd(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[6] = "1";
                pitchMadrugadaoNerd(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[6] = "0";
                pitchMadrugadaoNerd(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 7
      const pitchMadrugadaoNerd = function(res, convo) {
        convo.say({
          text: events[7].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[7].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[7].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[7] = "-1";
                pitchArruaca(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[7] = "1";
                pitchArruaca(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[7] = "0";
                pitchArruaca(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 8
      const pitchArruaca = function(res, convo) {
        convo.say({
          text: events[8].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[8].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[8].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[8] = "-1";
                pitchMindfullnessPorDoSol(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[8] = "1";
                pitchMindfullnessPorDoSol(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[8] = "0";
                pitchMindfullnessPorDoSol(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 9
      const pitchMindfullnessPorDoSol = function(res, convo) {
        convo.say({
          text: events[9].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[9].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[9].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[9] = "-1";
                pitchTrilhaDaFortaleza(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[9] = "1";
                pitchTrilhaDaFortaleza(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[9] = "0";
                pitchTrilhaDaFortaleza(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 10
      const pitchTrilhaDaFortaleza = function(res, convo) {
        convo.say({
          text: events[10].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[10].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[10].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[10] = "-1";
                pitchCecilyBrown(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[10] = "1";
                pitchCecilyBrown(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[10] = "0";
                pitchCecilyBrown(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 11
      const pitchCecilyBrown = function(res, convo) {
        convo.say({
          text: events[11].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[11].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[11].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[11] = "-1";
                pitchPatricksDay(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[11] = "1";
                pitchPatricksDay(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[11] = "0";
                pitchPatricksDay(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 12
      const pitchPatricksDay = function(res, convo) {
        convo.say({
          text: events[12].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[12].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[12].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[12] = "-1";
                pitchFeiraMeGusta(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[12] = "1";
                pitchFeiraMeGusta(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[12] = "0";
                pitchFeiraMeGusta(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 13
      const pitchFeiraMeGusta = function(res, convo) {
        convo.say({
          text: events[13].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[13].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[13].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[13] = "-1";
                pitchHackatownMobilidade(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[13] = "1";
                pitchHackatownMobilidade(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[13] = "0";
                pitchHackatownMobilidade(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 14
      const pitchHackatownMobilidade = function(res, convo) {
        convo.say({
          text: events[14].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[14].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[14].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[14] = "-1";
                pitchFennda(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[14] = "1";
                pitchFennda(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[14] = "0";
                pitchFennda(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 15
      const pitchFennda = function(res, convo) {
        convo.say({
          text: events[15].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[15].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[15].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[15] = "-1";
                pitchYogaRedencao(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[15] = "1";
                pitchYogaRedencao(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[15] = "0";
                pitchYogaRedencao(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 16
      const pitchYogaRedencao = function(res, convo) {
        convo.say({
          text: events[16].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[16].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[16].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[16] = "-1";
                pitchCaminhadaSaoJose(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[16] = "1";
                pitchCaminhadaSaoJose(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[16] = "0";
                pitchCaminhadaSaoJose(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 17
      const pitchCaminhadaSaoJose = function(res, convo) {
        convo.say({
          text: events[17].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[17].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[17].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[17] = "-1";
                pitchFridaKahlo(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[17] = "1";
                pitchFridaKahlo(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[17] = "0";
                pitchFridaKahlo(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 18
      const pitchFridaKahlo = function(res, convo) {
        convo.say({
          text: events[18].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[18].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[18].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[18] = "-1";
                pitchSerenataIluminada(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[18] = "1";
                pitchSerenataIluminada(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[18] = "0";
                pitchSerenataIluminada(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 19
      const pitchSerenataIluminada = function(res, convo) {
        convo.say({
          text: events[19].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[19].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[19].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[19] = "-1";
                pitchPicnicMuseu(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[19] = "1";
                pitchPicnicMuseu(res, convo);
                convo.next();
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[19] = "0";
                pitchPicnicMuseu(res, convo);
                convo.next();
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      // 20
      const pitchPicnicMuseu = function(res, convo) {
        convo.say({
          text: events[20].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[20].imageUrl,
              image: true
            }
          ]
        });

        convo.say({
          text: events[20].description,
          typingDelay: typing.normal
        });

        convo.ask(
          {
            text: "<b>Você iria neste evento?</b>",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Iria certo",
                payload: "Iria certo"
              },
              {
                title: "Talvez",
                payload: "Talvez"
              },
              {
                title: "Não me vejo indo",
                payload: "Não iria"
              }
            ]
          },
          [
            {
              pattern: patterns.negative,
              callback: function(res, convo) {
                convo.vars.personaSuitability[20] = "-1";
                predictPersona(res, convo);
              }
            },
            {
              pattern: patterns.positive,
              callback: function(res, convo) {
                convo.vars.personaSuitability[20] = "1";
                predictPersona(res, convo);
              }
            },
            {
              pattern: patterns.neutral,
              callback: function(res, convo) {
                convo.vars.personaSuitability[20] = "0";
                predictPersona(res, convo);
              }
            },
            {
              default: true,
              callback: function(res, convo) {
                bot.reply(
                  convo.source_message,
                  "Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>"
                );
                convo.silentRepeat();
              }
            }
          ]
        );
      };

      const loadNewEvents = function(res, convo) {
        convo.ask(
          {
            text: "Quer ver os eventos agora?",
            typingDelay: typing.normal,
            quick_replies: [
              {
                title: "Sim, me mostre",
                payload: "Sim, me mostre"
              }
            ]
          },
          [
            {
              pattern: /ok|sim|claro|vamos|pode|bora/gi,
              callback: function(res, convo) {
                const personas = JSON.stringify(convo.vars.personaPredict);

                console.log(convo.vars);

                bot.send({
                  type: "event",
                  params: Buffer.from(personas).toString("base64"),
                  name: "reload"
                });
                convo.next();
              }
            }
          ],
          {}
        );
      };

      const predictPersona = function(res, convo) {
        const options = {
          method: "GET"
        };

        const req = http.request(
          `http://${process.env.PRIVATE_IP}:5000/predict/persona?query=${JSON.stringify(
            convo.vars.personaSuitability
          )}`,
          options,
          res => {
            res.setEncoding("utf8");
            res.on("data", data => {
              json = JSON.parse(data);
              console.log(json)
              convo.setVar("personaPredict", json.classification.personas);

              bot.say({
                text: "Pronto! Segundo meus cálculos",
                typingDelay: typing.slow
              });
              bot.say({
                text: `Suas duas personas principais são <b>${json.classification.personas.primary.name.toUpperCase()} e ${json.classification.personas.secondary.name.toUpperCase()}</b>`,
                typingDelay: typing.normal
              });
              bot.say({
                text: `E podemos dizer que você tem um ascendente em <b>${json.classification.personas.tertiary.name.toUpperCase()}</b> com um "Q" de <b>${json.classification.personas.quartenary.name.toUpperCase()}</b>`,
                typingDelay: typing.slow
              });
              bot.say({
                text:
                  "Espero ter acertado, a partir de agora tentarei sugerir eventos que tem a ver com você",
                typingDelay: typing.normal
              });
              bot.say({
                text:
                  "Mas lembre-se que estarei aprendendo com você diariamente o que você gosta e não gosta",
                typingDelay: typing.normal
              });
              bot.say({
                text:
                  "Então a cada nova semana você poderá notar que estarei acertando cada vez mais",
                typingDelay: typing.normal
              });

              loadNewEvents(res, convo);
              convo.next();
            });
            res.on("end", () => {
              console.log("No more data in response.");
            });
          }
        );

        req.on("error", e => {
          console.error(`problem with request: ${e.message}`);
        });

        req.end();
      };
    });
  }
};
