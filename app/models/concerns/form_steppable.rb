module FormSteppable
  extend ActiveSupport::Concern

  included do
    attr_writer :form_step
    attr_writer :form_transition
    attr_writer :use_stepped_form

    validate :form_step_must_be_last, if: :use_stepped_form?

    after_validation ->{
      case self.form_transition
      when :__progress
        self.form_step = self.next_form_step_name unless has_errors_except_form_step?
      when :__regress
        self.form_step = self.prev_form_step_name
      when :__finish
        self.form_step = self.last_form_step_name
      end
    }
  end

  class_methods do
    attr_accessor :form_steps

    def accepts_stepped_form(*steps)
      self.form_steps = steps
      form_steps.each do |step|
        class_eval <<-RUBY
          def validate_on_#{step}?
            use_stepped_form? && !form_transition_regress? && self.form_step == :#{step}
          end
        RUBY
      end
    end

    def first_form_step_name
      form_steps[0]
    end

    def last_form_step_name
      form_steps[-1]
    end
  end

  def has_errors_except_form_step?
    errors_except_form_step.any?
  end

  def errors_except_form_step
    errors = self.errors.dup
    errors.delete(:form_step)
    errors
  end

  def form_step_must_be_last
    return if on_last_form_step? && form_transition_finish?
    errors.add(:form_step, 'Current step is not last yet.')
  end

  def form_step
    (@form_step || self.class.form_steps[0])&.to_sym
  end

  def form_transition
    @form_transition&.to_sym.in?(%i[__progress __regress __finish]) ? @form_transition&.to_sym : :__progress
  end

  def use_stepped_form
    @use_stepped_form ||= true
  end
  alias :use_stepped_form? :use_stepped_form

  def form_transition_regress?
    self.form_transition == :__regress
  end

  def form_transition_progress?
    self.form_transition == :__progress
  end

  def form_transition_finish?
    self.form_transition == :__finish
  end

  def on_first_form_step?
    form_step == self.class.first_form_step_name
  end

  def on_last_form_step?
    form_step == self.class.last_form_step_name
  end

  def prev_form_step_name
    self.class.form_steps[form_step_index - 1]
  end

  def next_form_step_name
    self.class.form_steps[form_step_index + 1]
  end

  def last_form_step_name
    self.class.last_form_step_name
  end

  def form_step_index
    self.class.form_steps.index(form_step.to_sym)
  end

  def step_partial_form_name
    "form_#{form_step}"
  end

end
