class String
  def to_ellipsis(max_length)
    if self.length > max_length + 2
      return self[0, max_length] + "..."
    else
      return self
    end
  end
end