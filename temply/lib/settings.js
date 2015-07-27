Settings = new Mongo.Collection('settings');

Settings.attachSchema(new SimpleSchema([BaseSchema, {
  temperature: { type: Number },
  fanSpeed: { type: Number }
}]));

Meteor.startup(function() {
  if (Meteor.isServer) {
    if (Settings.find().count() === 0) {
      Settings.insert({
        temperature: 76,
        fanSpeed: 3
      });
    }
  }
});

Meteor.methods({
  changeTemperature: function(direction) {
    check(direction, Number);

    var settings = Settings.findOne();
    if (settings) {
      var temp = settings.temperature;
      // settable range: 64-88
      if (direction == 0)
        temp -= 2;
      else
        temp += 2;
      if (temp > 88) temp = 88;
      if (temp < 64) temp = 64;

      return Settings.update({_id:settings._id},{$set:{temperature:temp}});
    }
  },
  changeFanSpeed: function(speed) {
    check(speed, Number);

    var settings = Settings.findOne();
    if (settings) {
      return Settings.update({_id:settings._id},{$set:{fanSpeed:speed}});
    }
  }
});
