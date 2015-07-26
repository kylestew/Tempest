Template.body.helpers({
  latestRecording: function() {
    return Recordings.findOne({},{sort: {createdAt: -1}});
  },
  currentSettings: function() {
    return Settings.findOne();
  }
});

Template.body.events({
  'click [data-temp-change]': function(e, tmpl) {
    e.preventDefault();

    var change = parseInt(e.target.dataset.tempChange);
    Meteor.call('changeTemperature', change);
  },
  'click [data-fanspeed-change]': function(e, tmpl) {
    e.preventDefault();

    var change = parseInt(e.target.dataset.fanspeedChange);
    Meteor.call('changeFanSpeed', change);
  }
});
