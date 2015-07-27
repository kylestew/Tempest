// given data, will display it
describe('Temperature display', function() {
  beforeEach(function(done) {
    Meteor.autorun(function (c) {
      var data = {
        temperature: 72.8,
        humidity: 66.4,
      };
      var recordingId = Recordings.insert(data);
      c.stop();
      Deps.afterFlush(done);
    });
  });

  it("displays the temperature", function() {
    expect($('#display-temperature').text().trim()).toEqual("72.8f");
  });

  it("displays the humidity", function() {
    expect($('#display-humidity').text().trim()).toEqual("66.4%");
  });
});
