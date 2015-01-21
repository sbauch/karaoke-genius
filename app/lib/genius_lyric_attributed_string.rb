class GeniusLyricAttributedString

  def initialize(lyrics)
    @attributed_string = NSMutableAttributedString.alloc.initWithString("")
    lines = lyrics.map{|lyric_node| parse_lines(lyric_node)}.flatten.compact

    lines.each do |line|
      attr_string = NSAttributedString.alloc.initWithString(line.lyric + "\n",
                                                            attributes: line.is_subtext ? subtext_attrs : main_attrs)

      @attributed_string.appendAttributedString(attr_string)
    end
  end

  def parse_lines(node)
    if node.is_a?(Array)
      node.map { |subnode| parse_lines(subnode) }
    elsif node.is_a?(String)
      Line.new(lyric: node)
    elsif node.is_a?(Hash) && node["tag"] == "p"
      parse_lines(node["children"])
    elsif node.is_a?(Hash) && node["tag"] == "a"
      Line.new(lyric: node["children"].select {|l| l.is_a? String }.join("\n"))
    else
      return
    end
  end

  def attributedString
    @attributed_string
  end

  def subtext_attrs
    {NSForegroundColorAttributeName => '#999999'.uicolor}
  end

  def main_attrs
    {NSForegroundColorAttributeName => '#ffc31c'.uicolor}
  end
end