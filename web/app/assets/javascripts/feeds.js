document.addEventListener('turbolinks:load', function() {
  var elems = document.querySelectorAll('.tooltipped');
  var instances = M.Tooltip.init(elems);
}, {once: true});
