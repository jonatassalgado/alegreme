/* This module kicks in if no Botkit Studio token has been provided */

module.exports = function(controller) {

    controller.on('hello', conductOnboarding);
    controller.on('welcome_back', conductOnboarding);

    function conductOnboarding(bot, message) {

      bot.startConversation(message, function(err, convo) {

        convo.say({
          text: 'Oi! Eu sou o <b>Eme</b>'
        });

        convo.say({
          text: 'Trabalho aqui no projeto <b>Alegreme</b> e vou te ajudar a ter uma <i>agenda de eventos de Porto Alegre com a sua cara</i>.'
        });

        convo.ask({
          text: 'Para isso vou precisar saber o que você gosta. <b>Ok?</b>',
          quick_replies: [
            {
              title: 'Ok, pode perguntar',
              payload: 'Ok, pode perguntar',
            },
          ]
        });


      });

    }

    controller.hears(['Ok, pode perguntar', 'ok', 'sim', 'claro', 'vamos lá', 'partiu', 'foi'], 'message_received', function(bot, message) {

      bot.startConversation(message, function(err, convo) {


        convo.say({
          text: 'Vou te mostrar alguns eventos reais que acontecem em Porto Alegre e te <b>perguntar se gostaria de ir ou não</b>'
        })

        convo.say({
          text: 'Com base no seu gosto por alguns eventos, <b>vou definir sua persona</b>, o qual me ajudará a indicar eventos futuros',
          typingDelay: 5000
        })

        convo.say({
          text: 'Vamos ao primeiro evento',
          typingDelay: 5500
        })

        convo.say({
          text: '<b>Arduino Day 2019</b>',
          typingDelay: 5000,
          files: [
              {
                url: './arduino-day-2019.png',
                image: true
              }
          ]
        })

        convo.say({
          text: 'Evento para pessoas desenvolvedoras de software que desejam aprendar mais sobre a linguagem Arduino.'
        })

        convo.ask({
          text: '<b>Você iria neste evento?</b>',
          typingDelay: 3000,
          quick_replies: [
            {
              title: 'Iria certo',
              payload: 'documentation',
            },
            {
              title: 'Talvez',
              payload: 'community',
            },
            {
              title: 'Não me vejo indo',
              payload: 'contact us',
            },
          ]
        },[
          {
            pattern: 'documentation',
            callback: function(res, convo) {
              convo.gotoThread('docs');
              convo.next();
            }
          },
          {
            pattern: 'community',
            callback: function(res, convo) {
              convo.gotoThread('community');
              convo.next();
            }
          },
          {
            pattern: 'contact',
            callback: function(res, convo) {
              convo.gotoThread('contact');
              convo.next();
            }
          },
          {
            default: true,
            callback: function(res, convo) {
              convo.gotoThread('end');
            }
          }
        ]);

        // set up docs threads
        convo.addMessage({
          text: 'I do not know how to help with that. Say `help` at any time to access this menu.'
        },'end');

        // set up docs threads
        convo.addMessage({
          text: 'Botkit is extensively documented! Here are some useful links:\n\n[Botkit Studio Help Desk](https://botkit.groovehq.com/help_center)\n\n[Botkit Anywhere README](https://github.com/howdyai/botkit-starter-web/blob/master/readme.md#botkit-anywhere)\n\n[Botkit Developer Guide](https://github.com/howdyai/botkit/blob/master/readme.md#build-your-bot)',
        },'docs');

        convo.addMessage({
          action: 'default'
        }, 'docs');


        // set up community thread
        convo.addMessage({
          text: 'Our developer community has thousands of members, and there are always friendly people available to answer questions about building bots!',
        },'community');

        convo.addMessage({
          text: '[Join our community Slack channel](https://community.botkit.ai) to chat live with the Botkit team, representatives from major messaging platforms, and other developers just like you!',
        },'community');

        convo.addMessage({
          text: '[Checkout the Github Issue Queue](https://github.com/howdyai/botkit/issues) to find frequently asked questions, bug reports and more.',
        },'community');

        convo.addMessage({
          action: 'default'
        }, 'community');



        // set up contact thread
        convo.addMessage({
          text: 'The team who built me can help you build the perfect robotic assistant! They can answer all of your questions, and work with you to develop custom applications and integrations.\n\n[Use this form to get in touch](https://botkit.ai/contact.html), or email us directly at [help@botkit.ai](mailto:help@botkit.ai), and a real human will get in touch!',
        },'contact');
        convo.addMessage({
          action: 'default'
        }, 'contact');

      });

    });


}
