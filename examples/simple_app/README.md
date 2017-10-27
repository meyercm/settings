# SimpleApp

This is a single application, using the standard in-memory settings backend
(useful for develpment), and is intended to showcase the simplest way to setup
your application using `Settings`.

In particular, see `app_settings.ex`, which is used to populate the default
settings values (see `application.ex`), and serves as a point of reference for
developers to know what settings are available within the app, as well as the
single location for adding new settings to the application.
