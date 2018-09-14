class User < ApplicationRecord
  include FormSteppable
  accepts_stepped_form :input_name, :input_email, :input_etc, :confirmation

  validates :first_name, presence: true, if: ->{ validate_on_input_name? || !use_stepped_form? }
  validates :last_name, presence: true, if: ->{ validate_on_input_name? || !use_stepped_form? }
  validates :email, presence: true, if: ->{ validate_on_input_email? || !use_stepped_form? }
end
