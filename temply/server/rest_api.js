Picker.route('/record', function(params, req, res, next) {
  var data = {
    temperature: params.query.temp,
    humidity: params.query.humd
  };
  var result = Recordings.insert(data);

  console.log(result + " :: " + data);

  res.end();
});

Picker.route('/settings', function(params, req, res, next) {
  console.log("request for settings");

  var temp = String.fromCharCode(80);
  var fanSpeed = String.fromCharCode(3);
  var buffer = new Buffer("*" + temp + "" + fanSpeed + "*", 'utf-8');
  res.write(buffer);

  res.end();
});
