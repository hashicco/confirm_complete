class Team < ApplicationRecord
  include FormSteppable
  accepts_stepped_form :input, :confirmation

  validates :name, presence: true, if: ->{ validate_on_input? || !use_stepped_form? }
end
