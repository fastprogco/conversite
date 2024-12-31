module ApplicationHelper
  def sort_direction(column)
    if params[:sort] == column
      params[:direction] == "asc" ? "desc" : "asc"
    else
      "asc"
    end
  end

  def arrow_class(column)
    if params[:sort] == column
      params[:direction] == 'asc' ? 'sort-up' : 'sort-down'
    else
      ''
    end
  end
end