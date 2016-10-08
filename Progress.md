
====== 0.0.1 =====

MyModule.constants.select {|c| Class === MyModule.const_get(c)}


====== 0.0.2 =====

require 'active_support/core_ext/class/attribute'
class Base

  def self.inherited(subclass)
    subclass.class_attribute :foo
  end

  def self.set_foo(value)
    self.foo = value
  end

  def self.foo
    self.foo
  end
end


class Sub < Base

end



class Sub2 < Base

end

# Sub.set_foo(:test)

# Object.send(:remove_const, :Sub)

====== 0.0.3 ========
