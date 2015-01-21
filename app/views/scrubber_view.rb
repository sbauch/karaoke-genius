class ScrubberView < UIView
  attr_accessor :delegate

  def init
    super
    self.frame = [[0,64],[Device.screen.width,40]]
    addGrey
    addGold
    addBar
    self.on_tap do |gesture|
      location = gesture.locationInView(self)
      seek(location.x)
    end
    self
  end

  def addGrey
    grey = UIView.alloc.initWithFrame([[0,0],[Device.screen.width,6]]).tap do |g|
      g.backgroundColor = '#9c9c9c'.uicolor
      g.on_tap do |gesture|
        location = gesture.locationInView(self)
        seek(location.x)
      end
    end
    addSubview(grey)
  end

  def addGold
    @gold = UIView.alloc.initWithFrame([[0,0],[0,6]]).tap do |g|
      g.backgroundColor = '#ffc31c'.uicolor
      g.on_tap do |gesture|
        location = gesture.locationInView(self)
        seek(location.x)
      end
    end

    addSubview(@gold)
  end

  def addBar
    @bar ||= UIView.alloc.initWithFrame([[-42,0],[44,40]]).tap do |b|
      b.backgroundColor = UIColor.clearColor
      b.on_pan do |gesture|
        location = gesture.locationInView(self)
        seek(location.x)
      end
      white_part = UIView.alloc.initWithFrame([[20,0],[4,12]]).tap do |w|
        w.backgroundColor = '#e1e1e1'.uicolor
      end
      b.addSubview(white_part)
    end

    addSubview(@bar)
  end

  def update(playbackPosition, duration)
    percentage = playbackPosition/duration
    width = (percentage * 320).ceil
    if @width != width
      @gold.reframe_to([[0,0],[width, 6]])
      @bar.reframe_to([[width - 22, 0],[44,40]])
      setNeedsDisplay
      @width = width
    end
  end

  def seek(location_x)
    @gold.reframe_to([[0,0],[location_x, 6]])
    @bar.reframe_to([[location_x - 22, 0],[44,30]])
    percentage = location_x / 320
    delegate.seek_to_percentage(percentage)
  end

end