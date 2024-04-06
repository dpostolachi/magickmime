defmodule MagickmimeTest do
  use ExUnit.Case
  import Magickmime
  doctest Magickmime

  test "png test" do
    {:ok, file} = File.open("test/image.png", [:read])
    data = IO.binread( file, :all )
    assert guess( data ) == "image/png"
    assert is?( data, "image/*" )
    assert is?( data, "image/png" )
  end

  test "jpeg test" do
    {:ok, file} = File.open("test/image.jpg", [:read])
    data = IO.binread( file, :all )
    assert guess( data ) == "image/jpeg"
    assert is?( data, "image/jpeg" )
    assert is?( data, [ "image/png", "image/jpeg" ] )
  end

  test "bmp test" do
    {:ok, file} = File.open("test/image.bmp", [:read])
    data = IO.binread( file, :all )
    assert guess( data ) == "image/bmp"
    assert not is?(data, [ "image/png", "image/jpeg" ] )
  end

  test "avif test" do
    {:ok, file} = File.open("test/output3.avif", [:read])
    data = IO.binread( file, :all )
    assert guess( data ) == "image/avif"
    assert is?( data, [ "image/avif" ] )
    assert is?( data, [ "image/*" ] )
  end

end
