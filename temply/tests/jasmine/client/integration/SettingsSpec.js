var getSettings = function() {
  return Settings.findOne();
}

describe('Settings', function() {
  describe('Methods', function() {
    beforeEach(function() {
      Settings.update({_id:getSettings()._id},{$set:{
        temperature: 82,
        fanSpeed: 2
      }});
    });

    it("can increase temperature", function(done) {
      Meteor.call('changeTemperature', 1, function(err) {
        expect(err).toBeUndefined();
        expect(getSettings().temperature).toEqual(84);
        done();
      });
    });

    it("can decrease temperature", function(done) {
      Meteor.call('changeTemperature', 0, function(err) {
        expect(err).toBeUndefined();
        expect(getSettings().temperature).toEqual(80);
        done();
      });
    });

    it("will not change temperature outside hardware limits", function(done) {
      Meteor.call('changeTemperature', 1, function(err) {
        Meteor.call('changeTemperature', 1, function(err) {
          Meteor.call('changeTemperature', 1, function(err) {
            Meteor.call('changeTemperature', 1, function(err) {
              Meteor.call('changeTemperature', 1, function(err) {
                expect(err).toBeUndefined();
                expect(getSettings().temperature).toEqual(88);
                done();
              });
            });
          });
        });
      });
    });

    it("can change fan speed", function(done) {
      Meteor.call('changeFanSpeed', 1, function(err) {
        expect(err).toBeUndefined();
        expect(getSettings().fanSpeed).toEqual(1);
        done();
      });
    });

    it("will not change fan speed outside hardware limits", function(done) {
      Meteor.call('changeFanSpeed', 6, function(err) {
        expect(err).toBeDefined();
        expect(getSettings().fanSpeed).toEqual(2);
        done();
      });
    });
  });
});
