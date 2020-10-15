defmodule MagickmimeTest do
  use ExUnit.Case
  import Magickmime
  doctest Magickmime

  test "png test" do
    {:ok, file} = File.open("test/image.png", [:read])
    data = IO.binread( file, :all )
    assert mime( data ) == "image/png"
  end

  test "jpeg test" do
    {:ok, file} = File.open("test/image.jpg", [:read])
    data = IO.binread( file, :all )
    assert mime( data ) == "image/jpeg"
  end

  test "bmp test" do
    {:ok, file} = File.open("test/image.bmp", [:read])
    data = IO.binread( file, :all )
    assert mime( data ) == "image/bmp"
  end

end
