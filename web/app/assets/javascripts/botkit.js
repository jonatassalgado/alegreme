var options = {
  id: gon.user_id || "null"
};

Botkit.boot(options);

document.addEventListener("turbolinks:render", () => {
  var options = {
    id: gon.user_id || "null"
  };

  Botkit.boot(options);
});
