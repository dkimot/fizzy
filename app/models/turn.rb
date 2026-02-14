class Turn < ApplicationRecord
  include Fulfillable, Streamable

  belongs_to :account, default: -> { parent.account }
  belongs_to :parent, polymorphic: true, touch: true
  belongs_to :creator, class_name: "User", default: -> { Current.user }
  belongs_to :artifact, optional: true

  enum :role, %w[ user assistant ].index_by(&:itself)
  enum :status, %w[ pending processing completed failed ].index_by(&:itself), default: :pending

  scope :chronologically, -> { order(Arel.sql("COALESCE(position, 0)"), created_at: :asc) }

  def card
    parent.card
  end

  # Reads content from artifact attachment when present,
  # falling back to the stored content column.
  def effective_content
    if artifact&.content&.attached?
      artifact.content.download
    else
      content
    end
  end
end
