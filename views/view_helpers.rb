def body_id
  @layout
end

def body_classes
  dirs, file = File.split(Serve::Router.resolve("./views", request.path_info))
  classes = dirs.split("/") << file.split(".").first
  classes.map{ |c| c.gsub("_", "-").gsub(".", "") }.reject(&:blank?).join("-")
end

def relpath(path="")
  current_path = Pathname.new(File.dirname(request.path_info))
  Pathname.new(path).relative_path_from(current_path.sub(/^\//, ""))
end

def build_menu(items, attrs={})
  items = load_from_file(items) if items.is_a?(String)
  haml_tag :ul, attrs do
    items.each_with_index do |item, index|
      li_classes = []
      if is_active?(item)
        li_classes << "active"
      elsif has_active_children?(item)
        li_classes << "current"
      end
      haml_tag :li, { :class => li_classes } do
        if item.url.nil?
          haml_concat item.title
        else
          haml_tag :a, item.title, { :href => relpath(item.url), :title => item.title }
        end
        build_menu(item.children) if item.children.present?
      end
    end
  end
end

def build_breadcrumbs(items, attrs={})
  items = load_from_file(items) if items.is_a?(String)
  haml_tag :ul, attrs do
    breadcrumbs = find_breadcrumb_items(items)
    breadcrumbs.each do |breadcrumb|
      haml_tag :li do
        if breadcrumb == breadcrumbs.last
          haml_tag :strong, breadcrumb.title
        else
          haml_tag :a, breadcrumb.title, { :href => relpath(breadcrumb.url), :title => breadcrumb.title }
        end
      end
    end
  end
end

private

  def load_from_file(file)
    contents = YAML::load_file(file)
    if contents.is_a?(Array)
      contents.map{|item| Hashie::Mash.new(item)}
    else
      Hashie::Mash.new(contents)
    end
  end

  def is_active?(item)
    item.url && request.path == "/#{item.url}"
  end

  def has_active_children?(item)
    if item.children.present?
      item.children.each do |child|
        return true if is_active?(child) || has_active_children?(child)
      end
    end
    return false
  end

  def find_breadcrumb_items(items)
    items.map do |item|
      if is_active?(item)
        item
      elsif has_active_children?(item)
        [item, find_breadcrumb_items(item.children)]
      end
    end.flatten.compact
  end
