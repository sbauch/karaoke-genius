class Line

  attr_accessor :lyric, :is_subtext

  def initialize(args)
    self.lyric = args.delete(:lyric)
    self.is_subtext = is_subtext?
  end

  def is_subtext?
    @lyric[0] == '['
  end

end