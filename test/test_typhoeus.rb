# -*- coding: utf-8 -*-

FlickRawOptions = {
  'async' => true
}

require 'test/unit'
require 'lib/flickraw'

class Basic < Test::Unit::TestCase
  
  def test_list
    flickr.photos.getRecent(:per_page => '10') do |list|
      assert_instance_of FlickRaw::ResponseList, list
      assert_equal(list.size, 10)
    end
    flickr.hydra.run
  end
  
  def people(user)
    assert_equal "41650587@N02", user.id
    assert_equal "41650587@N02", user.nsid
    assert_equal "ruby_flickraw", user.username
  end
  
  def photo(info)
    assert_equal "3839885270", info.id
    assert_equal "41650587@N02", info.owner
    assert_equal "6fb8b54e06", info.secret
    assert_equal "2485", info.server
    assert_equal 3, info.farm
    assert_equal "cat", info.title
    assert_equal 1, info.ispublic
  end

  # favorites
  def test_favorites_getPublicList
    flickr.favorites.getPublicList(:user_id => "41650587@N02") do |list|
      assert_equal 1, list.size
      assert_equal "3829093290", list[0].id
    end
    flickr.hydra.run
  end
  
  # groups
  def test_groups_getInfo
    flickr.groups.getInfo(:group_id => "51035612836@N01") do |info|
      assert_equal "51035612836@N01", info.id
      assert_equal "Flickr API", info.name
    end
    flickr.hydra.run
  end
  
  def test_groups_search
    flickr.groups.search(:text => "Flickr API") do |list|
      assert list.any? {|g| g.nsid == "51035612836@N01"}
    end
    flickr.hydra.run
  end
  
  # panda
  def test_panda_getList
    flickr.panda.getList do |pandas|
      assert_equal ["ling ling", "hsing hsing", "wang wang"], pandas.to_a
    end
    flickr.hydra.run
  end
  
  def test_panda_getList
    flickr.panda.getPhotos(:panda_name => "wang wang") do |pandas|
      assert_equal "wang wang", pandas.panda
      assert_respond_to pandas[0], :title
    end
    flickr.hydra.run
  end
  
  # people
  def test_people_findByEmail
    flickr.people.findByEmail(:find_email => "flickraw@yahoo.com") do |user|
      people user
    end
    flickr.hydra.run
  end
    
  def test_people_findByUsername
    flickr.people.findByUsername :username => "ruby_flickraw" do |user|
      people user
    end
    flickr.hydra.run
  end
  
  def test_people_getInfo
    flickr.people.getInfo(:user_id => "41650587@N02") do |user|
      people user
      assert_equal "Flickraw", user.realname
      assert_equal "http://www.flickr.com/photos/41650587@N02/", user.photosurl
      assert_equal "http://www.flickr.com/people/41650587@N02/", user.profileurl
      assert_equal "http://m.flickr.com/photostream.gne?id=41630239", user.mobileurl
      assert_equal 0, user.ispro
    end
    flickr.hydra.run
  end
  
  def test_people_getPublicGroups
    flickr.people.getPublicGroups(:user_id => "41650587@N02") do |groups|
      assert groups.to_a.empty?
    end
    flickr.hydra.run
  end
  
  def test_people_getPublicPhotos
    flickr.people.getPublicPhotos(:user_id => "41650587@N02") do |info|
      assert_equal 1, info.size
      assert_equal "1", info.total
      assert_equal 1, info.pages
      assert_equal 1, info.page
      photo info[0]
    end
    flickr.hydra.run
  end

  def test_photos_getExif
    flickr.photos.getExif(:photo_id => "3839885270") do |info|
      assert_equal "Canon DIGITAL IXUS 55", info.exif.find {|f| f.tag == "Model"}.raw
      assert_equal "1/60", info.exif.find {|f| f.tag == "ExposureTime"}.raw
      assert_equal "4.9", info.exif.find {|f| f.tag == "FNumber"}.raw
      assert_equal "1600", info.exif.find {|f| f.tag == "ImageWidth"}.raw
      assert_equal "1200", info.exif.find {|f| f.tag == "ImageHeight"}.raw
    end
    flickr.hydra.run
  end
  
  def test_photos_getSizes
    flickr.photos.getSizes(:photo_id => "3839885270") do |info|
      assert_equal "http://www.flickr.com/photos/41650587@N02/3839885270/sizes/l/", info.find {|f| f.label == "Large"}.url
      assert_equal "http://farm3.static.flickr.com/2485/3839885270_6fb8b54e06_b.jpg", info.find {|f| f.label == "Large"}.source
    end
    flickr.hydra.run
  end
  
  def test_photos_search
    flickr.photos.search(:user_id => "41650587@N02") do |info|
      photo info[0]
    end
    flickr.hydra.run
  end
  
  # photos.comments
  def test_photos_comments_getList
    flickr.photos.comments.getList(:photo_id => "3839885270") do |comments|
      assert_equal 1, comments.size
      assert_equal "3839885270", comments.photo_id
      assert_equal "41630239-3839885270-72157621986549875", comments[0].id
      assert_equal "41650587@N02", comments[0].author
      assert_equal "ruby_flickraw", comments[0].authorname
      assert_equal "http://www.flickr.com/photos/41650587@N02/3839885270/#comment72157621986549875", comments[0].permalink
      assert_equal "This is a cute cat !", comments[0].to_s
    end
    flickr.hydra.run
  end
  
  # tags
  def test_tags_getListPhoto
    flickr.tags.getListPhoto(:photo_id => "3839885270") do |tags|
      assert_equal 2, tags.tags.size
      assert_equal "3839885270", tags.id
      assert_equal %w{cat pet}, tags.tags.map {|t| t.to_s}.sort
    end
    flickr.hydra.run
  end
  
  def test_tags_getListUser
    flickr.tags.getListUser(:user_id => "41650587@N02") do |tags|
      assert_equal "41650587@N02", tags.id
      assert_equal %w{cat pet}, tags.tags.sort
    end
    flickr.hydra.run
  end
  
  # urls
  def test_urls_getGroup
    flickr.urls.getGroup(:group_id => "51035612836@N01") do |info|
      assert_equal "51035612836@N01", info.nsid
      assert_equal "http://www.flickr.com/groups/api/", info.url
    end
    flickr.hydra.run
  end
  
  def test_urls_getUserPhotos
    flickr.urls.getUserPhotos(:user_id => "41650587@N02") do |info|
      assert_equal "41650587@N02", info.nsid
      assert_equal "http://www.flickr.com/photos/41650587@N02/", info.url
    end
    flickr.hydra.run
  end
  
  def test_urls_getUserProfile
    flickr.urls.getUserProfile(:user_id => "41650587@N02") do |info|
      assert_equal "41650587@N02", info.nsid
      assert_equal "http://www.flickr.com/people/41650587@N02/", info.url
    end
    flickr.hydra.run
  end
  
  def test_urls_lookupGroup
    flickr.urls.lookupGroup(:url => "http://www.flickr.com/groups/api/") do |info|
      assert_equal "51035612836@N01", info.id
      assert_equal "Flickr API", info.groupname
    end
    flickr.hydra.run
  end
  
  def test_urls_lookupUser
    flickr.urls.lookupUser(:url => "http://www.flickr.com/photos/41650587@N02/") do |info|
      assert_equal "41650587@N02", info.id
      assert_equal "ruby_flickraw", info.username
    end
    flickr.hydra.run
  end
  
end