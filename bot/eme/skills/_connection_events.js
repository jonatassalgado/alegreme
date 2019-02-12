/* This module kicks in if no Botkit Studio token has been provided */

module.exports = function(controller) {

  var patterns = {
    positive: /iria|sim|claro|j(a|á)|l(a|á)|partiu|aham|foi/gi,
    negative: /não|nunca|nem/gi,
    neutral: /talvez|quiça|quem|sabe|se|p(a|á)/gi
  }

  var typing = {
    slow: 100,
    normal: 100,
    fast: 100
  }

  var events = [
    {
      "id": 0,
      "name": "<b>Arduino Day</b>",
      "imageUrl": "./arduino-day-2019.png",
      "description": "Evento para pessoas desenvolvedoras de software que desejam aprendar mais sobre a linguagem Arduino."
    },
    {
      "id": 1,
      "name": "<b>Festa HOT</b>",
      "imageUrl": "./festa-hot-doma.png",
      "description": "A pista mais fervida de Porto Alegre, sem moralismo, sem preconceito. No som: house, disco e os hits clássicos das últimas décadas. "
    },
    {
      "id": 2,
      "name": "<b>Mindfulness Intermediário e Avançado</b>",
      "imageUrl": "./mindfulness-intermediario-avancado.png",
      "description": "Curso de mindfulness para recuperar a motivação na prática, criando um compromisso sincero, também como avançar no treino e estabilização da atenção instrospectiva, possibilitando agir de maneira mais assertiva, criando felicidade e bem estar para nós mesmos e para os outros."
    },
    {
      "id": 3,
      "name": "<b>Bike Tour nas Ruínas das Missões</b>",
      "imageUrl": "./bike-tour-missoes.jpeg",
      "description": "Cicloturismo em São Miguel das Missões e depois do pedal vamos relaxar na acolhedora Pousada das Missões."
    },
    {
      "id": 4,
      "name": "<b>Cinema mudo com música ao vivo</b>",
      "imageUrl": "./cine-ibere-musica-aovivo.jpeg",
      "description": "Sessão no Iberê Camargo do filme O Gabinete do Dr. Caligari, um dos filmes mais importantes da história do cinema mundial. Considerado o primeiro filme de terror."
    },
    {
      "id": 5,
      "name": "<b>Festa Nacional da Uva</b>",
      "imageUrl": "./festa-da-uva.jpeg",
      "description": "É uma das maiores festas do Brasil com shows de artistas como Anitta e Molejo. Ocorre em Caxias do Sul, cidade da serra gaúcha com colonização italiana e produção de vinho."
    },
    {
      "id": 6,
      "name": "<b>Feira do Aeromovel</b>",
      "imageUrl": "./feira-do-aeromovel.jpeg",
      "description": "A feira acontece de frente para a Orla do Guaíba, na praça do antigo Aeromovel. Um público lindo ocupando a praça, expositores de marcas locais, gastronomia, cultura, arte e cidadania."
    },
    {
      "id": 7,
      "name": "<b>Feira Vegana Noturna</b>",
      "imageUrl": "./feira-vegana-noturna.jpeg",
      "description": "Feira com produtos veganos que ocorre no bairro Bom Fim durante a noite."
    },
    {
      "id": 8,
      "name": "<b>Madrugadão Virada Nerd</b>",
      "imageUrl": "./virada-nerd.jpeg",
      "description": "Duas madrugadas no final de semana com pizzas e jogos de tabuleiro para se divertir com amigos."
    },
    {
      "id": 9,
      "name": "<b>Arruaça</b>",
      "imageUrl": "./arruaca.jpeg",
      "description": "Festa de rua das mina, das mana e das mona. DJs gurias tocando house e techno no centro da cidade, na rua."
    },
    {
      "id": 10,
      "name": "<b>Mindfulness no Pôr do Sol</b>",
      "imageUrl": "./mindfulness-por-do-sol.jpeg",
      "description": "Venha participar da meditação de Atenção Plena e desfrutar de um momento de presença e desenvolvimento de tranquilidade, contemplando nosso belo cartão postal na Orla do Guaíba."
    },
    {
      "id": 11,
      "name": "<b>Trilha da Fortaleza no Parque de Itapuã</b>",
      "imageUrl": "./trilha-da-fortaleza.jpeg",
      "description": "Localizado a 57 km da capital, o Parque de Itapuã, protege a última amostra dos ecossistemas com campos, matas, dunas, lagoas, praias e morros às margens do lago Guaíba e da laguna dos Patos."
    },
    {
      "id": 12,
      "name": "<b>Exposição Cecily Brown</b>",
      "imageUrl": "./exposicao-cecily-brown.jpeg",
      "description": "Cecily Brown é uma das artistas de maior destaque na pintura contemporânea mundial."
    }
  ]


  controller.on('hello', conductOnboarding);
  controller.on('welcome_back', conductOnboarding);


  function conductOnboarding(bot, message) {
    bot.startConversation(message, function(err, convo) {


      // START
      convo.ask({
        text: 'Oi. Tem alguém ai?',
        quick_replies: [
          {
            title: 'Sim',
            payload: 'Sim! Tô aqui',
          }
        ]
      },
      [
        {
          pattern: /sim|eu|yo|aqui/gi,
          callback: function(res, convo) {
            if (convo.vars.personaSuitability == undefined){
              convo.setVar('personaSuitability', [])
            }

            convo.gotoThread('self_presentation')
            convo.next()
          }
        }
      ]);



      // SELF PRESENTATION
      convo.addMessage({
        text: 'Oi! Eu sou o <b>Eme</b>',
      }, 'self_presentation');

      convo.addMessage({
        text: 'Trabalho aqui no projeto <b>Alegreme</b> e vou te ajudar a ter uma <i>agenda de eventos de Porto Alegre com a sua cara</i>.'
      }, 'self_presentation');

      convo.addQuestion({
        text: 'Para isso vou precisar saber o que você gosta. <b>Ok?</b>',
        quick_replies: [
          {
            title: 'Ok, pode perguntar',
            payload: 'Ok, pode perguntar',
          }
        ]
      },
      [
        {
          pattern: /ok|sim|claro|vamos|pode/gi,
          callback: function(res, convo) {
            convo.gotoThread('how_works')
            convo.next()
          }
        }
      ], {}, 'self_presentation');



      // HOW WORKS
      convo.addMessage({
        text: 'Vou te mostrar alguns eventos que acontecem em Porto Alegre e te <b>perguntar se gostaria de ir ou não</b>'
      }, 'how_works')

      convo.addMessage({
        text: 'Com base no seu gosto por alguns eventos, <b>vou definir sua persona</b>, o qual me ajudará a indicar eventos futuros',
        typingDelay: typing.slow
      }, 'how_works')

      convo.addMessage({
        text: 'Vamos ao primeiro evento',
        typingDelay: typing.slow
      }, 'how_works')


      convo.addMessage({
        text: events[0].name,
        typingDelay: typing.slow,
        files: [
          {
            url: events[0].imageUrl,
            image: true
          }
        ]
      }, 'how_works')

      convo.addMessage({
        text: events[0].description,
        typingDelay: typing.normal,
        action: 'pitchArduino'
      }, 'how_works')


      // 0
      convo.addQuestion({
        text: '<b>Você iria neste evento?</b>',
        typingDelay: typing.normal,
        quick_replies: [
          {
            title: 'Iria certo',
            payload: 'Iria certo',
          },
          {
            title: 'Talvez',
            payload: 'Talvez',
          },
          {
            title: 'Não me vejo indo',
            payload: 'Não iria',
          },
        ]
      },[
        {
          pattern: patterns.positive,
          callback: function(res, convo) {
            convo.vars.personaSuitability[0] = "1";
            pitchHot(res, convo)
            convo.next()
          }
        },
        {
          pattern: patterns.neutral,
          callback: function(res, convo) {
            convo.vars.personaSuitability[0] = "0";
            pitchHot(res, convo)
            convo.next();
          }
        },
        {
          pattern: patterns.negative,
          callback: function(res, convo) {
            convo.vars.personaSuitability[0] = "-1";
            pitchHot(res, convo)
            convo.next();
          }
        },
        {
          default: true,
          callback: function(res, convo) {
            bot.reply(convo.source_message, 'Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>');
            convo.silentRepeat();
          }
        }
      ],
      {}, 'pitchArduino');



      // 1
      const pitchHot = function(res, convo){
        convo.say({
          text: 'Legal! E neste evento',
          typingDelay: typing.fast,
        })

        convo.say({
          text: events[1].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[1].imageUrl,
              image: true
            }
          ]
        })

        convo.say({
          text: events[1].description,
          typingDelay: typing.normal
        })

        convo.ask({
          text: '<b>Você iria?</b>',
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: 'Iria certo',
              payload: 'Iria certo',
            },
            {
              title: 'Talvez',
              payload: 'Talvez',
            },
            {
              title: 'Não me vejo indo',
              payload: 'Não iria',
            },
          ]
        },[
          {
            pattern: patterns.positive,
            callback: function(res, convo) {
              convo.vars.personaSuitability[1] = "1";
              pitchMindfullness(res, convo)
              convo.next();
            }
          },
          {
            pattern: patterns.neutral,
            callback: function(res, convo) {
              convo.vars.personaSuitability[1] = "0";
              pitchMindfullness(res, convo)
              convo.next();
            }
          },
          {
            pattern: patterns.negative,
            callback: function(res, convo) {
              convo.vars.personaSuitability[1] = "-1";
              pitchMindfullness(res, convo)
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              bot.reply(convo.source_message, 'Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>');
              convo.silentRepeat();
            }
          }
        ]);
      }


      // 2
      const pitchMindfullness = function(res, convo){
        convo.say({
          text: events[2].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[2].imageUrl,
              image: true
            }
          ]
        })

        convo.say({
          text: events[2].description,
          typingDelay: typing.normal
        })


        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: 'Iria certo',
              payload: 'Iria certo',
            },
            {
              title: 'Talvez',
              payload: 'Talvez',
            },
            {
              title: 'Não me vejo indo',
              payload: 'Não iria',
            },
          ]
        },[
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
            pattern: patterns.negative,
            callback: function(res, convo) {
              convo.vars.personaSuitability[2] = "-1";
              pitchBikeTour(res, convo);
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              bot.reply(convo.source_message, 'Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>');
              convo.silentRepeat();
            }
          }
        ]);
      }




      // 3
      const pitchBikeTour = function(res, convo){
        convo.say({
          text: events[3].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[3].imageUrl,
              image: true
            }
          ]
        })

        convo.say({
          text: events[3].description,
          typingDelay: typing.normal
        })


        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: 'Iria certo',
              payload: 'Iria certo',
            },
            {
              title: 'Talvez',
              payload: 'Talvez',
            },
            {
              title: 'Não me vejo indo',
              payload: 'Não iria',
            },
          ]
        },[
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
            pattern: patterns.negative,
            callback: function(res, convo) {
              convo.vars.personaSuitability[3] = "-1";
              pitchCineIbere(res, convo);
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              bot.reply(convo.source_message, 'Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>');
              convo.silentRepeat();
            }
          }
        ]);
      }



      // 4
      const pitchCineIbere = function(res, convo){
        convo.say({
          text: events[4].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[4].imageUrl,
              image: true
            }
          ]
        })

        convo.say({
          text: events[4].description,
          typingDelay: typing.normal
        })


        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: 'Iria certo',
              payload: 'Iria certo',
            },
            {
              title: 'Talvez',
              payload: 'Talvez',
            },
            {
              title: 'Não me vejo indo',
              payload: 'Não iria',
            },
          ]
        },[
          {
            pattern: patterns.positive,
            callback: function(res, convo) {
              convo.vars.personaSuitability[4] = "1";
              pitchFestaDaUva(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.neutral,
            callback: function(res, convo) {
              convo.vars.personaSuitability[4] = "0";
              pitchFestaDaUva(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.negative,
            callback: function(res, convo) {
              convo.vars.personaSuitability[4] = "-1";
              pitchFestaDaUva(res, convo);
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              bot.reply(convo.source_message, 'Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>');
              convo.silentRepeat();
            }
          }
        ]);
      }




      // 5
      const pitchFestaDaUva = function(res, convo){
        convo.say({
          text: events[5].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[5].imageUrl,
              image: true
            }
          ]
        })

        convo.say({
          text: events[5].description,
          typingDelay: typing.normal
        })


        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: 'Iria certo',
              payload: 'Iria certo',
            },
            {
              title: 'Talvez',
              payload: 'Talvez',
            },
            {
              title: 'Não me vejo indo',
              payload: 'Não iria',
            },
          ]
        },[
          {
            pattern: patterns.positive,
            callback: function(res, convo) {
              convo.vars.personaSuitability[5] = "1";
              pitchFeiraAeromovel(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.neutral,
            callback: function(res, convo) {
              convo.vars.personaSuitability[5] = "0";
              pitchFeiraAeromovel(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.negative,
            callback: function(res, convo) {
              convo.vars.personaSuitability[5] = "-1";
              pitchFeiraAeromovel(res, convo);
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              bot.reply(convo.source_message, 'Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>');
              convo.silentRepeat();
            }
          }
        ]);
      }




      // 6
      const pitchFeiraAeromovel = function(res, convo){
        convo.say({
          text: events[6].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[6].imageUrl,
              image: true
            }
          ]
        })

        convo.say({
          text: events[6].description,
          typingDelay: typing.normal
        })


        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: 'Iria certo',
              payload: 'Iria certo',
            },
            {
              title: 'Talvez',
              payload: 'Talvez',
            },
            {
              title: 'Não me vejo indo',
              payload: 'Não iria',
            },
          ]
        },[
          {
            pattern: patterns.positive,
            callback: function(res, convo) {
              convo.vars.personaSuitability[6] = "1";
              pitchFeiraNoturnaVegana(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.neutral,
            callback: function(res, convo) {
              convo.vars.personaSuitability[6] = "0";
              pitchFeiraNoturnaVegana(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.negative,
            callback: function(res, convo) {
              convo.vars.personaSuitability[6] = "-1";
              pitchFeiraNoturnaVegana(res, convo);
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              bot.reply(convo.source_message, 'Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>');
              convo.silentRepeat();
            }
          }
        ]);
      }




      // 7
      const pitchFeiraNoturnaVegana = function(res, convo){
        convo.say({
          text: events[7].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[7].imageUrl,
              image: true
            }
          ]
        })

        convo.say({
          text: events[7].description,
          typingDelay: typing.normal
        })

        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: 'Iria certo',
              payload: 'Iria certo',
            },
            {
              title: 'Talvez',
              payload: 'Talvez',
            },
            {
              title: 'Não me vejo indo',
              payload: 'Não iria',
            },
          ]
        },[
          {
            pattern: patterns.positive,
            callback: function(res, convo) {
              convo.vars.personaSuitability[7] = "1";
              pitchMadrugadaoNerd(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.neutral,
            callback: function(res, convo) {
              convo.vars.personaSuitability[7] = "0";
              pitchMadrugadaoNerd(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.negative,
            callback: function(res, convo) {
              convo.vars.personaSuitability[7] = "-1";
              pitchMadrugadaoNerd(res, convo);
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              bot.reply(convo.source_message, 'Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>');
              convo.silentRepeat();
            }
          }
        ]);
      }




      // 8
      const pitchMadrugadaoNerd = function(res, convo){
        convo.say({
          text: events[8].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[8].imageUrl,
              image: true
            }
          ]
        })

        convo.say({
          text: events[8].description,
          typingDelay: typing.normal
        })

        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: 'Iria certo',
              payload: 'Iria certo',
            },
            {
              title: 'Talvez',
              payload: 'Talvez',
            },
            {
              title: 'Não me vejo indo',
              payload: 'Não iria',
            },
          ]
        },[
          {
            pattern: patterns.positive,
            callback: function(res, convo) {
              convo.vars.personaSuitability[8] = "1";
              pitchArruaca(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.neutral,
            callback: function(res, convo) {
              convo.vars.personaSuitability[8] = "0";
              pitchArruaca(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.negative,
            callback: function(res, convo) {
              convo.vars.personaSuitability[8] = "-1";
              pitchArruaca(res, convo);
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              bot.reply(convo.source_message, 'Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>');
              convo.silentRepeat();
            }
          }
        ]);
      }




      // 9
      const pitchArruaca = function(res, convo){
        convo.say({
          text: events[9].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[9].imageUrl,
              image: true
            }
          ]
        })

        convo.say({
          text: events[9].description,
          typingDelay: typing.normal
        })

        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: 'Iria certo',
              payload: 'Iria certo',
            },
            {
              title: 'Talvez',
              payload: 'Talvez',
            },
            {
              title: 'Não me vejo indo',
              payload: 'Não iria',
            },
          ]
        },[
          {
            pattern: patterns.positive,
            callback: function(res, convo) {
              convo.vars.personaSuitability[9] = "1";
              pitchMindfullnessPorDoSol(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.neutral,
            callback: function(res, convo) {
              convo.vars.personaSuitability[9] = "0";
              pitchMindfullnessPorDoSol(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.negative,
            callback: function(res, convo) {
              convo.vars.personaSuitability[9] = "-1";
              pitchMindfullnessPorDoSol(res, convo);
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              bot.reply(convo.source_message, 'Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>');
              convo.silentRepeat();
            }
          }
        ]);
      }




      // 10
      const pitchMindfullnessPorDoSol = function(res, convo){
        convo.say({
          text: events[10].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[10].imageUrl,
              image: true
            }
          ]
        })

        convo.say({
          text: events[10].description,
          typingDelay: typing.normal
        })

        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: 'Iria certo',
              payload: 'Iria certo',
            },
            {
              title: 'Talvez',
              payload: 'Talvez',
            },
            {
              title: 'Não me vejo indo',
              payload: 'Não iria',
            },
          ]
        },[
          {
            pattern: patterns.positive,
            callback: function(res, convo) {
              convo.vars.personaSuitability[10] = "1";
              pitchTrilhaDaFortaleza(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.neutral,
            callback: function(res, convo) {
              convo.vars.personaSuitability[10] = "0";
              pitchTrilhaDaFortaleza(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.negative,
            callback: function(res, convo) {
              convo.vars.personaSuitability[10] = "-1";
              pitchTrilhaDaFortaleza(res, convo);
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              bot.reply(convo.source_message, 'Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>');
              convo.silentRepeat();
            }
          }
        ]);
      }




      // 11
      const pitchTrilhaDaFortaleza = function(res, convo){
        convo.say({
          text: events[11].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[11].imageUrl,
              image: true
            }
          ]
        })

        convo.say({
          text: events[11].description,
          typingDelay: typing.normal
        })

        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: 'Iria certo',
              payload: 'Iria certo',
            },
            {
              title: 'Talvez',
              payload: 'Talvez',
            },
            {
              title: 'Não me vejo indo',
              payload: 'Não iria',
            },
          ]
        },[
          {
            pattern: patterns.positive,
            callback: function(res, convo) {
              convo.vars.personaSuitability[11] = "1";
              pitchCecilyBrown(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.neutral,
            callback: function(res, convo) {
              convo.vars.personaSuitability[11] = "0";
              pitchCecilyBrown(res, convo);
              convo.next();
            }
          },
          {
            pattern: patterns.negative,
            callback: function(res, convo) {
              convo.vars.personaSuitability[11] = "-1";
              pitchCecilyBrown(res, convo);
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              bot.reply(convo.source_message, 'Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>');
              convo.silentRepeat();
            }
          }
        ]);
      }




      // 12
      const pitchCecilyBrown = function(res, convo){
        convo.say({
          text: events[12].name,
          typingDelay: typing.normal,
          files: [
            {
              url: events[12].imageUrl,
              image: true
            }
          ]
        })

        convo.say({
          text: events[12].description,
          typingDelay: typing.normal
        })

        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: typing.normal,
          quick_replies: [
            {
              title: 'Iria certo',
              payload: 'Iria certo',
            },
            {
              title: 'Talvez',
              payload: 'Talvez',
            },
            {
              title: 'Não me vejo indo',
              payload: 'Não iria',
            },
          ]
        },[
          {
            pattern: patterns.positive,
            callback: function(res, convo) {
              convo.vars.personaSuitability[12] = "1";
              convo.next();
            }
          },
          {
            pattern: patterns.neutral,
            callback: function(res, convo) {
              convo.vars.personaSuitability[12] = "0";
              convo.next();
            }
          },
          {
            pattern: patterns.negative,
            callback: function(res, convo) {
              convo.vars.personaSuitability[12] = "-1";
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              bot.reply(convo.source_message, 'Eita! Perguntei se você gostaria de ir no evento acima, é só responder <b>sim</b>, <b>talvez</b> ou <b>não</b>');
              convo.silentRepeat();
            }
          }
        ]);
      }






    });
  }
}
