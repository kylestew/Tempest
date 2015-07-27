Template.body.onCreated(function() {
  this.subscribe('recordings', 1);
  this.subscribe('settings');

  this.currentRecording = function() {
    return Recordings.findOne({},{sort: {createdAt: -1}});
  }
  this.settings = function() {
    return Settings.findOne();
  }
});

Template.body.helpers({
  latestRecording: function() {
    return Template.instance().currentRecording();
  },
  currentSettings: function() {
    return Template.instance().settings();
  },
  fanSpeedIsSelected: function(speed) {
    var settings = Template.instance().settings();
    if (settings && settings.fanSpeed === speed)
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
