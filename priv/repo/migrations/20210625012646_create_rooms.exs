defmodule Manga2gether.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :string
      add :room_code, :integer
      add :owner_id, references(:users, on_delete: :nothing, type: :binary_id), null: true

      timestamps()
    end

    create unique_index(:rooms, [:owner_id])
  end
end
