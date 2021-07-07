defmodule Manga2gether.Repo.Migrations.AddRoomDetails do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :current_manga, :string, null: true
      add :num_ppl, :integer, default: 0
      add :private, :boolean, default: false
    end
  end
end
