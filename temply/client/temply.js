Template.body.helpers({
  latestRecording: function() {
    return Recordings.findOne({},{sort: {createdAt: -1}});
  },
  currentSettings: function() {
    return Settings.findOne();
  },
  fanSpeedIsSelected: function(speed) {
    var settings = Settings.findOne();
    if (settings.fanSpeed === speed)
      return 'selected';
  }
});

Template.body.events({
  'click [data-temp-change]': function(e, tmpl) {
    e.preventDefault();

    var change = parseInt(e.target.parentElement.dataset.tempChange);
    Meteor.call('changeTemperature', change);
  },
  'click [data-fanspeed-change]': function(e, tmpl) {
    e.preventDefault();

    var change = parseInt(e.target.dataset.fanspeedChange);
    Meteor.call('changeFanSpeed', change);
  }
});
