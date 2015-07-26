Template.body.helpers({
  latestRecording: function() {
    return Recordings.findOne({},{sort: {createdAt: -1}});
  }
});
