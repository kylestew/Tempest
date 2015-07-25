Picker.route('/record', function(params, req, res, next) {
  console.log("temp: " + params.query.temp);
  console.log("humd: " + params.query.humd);
  console.log("");
  res.end();
});

Picker.route('/settings', function(params, req, res, next) {
  console.log("request for settings");

  var temp = String.fromCharCode(76);
  var fanSpeed = String.fromCharCode(1);
  var buffer = new Buffer("*" + temp + "" + fanSpeed + "*", 'utf-8');
  res.write(buffer);

  res.end();
});
