Recordings = new Mongo.Collection('recordings');

Recordings.attachSchema(new SimpleSchema([BaseSchema, {
  temperature: { type: Number, decimal: true },
  humidity: { type: Number, decimal: true }
}]));

if (Meteor.isServer) {
  Meteor.publish('recordings', function(limit) {
    check(limit, Number);
    return Recordings.find({},{sort:{createdAt:-1},limit:limit});
  })
}
