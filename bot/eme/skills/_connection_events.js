/* This module kicks in if no Botkit Studio token has been provided */

module.exports = function(controller) {

  var events = [{
    "id": 0,
    "name": "<b>Arduino Day 2019</b>",
    "imageUrl": "./arduino-day-2019.png",
    "description": "Evento para pessoas desenvolvedoras de software que desejam aprendar mais sobre a linguagem Arduino."
  },
  {
    "id": 1,
    "name": "<b>Festa HOT</b>",
    "imageUrl": "./arduino-day-2019.png",
    "description": "A pista mais fervida de Porto Alegre, sem moralismo, sem preconceito. No som: house, disco e os hits clássicos das últimas décadas. "
  }]


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
        text: 'Vou te mostrar alguns eventos reais que acontecem em Porto Alegre e te <b>perguntar se gostaria de ir ou não</b>'
      }, 'how_works')

      convo.addMessage({
        text: 'Com base no seu gosto por alguns eventos, <b>vou definir sua persona</b>, o qual me ajudará a indicar eventos futuros',
        typingDelay: 5000
      }, 'how_works')

      convo.addMessage({
        text: 'Vamos ao primeiro evento',
        typingDelay: 5500
      }, 'how_works')

      if (convo.vars.currentEvent == undefined) {
        convo.setVar('currentEvent', 0)
      }

      convo.addMessage({
        text: events[convo.vars.currentEvent].name,
        typingDelay: 5000,
        files: [
          {
            url: events[convo.vars.currentEvent].imageUrl,
            image: true
          }
        ]
      }, 'how_works')

      convo.addMessage({
        text: events[convo.vars.currentEvent].description,
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

            convo.vars.personaSuitability[convo.vars.currentEvent] = 1;
            convo.setVar('currentEvent', convo.vars.currentEvent + 1);

            convo.pitchEvent()
            convo.next()
          }
        },
        {
          pattern: 'talvez',
          callback: function(res, convo) {
            if (convo.vars.personaSuitability == undefined){
              convo.setVar('personaSuitability', [])
            }

            convo.vars.personaSuitability[convo.vars.currentEvent] = 0;
            convo.vars.currentEvent = convo.vars.currentEvent + 1;
            console.log(convo.vars);

            convo.gotoThread('pitchEvent')
            convo.next()
          }
        },
        {
          pattern: 'Não',
          callback: function(res, convo) {
            if (convo.vars.personaSuitability == undefined){
              convo.setVar('personaSuitability', [])
            }

            convo.vars.personaSuitability[convo.vars.currentEvent] = -1;
            convo.vars.currentEvent = convo.vars.currentEvent + 1;

            convo.gotoThread('pitchEvent')
            convo.next()
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





      convo.pitchEvent = function pitchEvent() {
        this.say({
          text: events[this.vars.currentEvent].name,
          typingDelay: 5000,
          files: [
            {
              url: events[this.vars.currentEvent].imageUrl,
              image: true
            }
          ]
        })

        this.say({
          text: events[this.vars.currentEvent].description,
          action: 'goOrNotGo'
        })
      }

    });


  }
}
