class NullTest
  def variant
  end

  def method_missing(meth, *args, &block)
    meth.to_s.end_with?('?') ? false : super
  end

  def respond_to?(meth)
    meth.to_s.end_with?('?') ? true : super
  end
end
