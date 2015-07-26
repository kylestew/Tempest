Recordings = new Mongo.Collection('recordings');

Recordings.attachSchema(new SimpleSchema([BaseSchema, {
  temperature: { type: Number, decimal: true },
  humidity: { type: Number, decimal: true }
}]));
