module ApplicationHelper
  def page_title
    if @page_title
      "Crummy Test - #{@page_title}"
    else
      'Crummy Test'
    end
  end
end
