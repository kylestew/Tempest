Recordings = new Mongo.Collection('recordings');

Recordings.attachSchema(new SimpleSchema([BaseSchema, {
  temperature: { type: Number },
  humidity: { type: Number }
}]));
