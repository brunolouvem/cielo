# Cielo

**A Cielo API Client for Elixir**

Online documentation [http://hex.pm/cielo](http://hex.pm/cielo).

## Readmap

|Feature   | Status  |
|---|:---:|
|Bin Consultation  | ✅ |
|Payment Consultation  | ✅ |
|Credit Card Transaction   | ✅ | 
|Debit Card Transaction   | ✅ | 
|BankSlip Transaction   | ✅ | 
|Recurrent Payment Transaction   | ✅ | 
|Zero Auth Consultation   | ⏱ |
|Card Tokenization   | ⏱ |
|Token Consultation   | ⏱ |
|Full Capture Transaction   | ⏱ |
|Partial Capture Transaction   | ⏱ |
|Cancel a Sale   | ⏱ |
|Cancel a Sale   | ⏱ |
|QRCode Transaction   | ⏱ |


## Installation

Add cielo to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cielo, "~> 0.1"}
  ]
end
```

Once that is configured you are all set. Cielo is a library, not an
application, but it does rely on `hackney`, which must be started. For Elixir
versions < 1.4 you'll need to include it in the list of applications:

```elixir
def application do
  [applications: [:cielo]]
end
```

Within your application you will need to configure the merchant id and
authorization keys. You do *not* want to put this information in your
`config.exs` file! Either put it in a `{prod,dev,test}.secret.exs` file which is
sourced by `config.exs`, or read the values in from the environment:

```elixir
config :cielo,
  merchant_id: {:system, "CIELO_MERCHANT_ID"},
  merchant_key: {:system, "CIELO_MERCHANT_KEY"}
```

Furthermore, the environment defaults to `sandbox: false`, so you'll want to configure it with:
```elixir
config :cielo,
  sandbox: true
``` 
in your `config/dev.exs`.

You may optionally pass directly those configuration keys to all functions
performing an API call. In that case, those keys will be used to perform the
call.

You can optionally [configure Hackney options][opts] with:

```elixir
config :cielo,
  http_options: [
    timeout: 30_000, # default, in milliseconds
    recv_timeout: 5000 # default, in milliseconds
  ]
```

[opts]: https://github.com/benoitc/hackney/blob/master/doc/hackney.md#request5


## Contributing

Feedback, feature requests, and fixes are welcomed and encouraged. Please make appropriate use of [Issues](https://github.com/brunolouvem/cielo/issues) and [Pull Requests](https://github.com/brunolouvem/cielo/pulls). All code should have accompanying tests.