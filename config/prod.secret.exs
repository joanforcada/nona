use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :tino, Tino.Endpoint,
  secret_key_base: "Z6mcc9CgvyCfrbu/LqwOpY3aLuzmKBfM/eYAyBiw7YSukWyP910eUcU6CA8yQAa6"

# Configure your database
config :tino, Tino.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "",
  database: "tino_prod",
  pool_size: 20
