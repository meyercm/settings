# Settings

[![Build Status](https://travis-ci.org/meyercm/settings.svg?branch=master)](https://travis-ci.org/meyercm/settings)

`Settings` is a generic settings API for top-level applications, intended to
solve a set of real-world issues with other approaches to run-time application
configuration.

`Settings` provides an abstraction for the intricacies of settings, while
deferring the practicalities of persistence to the client via the
`Settings.Backend` behaviour.

### Get Started

#### Installation

```elixir
{:settings, "~> 0.1.0"},
```

#### Backend

`Settings` currently ships with just an in-memory backend, which was required in
order to test Settings.  You will need to write a module that implements the
`Settings.Backend` behavior.

#### Use

See [the `SimpleApp` example][simpleapp_readme] for very basic use.
A larger example of an umbrella project is in the works.

### Important concepts

#### `:app`

Apps are a grouping/namespacing construct for settings, most useful in the umbrella
app domain.  When querying settings, queries may be restricted by app, e.g.
`Settings.all(:myapp)`, which returns all settings for the app `:myapp`

#### `:scope`

The return value from `get/1,2` is constrained by 'scope'. First, a simple
example:

```elixir
iex> Settings.create(:http_timeout_ms, 15_000)
...> Settings.get(:http_timeout_ms) # :scope omitted, defaults to :__global
15000 # this is the :__default scope value, because :__global has not been set
...> Settings.set(:http_timeout_ms, 10_000) # :scope omitted, defaults to :__global
...> Settings.get(:http_timeout_ms)
10000 # this is the global scope value
...> Settings.set(:http_timeout_ms, 5_000, scope: :lan_requests)
...> Settings.get(:http_timeout_ms, scope: :lan_requests)
5000
...> Settings.get(:http_timeout_ms, scope: :wifi_requests)
10000 # falls back to :__global, as the :wifi_requests scope has not been set
```

As the example shows, a Setting may have multiple values, each known by their
`:scope`.  `:__default` is the scope set during `Settings.create`, and can only
be changed by calling `Settings.create` again (usually when the app is
restarted). `:__global` is the scope used whenever the `:scope` opt is omitted,
and takes precedence over `:__default`.  Finally, specific scopes may be set by
using the `:scope` opt in `get/2` and `set/3`, and accept any Elixir term.

During retrieval, the value for the requested scope will be returned if it
exists, followed by the `:__global` scope if it exists, with `:__default` as the
ultimate fallback.

### `create/3`

The `create` method **must** be called each time the app is started, prior to
any other calls which access the setting. While this may seem like a stifling
requirement, it is a byproduct of a common pattern in the development process:

1. identify that a hardcoded value should be a run-time setting
2. create the setting, and assign it the value of, e.g. 5
3. test and troubleshoot, then realize that the value should have been 7

We cannot use `set` at this moment, because the value needs to be changed for
the production system, not just in the persistence layer on this developer's
machine.  If the developer now changes the value in the create method to 7, the
source code will reflect that change and can be propagated via source control.

A useful pattern is to create a module/method to be called during app startup
that contains all of the calls to `Settings.create`, which forms a convenient
place to go to see the available configuration for an app.

### API by Example

```elixir
# This allows us to omit these opts from the remaining calls, and affects the
# entire node.
Settings.set_defaults(app: :my_webapp, backend: MyEctoBackend)

# gets app and backend from `set_defaults`
Settings.create(:site_url, "www.foo.com")

# still uses backend from `set_defaults`, but overrides the app
Settings.create(:gps_device, "ttyUSB0", app: :my_serial_app)


```

### Design

This library was designed using [Artifact][artifact_repo].  The raw design files are located
in `./design`, and they have been rendered [here][design_docs].


[artifact_repo]:
https://github.com/vitiral/artifact

[design_docs]:
https://meyercm.github.io/settings/#artifacts/req-purpose

[simpleapp_readme]:
examples/simple_app/README.md
