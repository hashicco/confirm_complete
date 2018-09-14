module CompleteShowable
  extend ActiveSupport::Concern

  included do
    before_action :show_completed, only: :show
  end

  def show_completed
    return render(:complete) if params[:__completed_now]
  end
end

