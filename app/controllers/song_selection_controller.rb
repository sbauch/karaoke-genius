class SongSelectionController < UITableViewController

  def viewDidLoad
    self.navigationItem.title = 'Pick a Song'
    self.view.backgroundColor = '#151515'.uicolor

    add_search_bar

    @table = self.tableView.tap do |tbl|
      tbl.backgroundColor = '#111111'.uicolor
      tbl.separatorColor  = '#c1c1c1'.uicolor
      tbl.delegate        = self
      tbl.dataSource      = self
      tbl.allowsSelection = true
      tbl.setSeparatorInset(UIEdgeInsetsMake(0,15,0,15))
      tbl.tableHeaderView = @search
      tbl.setTableFooterView(UIView.new) # prevents separators when table is empty
    end

    @search.becomeFirstResponder

    self
  end

  def add_search_bar
    @search = UISearchBar.alloc.initWithFrame([[0,0],[320,40]]).tap do |srch|
      srch.delegate     = self
      srch.barTintColor = '#111111'.uicolor
      srch.placeholder  = 'search for a track to sing along'
    end

    @search

  end

  def searchBar(searchbar, textDidChange: text)

    if text == (nil || '')
      @table_data = nil
      @table.reloadData
      return
    end

    @text = text

    # waits for typing to stop before firing req
    (0.2).seconds.later do
      if @text == text
        SPTRequest.performSearchWithQuery(text, queryType: SPTQueryTypeTrack, session:nil,  callback: proc{|error, list|
          if error
            p error
          else
            @table_data = list.items
            @table.reloadData
          end

        })
      end
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(cell_identifier)

    if not cell
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle,
                                                 reuseIdentifier: cell_identifier)
    end

    cell.separatorInset = UIEdgeInsetsMake(12,15,12,15)
    cell.backgroundColor = '#111111'.uicolor

    cell.textLabel.font  = UIFont.fontWithName('DINCondensedC', size: 20)
    cell.textLabel.textColor = '#ffc31c'.uicolor
    cell.textLabel.text  = @table_data[indexPath.row].name

    cell.detailTextLabel.font = UIFont.fontWithName('DINCondensedC', size: 16)
    cell.detailTextLabel.text = @table_data[indexPath.row].artists[0].name
    cell.detailTextLabel.textColor = '#e1e1e1'.uicolor

    # this is crazy that selection color requires a whole view!!
    bg_color_view = UIView.alloc.init
    bg_color_view.backgroundColor = '#ffc31c'.uicolor
    cell.setSelectedBackgroundView(bg_color_view)

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    SingalongController.alloc.init.tap do |sing|
      sing.get_lyrics(@table_data[indexPath.row].artists[0].name,
                      @table_data[indexPath.row].name)

      sing.spotify_song_id = @table_data[indexPath.row].identifier

      navigationController.pushViewController(sing, animated: true).tap do |sing|
      end
    end
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    60
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @table_data.nil? ? 0 : @table_data.count
  end

  def cell_identifier
    @@cell_identifier ||= 'Cell'
  end

end