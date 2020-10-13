defprotocol Magickmime do
  @spec mime(binary) :: atom | {:error, <<_::192, _::_*32>>}
  def mime(value)
end
