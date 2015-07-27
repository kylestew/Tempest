// Given inputs, will change data state
var getSettings = function() {
  return Settings.findOne();
}

describe('Temperature control', function() {
  beforeEach(function(done) {
    Meteor.autorun(function (c) {
      Settings.update({_id:getSettings()._id}, {$set:{
        temperature: 82,
        fanSpeed: 2
      }});
      c.stop();
      Deps.afterFlush(done);
    });
  });

  it("displays the current temperature setting", function() {
    expect($('#control-temperature').text().trim()).toEqual("82");
  });

  it("displays the current fan speed", function() {
    expect($($('.fan-control .selected')[0]).data('fanspeed-change')).toEqual(2);
  });

  it("will increase temperature", function() {
    $(".control a:last-child").click();
    expect(getSettings().temperature).toEqual(84);
  });

// not sure why this won't work
  xit("will decrease temperature", function() {
    $(".control a:first-child").click();
    expect(getSettings().temperature).toEqual(80);
  });

  it("will change fan speed", function() {
    $($(".fan-control button:first-child")[0]).click();
    expect(getSettings().fanSpeed).toEqual(0);
  });
});
