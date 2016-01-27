require 'liquefied/version'

class Liquefied < BasicObject

  # Public: Wrap an object with a default finalizer method
  #
  # The object remains wrapped and responds to all its original methods
  # until the finalizer method is called. The finalizer method can be
  # set up with default arguments, which are passed if the method is called
  # implicitly or with no options.
  #
  # object - The original value to wrap
  #
  # @example
  #   Liquefied.new(12.333, :to_s) { |val| "%.2f" % val }
  #   Liquefied.new(Date.new(2016,1,1), :to_s, :long)
  #   #=> "January 1, 2016"
  #
  def initialize(original, *default_args, method: :to_s, &default_block)
    @original = original
    @finalizer = method
    @default_args = default_args
    @default_block = default_block
  end

  def inspect
    "#<Liquefied(#{@original.class}):#{@original.object_id}>"
  end

  def object
    @original
  end

  def ==(other)
    @original == other
  end

  private

  def method_missing(method, *args, &block)
    if method == @finalizer
      _finalize!(*args, &block)
    else
      result = @original.public_send(method, *args, &block)
      if result.class == @original.class
        ::Liquefied.new(result, *@default_args, method: @finalizer, &@default_block)
      else
        result
      end
    end
  end

  def _finalize!(*args, &block)
    block = block || @default_block
    if block
      block.call(@original, *args)
    else
      args = @default_args if args.empty?
      @original.public_send(@finalizer, *args, &block)
    end
  end

end