/* This module kicks in if no Botkit Studio token has been provided */

module.exports = function(controller) {

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
      "name": "<b>Bike Tour A Magia das Missões</b>",
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
      "description": "A feira acontece de frente para a Orla do Guaíba, na Praça do antigo Aeromovel. Um público lindo ocupando a Praça, expositores de marcas locais, gastronomia, cultura, arte e cidadania."
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
          pattern: 'Sim',
          callback: function(res, convo) {
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
          pattern: 'Ok',
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
        typingDelay: 5000
      }, 'how_works')

      convo.addMessage({
        text: 'Vamos ao primeiro evento',
        typingDelay: 5500
      }, 'how_works')


      convo.addMessage({
        text: events[0].name,
        typingDelay: 5000,
        files: [
          {
            url: events[0].imageUrl,
            image: true
          }
        ]
      }, 'how_works')

      convo.addMessage({
        text: events[0].description,
        action: 'goOrNotGo'
      }, 'how_works')



      // GO OR NOT GO
      convo.addQuestion({
        text: '<b>Você iria neste evento?</b>',
        typingDelay: 3000,
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
          pattern: 'Iria',
          callback: function(res, convo) {
            if (convo.vars.personaSuitability == undefined){
              convo.setVar('personaSuitability', [])
            }

            convo.vars.personaSuitability[0] = 1;

            pitchHot(res, convo)
            
            console.log(convo.vars);
          }
        },
        {
          pattern: 'talvez',
          callback: function(res, convo) {

          }
        },
        {
          pattern: 'Não',
          callback: function(res, convo) {

          }
        },
        {
          default: true,
          callback: function(res, convo) {
            // convo.gotoThread('end');
          }
        }
      ],
      { eventId: 0 }, 'goOrNotGo');



      const pitchHot = function(res, convo){
        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: 3000,
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
            pattern: 'Iria',
            callback: function(res, convo) {
              if (convo.vars.personaSuitability == undefined){
                convo.setVar('personaSuitability', [])
              }

              convo.vars.personaSuitability[1] = 1;

              convo.say({
                text: events[1].name,
                typingDelay: 4000,
                files: [
                  {
                    url: events[1].imageUrl,
                    image: true
                  }
                ]
              })
              convo.say({
                text: events[1].description
              })

              pitchMindfullness(res, convo)
              convo.next();

              console.log(convo.vars);
            }
          },
          {
            pattern: 'talvez',
            callback: function(res, convo) {

            }
          },
          {
            pattern: 'Não',
            callback: function(res, convo) {

            }
          },
          {
            default: true,
            callback: function(res, convo) {
              // convo.gotoThread('end');
            }
          }
        ]);
      }



      const pitchMindfullness = function(res, convo){
        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: 3000,
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
            pattern: 'Iria',
            callback: function(res, convo) {
              if (convo.vars.personaSuitability == undefined){
                convo.setVar('personaSuitability', [])
              }

              convo.vars.personaSuitability[2] = 1;

              convo.say({
                text: events[2].name,
                typingDelay: 4000,
                files: [
                  {
                    url: events[2].imageUrl,
                    image: true
                  }
                ]
              })
              convo.say({
                text: events[2].description
              })
              convo.next();

              console.log(convo.vars);
            }
          },
          {
            pattern: 'talvez',
            callback: function(res, convo) {

            }
          },
          {
            pattern: 'Não',
            callback: function(res, convo) {

            }
          },
          {
            default: true,
            callback: function(res, convo) {
              // convo.gotoThread('end');
            }
          }
        ]);
      }


    });
  }
}
