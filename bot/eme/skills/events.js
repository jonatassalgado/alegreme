module.exports = function(controller) {

controller.on('pitch_event', function(bot, message) {

    // console.log(bot);

    bot.createConversation(message, function(err, convo) {




        convo.activate();
    });
  })

}
