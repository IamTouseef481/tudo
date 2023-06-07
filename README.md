# Tudo

| Section                                     | Description                                            |
|---------------------------------------------|--------------------------------------------------------|
| [🏎 Quickstart](#Quickstart)                | Details on how to kickstart development on the project |
| [🎯 Development model](#-development-model) | Branching, merging and deploying                       |

## 🏎 Quickstart

### 🚧 Dependencies

#### Application

Install the [`asdf`](http://asdf-vm.com/) version manager to manage the runtime dependencies specified in the `.tool-versions` file.

Run this command to help get the runtime dependencies:

### macOS

`nv` is available via [Homebrew](#homebrew) and as a downloadable binary from the [releases page](https://github.com/jcouture/nv/releases).

#### Homebrew

| Install                       | Upgrade           |
| ----------------------------- | ----------------- |
| `brew install jcouture/nv/nv` | `brew upgrade nv` |

### Linux

`nv` is available as downloadable binaries from the [releases page](https://github.com/jcouture/nv/releases).

### Windows

`nv` is available as a downloadable binary from the [releases page](https://github.com/jcouture/nv/releases).

### Build from source

Alternatively, you can build it from source.

1. Verify you have Go 1.16+ installed

  ```shell
    ~> go version
  ```

If `Go` is not installed, follow the instructions on the [Go website](https://golang.org/doc/install)

2. Clone this repository

  ```shell
    ~> git clone https://github.com/jcouture/nv.git
    ~> cd nv
  ```

3. Build

  ``` shell
    ~> go mod tidy
    ~> go build ./cmd/nv/
  ```

Please see [list of helpful things](docs/installation_help.md) in case you run into issues with getting set up on OSX.

#### Database

Access to a local [PostgreSQL 13](https://www.postgresql.org/download/) database is required.

### Environment variables

All required environment variables are documented in [`.env.dev`](./.env.dev).

When running `mix` or `make` commands, it is important that these variables are present in the environment. There are several ways to achieve this. Using [`nv`](https://github.com/jcouture/nv) is recommended since it works out of the box with `.env.*` files.

### Initial setup after installing dependencies

Run 

  ``` shell
  ~> make nv-deploy
  ```

This should

  1. Install Mix and dependencies
  2. Create both `.env.dev.local` and `.env.test.local`. You can place variables here that you might want to override in [`.env.dev`](./.env.dev) and [`.env.test`](./.env.test), but not check in.
  3. Generate values for mandatory secrets in [`.env.dev`](./.env.dev) with `mix phx.gen.secret`
  4. Create and migrate the database with `mix ecto.setup`

You should now be able to start the phoenix server

  ``` shell
  ~> make nv-run
  ```
  or with an interactive shell
  ``` shell
  ~> iex -S mix phx.server
  ```

## Common  `mix` commands
| Description                                                      | Alias                          |
|------------------------------------------------------------------|--------------------------------|
| Run the server using the `dev` environment                       | `iex -S mix phx.server`        |
| Run tests in the `test` environment                              | `mix test`                     |
| Run tests in the `test` environment and generates the API doc    | `DOC=1 mix test`               |
| Run only tagged tests in the `test` environment                  | `mix test --only authenticated`|
| Re-run failed tests in the `test` environment                    | `mix test --failed`            |
| Run tests in the specified file in the `test` environment        | `mix test <FILENAME>`          |
| Run migrations in the `dev` environment                          | `mix ecto.migrate`             |
| Drop the database in the `dev` environment                       | `mix ecto.drop`                |
| Drop and run migrations in the database in the `dev` environment | `mix ecto.reset`               |
| Compiles code and runs Codecov, Credo to check formatting        | `mix ecto.reset`               |

### Continuous integration

The `.github/workflows/ci.yaml` workflow ensures that the codebase is in good shape on each pull request and branch push.

## 🎯 Development model

### Branching and merging

- We use a three step merge process
  - Create New Branch From `staging`.
  - When `new_branch` is stabilizes sufficiently,then PRs merge into `staging`,
  - The `staging` branch will be deployed to `staging.tudo.app/graphiql` with `tudp.pm` keys.

### Deploy To Staging

- We use these steps to deploy staging 
  - Connect To the `staging` server with `tudo.pm` keys.
  - Go to Tudo Directory with `cd /var/www/tudo/tudo`.
  - Take Pull with `git pull origin staging`.
  - Now change user to `su` with `sudo su`.
  - Kill the server with `fuser -k 4001/tcp`.
  - Run the server with `nohup mix phx.server &!`.

## Elixir Learning Resources

**[Elixir Learning Resources File](./docs/elixir-learning-resources.md)**
