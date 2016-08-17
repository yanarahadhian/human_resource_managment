module WillPaginate
  class MyLinkRenderer < LinkRenderer
    def to_html
      links = @options[:page_links] ? windowed_links : []
      # previous/next buttons
      links.unshift page_link_or_span(@collection.previous_page, 'disabled prev_page', @options[:previous_label])

      # Add my first link
      links.unshift page_link_or_span(1, 'disabled first_page', 'first')
      links.push    page_link_or_span(@collection.next_page,     'disabled next_page', @options[:next_label])

      # Add my last link
      links.push    page_link_or_span(@collection.total_pages,     'disabled last_page', 'LAST')

      html = links.join(@options[:separator])
      @options[:container] ? @template.content_tag(:div, html, html_attributes) : html
    end
  end
end
