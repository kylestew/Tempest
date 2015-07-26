Settings = new Mongo.Collection('settings');

Settings.attachSchema(new SimpleSchema([BaseSchema, {
  temp: { type: Number },
  fanSpeed: { type: Number }
}]));
